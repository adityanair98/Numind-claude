import Foundation

struct QuizEngine {

    // MARK: - Public API

    /// Generates a question from `template`, re-rolling variables up to `maxAttempts` times
    /// until the computed difficulty matches `targetDifficulty`. Falls back to the last
    /// attempt if the target is never reached.
    static func generate(
        from template: QuizTemplate,
        targetDifficulty: QuestionDifficulty? = nil,
        maxAttempts: Int = 6
    ) -> QuizQuestion {
        guard let target = targetDifficulty else {
            return generate(from: template, seed: .random(in: 1...UInt64.max))
        }
        var best: QuizQuestion? = nil
        for _ in 0..<maxAttempts {
            let q = generate(from: template, seed: .random(in: 1...UInt64.max))
            if q.difficulty == target { return q }
            if best == nil { best = q }
        }
        return best!   // never nil — loop runs at least once
    }

    static func generate(from template: QuizTemplate, seed: UInt64 = .random(in: 1...UInt64.max)) -> QuizQuestion {
        var rng = SeededRandomGenerator(seed: seed)

        // ── Concept template path (no formula, text-based MCQ) ──
        if let conceptChoices = template.conceptChoices,
           let correctText = template.correctConceptChoice {
            let made = conceptChoices.map { QuizQuestion.Choice(id: UUID(), text: $0) }
            let shuffled = made.shuffled(using: &rng)
            guard let correctChoice = shuffled.first(where: { $0.text == correctText }) else {
                fatalError("QuizEngine: correctConceptChoice '\(correctText)' not in conceptChoices for \(template.id)")
            }
            // Difficulty for concept templates comes from the static tier (no operations to score).
            let difficulty: QuestionDifficulty = {
                switch template.difficulty {
                case 1:  return .easy
                case 2:  return .medium
                default: return .hard
                }
            }()
            return QuizQuestion(
                id: UUID(),
                templateId: template.id,
                difficulty: difficulty,
                inputMode: template.inputMode ?? .multipleChoice,
                answerFormat: template.answerFormat,
                correctValue: -1,                       // sentinel — concept templates have no numeric answer
                scenario: template.scenarioTemplate,
                prompt: template.promptTemplate,        // no variable rendering — concept prompts are static
                choices: shuffled,
                correctChoiceId: correctChoice.id,
                explanation: template.explanationTemplate
            )
        }

        // ── Numerical template path (existing flow) ──
        let variables = resolveVariables(template.variableRules, using: &rng)

        guard let formula = template.answerFormula else {
            fatalError("QuizEngine: template \(template.id) has neither answerFormula nor conceptChoices")
        }
        let correctRaw: Double
        switch compute(formula: formula, variables: variables) {
        case .ok(let value):
            correctRaw = value
        case .formulaNotRegistered:
            fatalError("QuizEngine: unknown formula '\(formula)' — not in registry. Template '\(template.id)' references a formula key that doesn't exist. Check for a typo in the template JSON.")
        case .formulaReturnedNil:
            fatalError("QuizEngine: formula '\(formula)' returned nil for variables \(variables.keys.sorted()) — likely a missing or mismatched variable name. Template '\(template.id)' did not supply a variable the formula requires (or named it differently). Check the formula's `guard let` clauses against the template's variableRules.")
        }
        let correctValue = correctRaw.rounded2dp

        // Assess difficulty from the actual generated numbers, not the template's static tier.
        let ops = FormulaOperationMap.operations(formula: formula, variables: variables)
        let difficulty: QuestionDifficulty = ops.isEmpty ? .easy : DifficultyScorer.score(operations: ops)

        let distractorValues = distractors(
            correct: correctValue,
            strategy: template.distractorStrategy,
            variables: variables,
            using: &rng
        )

        let correctChoice = QuizQuestion.Choice(id: UUID(), text: format(correctValue, as: template.answerFormat))
        let distractorChoices = distractorValues.map {
            QuizQuestion.Choice(id: UUID(), text: format($0, as: template.answerFormat))
        }

        let allChoices = ([correctChoice] + distractorChoices).shuffled(using: &rng)

        let scenario = template.scenarioTemplate.map { render($0, variables: variables) }

        // Inject the computed answer into the render context so explanation
        // templates can reference it as {{answer}} (e.g. "72 ÷ 8 = {{answer}} years").
        var renderVars = variables
        renderVars["answer"] = correctValue

        return QuizQuestion(
            id: UUID(),
            templateId: template.id,
            difficulty: difficulty,
            inputMode: template.inputMode ?? .multipleChoice,
            answerFormat: template.answerFormat,
            correctValue: correctValue,
            scenario: scenario,
            prompt: render(template.promptTemplate, variables: variables),
            choices: allChoices,
            correctChoiceId: correctChoice.id,
            explanation: render(template.explanationTemplate, variables: renderVars)
        )
    }

    // MARK: - Answer formatting (internal + exposed for UI)

    static func format(_ value: Double, as answerFormat: AnswerFormat) -> String {
        switch answerFormat {
        case .currency:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
        case .percent:  return String(format: "%.0f%%", value)
        case .integer:  return String(Int(value.rounded()))
        }
    }

    // MARK: - Variable resolution

    private static func resolveVariables(_ rules: [VariableRule], using rng: inout SeededRandomGenerator) -> [String: Double] {
        var result: [String: Double] = [:]
        for rule in rules where !rule.options.isEmpty {
            let idx = Int(rng.next() % UInt64(rule.options.count))
            result[rule.name] = rule.options[idx]
        }
        return result
    }

    // MARK: - Formula registry

    private static let formulas: [String: ([String: Double]) -> Double?] = [
        "tipAmount": { vars in
            guard let bill = vars["billAmount"], let pct = vars["tipPercent"] else { return nil }
            return bill * pct / 100
        },
        "billWithTip": { vars in
            guard let bill = vars["billAmount"], let pct = vars["tipPercent"] else { return nil }
            return bill * (1 + pct / 100)
        },
        "tipPerPerson": { vars in
            guard let bill = vars["billAmount"], let pct = vars["tipPercent"],
                  let n = vars["numPeople"], n > 0 else { return nil }
            return bill * pct / 100 / n
        },
        "discountAmount": { vars in
            guard let price = vars["originalPrice"], let pct = vars["discountPercent"] else { return nil }
            return price * pct / 100
        },
        "salePrice": { vars in
            guard let price = vars["originalPrice"], let pct = vars["discountPercent"] else { return nil }
            return price * (1 - pct / 100)
        },
        // Money Math formulas
        "taxAmount": { vars in
            guard let price = vars["originalPrice"], let pct = vars["taxPercent"] else { return nil }
            return price * pct / 100
        },
        "priceWithTax": { vars in
            guard let price = vars["originalPrice"], let pct = vars["taxPercent"] else { return nil }
            return price * (1 + pct / 100)
        },
        "totalCost": { vars in
            guard let price = vars["itemPrice"], let qty = vars["quantity"] else { return nil }
            return price * qty
        },
        "unitPrice": { vars in
            guard let total = vars["totalPrice"], let qty = vars["quantity"], qty > 0 else { return nil }
            return total / qty
        },
        // Shared Math Shortcuts (used by multiple modules)
        "doubleOf": { vars in
            guard let amount = vars["originalAmount"] else { return nil }
            return amount * 2
        },
        "halfOf": { vars in
            guard let amount = vars["originalAmount"] else { return nil }
            return amount / 2
        },
        "multiplyBy5": { vars in
            guard let amount = vars["originalAmount"] else { return nil }
            return amount * 5
        },
        "splitFive": { vars in
            guard let total = vars["totalAmount"] else { return nil }
            return total / 5
        },
        // Money Math — budget
        "budgetRemaining": { vars in
            guard let budget = vars["budget"], let spent = vars["spent"] else { return nil }
            return budget - spent
        },
        "budgetAfterPurchase": { vars in
            guard let budget = vars["budget"],
                  let qty = vars["quantity"],
                  let price = vars["itemPrice"] else { return nil }
            return budget - qty * price
        },
        // Money Math — subscriptions
        "monthlyToYearly": { vars in
            guard let monthly = vars["monthlyPrice"] else { return nil }
            return monthly * 12
        },
        "annualPlanSaving": { vars in
            guard let monthly = vars["monthlyPrice"],
                  let annual = vars["annualPrice"] else { return nil }
            return monthly * 12 - annual
        },
        "yearlyToMonthly": { vars in
            guard let yearly = vars["yearlyPrice"] else { return nil }
            return yearly / 12
        },
        // Money Math — cost per use
        "costPerUse": { vars in
            guard let price = vars["itemPrice"],
                  let uses = vars["numberOfUses"], uses > 0 else { return nil }
            return price / uses
        },
        // Tips — post-tax tip (tip calculated on subtotal + tax)
        "tipOnTotal": { vars in
            guard let subtotal = vars["billAmount"],
                  let tipPct = vars["tipPercent"],
                  let taxPct = vars["taxPercent"] else { return nil }
            return subtotal * (1 + taxPct / 100) * tipPct / 100
        },
        // Discounts — BOGO
        "bogoPerItemPrice": { vars in
            // Buy 2 get 1 free: pay for 2, receive 3 → cost per item = (2 × price) / 3
            guard let price = vars["itemPrice"] else { return nil }
            return (2 * price) / 3
        },
        "bogoSavings": { vars in
            // Total saving on a BOGO-3 deal = exactly one item's price (the free one)
            guard let price = vars["itemPrice"] else { return nil }
            return price
        },
        // Salary & Income
        "grossToNet": { vars in
            guard let gross = vars["grossPay"],
                  let pct = vars["deductionPercent"] else { return nil }
            return gross * (1 - pct / 100)
        },
        "annualToMonthly": { vars in
            guard let annual = vars["annualSalary"] else { return nil }
            return annual / 12
        },
        "raiseAmount": { vars in
            guard let salary = vars["annualSalary"],
                  let pct = vars["raisePercent"] else { return nil }
            return salary * pct / 100
        },
        "raisedSalary": { vars in
            guard let salary = vars["annualSalary"],
                  let pct = vars["raisePercent"] else { return nil }
            return salary * (1 + pct / 100)
        },
        "overtimePay": { vars in
            guard let rate = vars["regularRate"],
                  let hours = vars["overtimeHours"] else { return nil }
            return rate * 1.5 * hours
        },
        "biweeklyToAnnual": { vars in
            guard let biweekly = vars["biweeklySalary"] else { return nil }
            return biweekly * 26
        },
        "weeklyToAnnual": { vars in
            guard let weekly = vars["weeklySalary"] else { return nil }
            return weekly * 52
        },
        "payPeriodDifference": { vars in
            guard let weekly = vars["weeklyPay"],
                  let biweekly = vars["biweeklyPay"] else { return nil }
            return abs(weekly * 52 - biweekly * 26)
        },
        // Investing Basics
        "simpleInterest": { vars in
            guard let principal = vars["principal"],
                  let rate = vars["interestRate"],
                  let years = vars["years"] else { return nil }
            return principal * rate / 100 * years
        },
        "totalWithInterest": { vars in
            guard let principal = vars["principal"],
                  let rate = vars["interestRate"],
                  let years = vars["years"] else { return nil }
            return principal * (1 + rate / 100 * years)
        },
        "rule72": { vars in
            // Accept any of the common rate-input names so the same formula can
            // serve "interestRate" (investment-return lessons) and "apy"
            // (HYSA / savings doubling-time lessons).
            let rate = vars["interestRate"] ?? vars["apy"] ?? vars["apr"] ?? vars["rate"]
            guard let r = rate, r > 0 else { return nil }
            return 72 / r
        },
        "roiPercent": { vars in
            guard let cost = vars["cost"], cost > 0,
                  let gain = vars["gain"] else { return nil }
            return (gain / cost) * 100
        },
        "dollarReturn": { vars in
            guard let cost = vars["cost"],
                  let pct = vars["roiPercent"] else { return nil }
            return cost * pct / 100
        },
        // 401(k) Match
        "employerMatchAmount": { vars in
            guard let contribution = vars["contribution"],
                  let matchPct = vars["matchPercent"] else { return nil }
            return contribution * matchPct / 100
        },
        "totalWithMatch": { vars in
            guard let contribution = vars["contribution"],
                  let matchPct = vars["matchPercent"] else { return nil }
            return contribution * (1 + matchPct / 100)
        },
        "employerMatchFromSalary": { vars in
            guard let salary = vars["annualSalary"],
                  let contribPct = vars["contribPercent"],
                  let matchPct = vars["matchPercent"] else { return nil }
            return salary * contribPct / 100 * matchPct / 100
        },
        "totalContribFromSalary": { vars in
            guard let salary = vars["annualSalary"],
                  let contribPct = vars["contribPercent"],
                  let matchPct = vars["matchPercent"] else { return nil }
            let contrib = salary * contribPct / 100
            return contrib * (1 + matchPct / 100)
        },
        // Roth vs Traditional IRA
        "rothTaxPaid": { vars in
            guard let contribution = vars["contribution"],
                  let taxRate = vars["taxRate"] else { return nil }
            return contribution * taxRate / 100
        },
        "traditionalTaxSaved": { vars in
            guard let contribution = vars["contribution"],
                  let taxRate = vars["taxRate"] else { return nil }
            return contribution * taxRate / 100
        },
        "rothAfterTaxCost": { vars in
            guard let contribution = vars["contribution"],
                  let taxRate = vars["taxRate"] else { return nil }
            return contribution * (1 + taxRate / 100)
        },
        "traditionalNetCost": { vars in
            guard let contribution = vars["contribution"],
                  let taxRate = vars["taxRate"] else { return nil }
            return contribution * (1 - taxRate / 100)
        },
        "rothVsTradDifference": { vars in
            guard let contribution = vars["contribution"],
                  let taxRate = vars["taxRate"] else { return nil }
            return contribution * taxRate / 100
        },
        // Compound Growth
        "totalContributed": { vars in
            guard let monthly = vars["monthlyAmount"],
                  let years = vars["years"] else { return nil }
            return monthly * 12 * years
        },
        "interestEarned": { vars in
            guard let total = vars["totalContributed"],
                  let finalVal = vars["finalValue"] else { return nil }
            return finalVal - total
        },
        "finalAccountValue": { vars in
            guard let total = vars["totalContributed"],
                  let growth = vars["growthAmount"] else { return nil }
            return total + growth
        },
        // Inflation-Adjusted Raise
        "inflationAdjustedRaise": { vars in
            guard let raise_ = vars["raisePercent"],
                  let inflation = vars["inflationPercent"] else { return nil }
            return raise_ - inflation
        },
        "inflationAdjustedRaiseA": { vars in
            guard let raise_ = vars["raisePercentA"],
                  let inflation = vars["inflationPercent"] else { return nil }
            return raise_ - inflation
        },
        "realRaiseDollars": { vars in
            guard let salary = vars["annualSalary"],
                  let raise_ = vars["raisePercent"],
                  let inflation = vars["inflationPercent"] else { return nil }
            return salary * (raise_ - inflation) / 100
        },
        "salaryInRealTerms": { vars in
            guard let salary = vars["annualSalary"],
                  let raise_ = vars["raisePercent"],
                  let inflation = vars["inflationPercent"] else { return nil }
            return salary * (1 + raise_ / 100) / (1 + inflation / 100)
        },
        // Shared Math Shortcuts — rounding
        "estimateSumNearestTen": { vars in
            guard let a = vars["priceA"], let b = vars["priceB"] else { return nil }
            let roundA = (a / 10).rounded() * 10
            let roundB = (b / 10).rounded() * 10
            return roundA + roundB
        },
        // Shared Math Shortcuts — salary conversion
        "hourlyFromAnnual": { vars in
            guard let annual = vars["annualSalary"] else { return nil }
            return annual / 2000
        },
        "annualFromHourly": { vars in
            guard let hourly = vars["hourlyRate"] else { return nil }
            return hourly * 2000
        },
        // Shared Math Shortcuts — percent change
        "percentRaise": { vars in
            guard let base = vars["basePrice"], base > 0,
                  let increase = vars["increaseAmount"] else { return nil }
            return increase / base * 100
        },
        "percentDrop": { vars in
            guard let base = vars["basePrice"], base > 0,
                  let decrease = vars["decreaseAmount"] else { return nil }
            return decrease / base * 100
        },
        // Tips — total per person including tip
        "billWithTipPerPerson": { vars in
            guard let bill = vars["billAmount"],
                  let pct = vars["tipPercent"],
                  let n = vars["numPeople"], n > 0 else { return nil }
            return bill * (1 + pct / 100) / n
        },
        // Salary — monthly to annual
        "monthlyToAnnual": { vars in
            guard let monthly = vars["monthlyIncome"] else { return nil }
            return monthly * 12
        },
        // Investing — monthly return on principal
        "monthlyInvestmentReturn": { vars in
            guard let principal = vars["principal"],
                  let rate = vars["interestRate"] else { return nil }
            return principal * rate / 100 / 12
        },
        // Shared Math Shortcuts — triple / quarter / 20%
        "tripleOf": { vars in
            guard let amount = vars["originalAmount"] else { return nil }
            return amount * 3
        },
        "quarterOf": { vars in
            guard let amount = vars["originalAmount"] else { return nil }
            return amount / 4
        },
        "twentyPercentOf": { vars in
            guard let amount = vars["originalAmount"] else { return nil }
            return amount / 5
        },
        // Discounts — stacked
        "stackedFinalPrice": { vars in
            guard let price = vars["originalPrice"],
                  let first = vars["firstDiscount"],
                  let second = vars["secondDiscount"] else { return nil }
            return price * (1 - first / 100) * (1 - second / 100)
        },
        "stackedTotalSaving": { vars in
            guard let price = vars["originalPrice"],
                  let first = vars["firstDiscount"],
                  let second = vars["secondDiscount"] else { return nil }
            return price - price * (1 - first / 100) * (1 - second / 100)
        },

        // Debt & Loans
        "creditCardMonthlyInterest": { vars in
            guard let balance = vars["balance"], let apr = vars["apr"] else { return nil }
            return balance * apr / 100 / 12
        },
        "creditCardAnnualInterest": { vars in
            guard let balance = vars["balance"], let apr = vars["apr"] else { return nil }
            return balance * apr / 100
        },
        "minimumPaymentTwoPercent": { vars in
            guard let balance = vars["balance"] else { return nil }
            return balance * 0.02
        },
        // Realistic minimum-payment estimate matching how most issuers calculate:
        // ~1% of principal + this month's interest accrual. Issuers also apply a
        // $25-$35 floor on small balances; the mental-math version omits the floor
        // because the templates only present balances large enough that 1% + interest
        // clears it. The "2% of balance" rule taught in older personal-finance books
        // is a simplification that understates what you owe in high-APR months.
        "realisticMinPayment": { vars in
            guard let balance = vars["balance"], let apr = vars["apr"] else { return nil }
            let principalPortion = balance * 0.01
            let monthlyInterest = balance * apr / 1200   // apr% ÷ 12 months
            return principalPortion + monthlyInterest
        },
        "debtToIncomeRatio": { vars in
            guard let totalDebt = vars["totalDebt"],
                  let monthlyIncome = vars["monthlyIncome"], monthlyIncome > 0 else { return nil }
            return totalDebt / monthlyIncome * 100
        },
        "loanTotalRepayment": { vars in
            guard let payment = vars["monthlyPayment"],
                  let months = vars["numMonths"] else { return nil }
            return payment * months
        },
        "loanTotalInterest": { vars in
            guard let payment = vars["monthlyPayment"],
                  let months = vars["numMonths"],
                  let principal = vars["loanAmount"] else { return nil }
            return payment * months - principal
        },
        "balanceAfterMonthlyInterest": { vars in
            guard let balance = vars["balance"], let apr = vars["apr"] else { return nil }
            return balance * (1 + apr / 100 / 12)
        },
        "extraPaymentAnnualSaving": { vars in
            guard let extra = vars["extraPayment"], let apr = vars["apr"] else { return nil }
            return extra * apr / 100
        },
        "totalMonthlyPayments": { vars in
            guard let p1 = vars["payment1"], let p2 = vars["payment2"] else { return nil }
            return p1 + p2
        },

        // Housing & Rent
        "maxRent28": { vars in
            guard let monthly = vars["monthlySalary"] else { return nil }
            return monthly * 0.28
        },
        "maxAnnualRent28": { vars in
            guard let monthly = vars["monthlySalary"] else { return nil }
            return monthly * 0.28 * 12
        },
        "rentIncrease": { vars in
            guard let rent = vars["currentRent"],
                  let pct = vars["increasePercent"] else { return nil }
            return rent * pct / 100
        },
        "newRentAfterIncrease": { vars in
            guard let rent = vars["currentRent"],
                  let pct = vars["increasePercent"] else { return nil }
            return rent * (1 + pct / 100)
        },
        "moveInTotal": { vars in
            guard let first = vars["firstMonth"],
                  let last = vars["lastMonth"],
                  let deposit = vars["securityDeposit"] else { return nil }
            let broker = vars["brokerFee"] ?? 0
            return first + last + deposit + broker
        },
        "moveInThreeMonths": { vars in
            guard let rent = vars["monthlyRent"] else { return nil }
            return rent * 3
        },
        "moveInWithBrokerFee": { vars in
            guard let rent = vars["monthlyRent"],
                  let broker = vars["brokerFee"] else { return nil }
            return rent * 3 + broker
        },
        "pricePerSqft": { vars in
            guard let price = vars["monthlyRent"],
                  let sqft = vars["squareFeet"], sqft > 0 else { return nil }
            return price / sqft
        },
        "monthlyMortgage": { vars in
            // Simplified: principal × (annualRate / 12) — interest-only approximation
            guard let principal = vars["loanAmount"],
                  let rate = vars["annualRate"],
                  let years = vars["loanYears"], years > 0 else { return nil }
            return principal * (rate / 100 / 12) + principal / (years * 12)
        },

        // Taxes & Paycheck
        "marginalTax": { vars in
            // Simplified 2-bracket system: first bracket taxed at rate1, remainder at rate2
            guard let income = vars["taxableIncome"],
                  let bracket1 = vars["bracket1Limit"],
                  let rate1 = vars["rate1"],
                  let rate2 = vars["rate2"] else { return nil }
            if income <= bracket1 {
                return income * rate1 / 100
            }
            return bracket1 * rate1 / 100 + (income - bracket1) * rate2 / 100
        },
        "paycheckNet": { vars in
            guard let gross = vars["grossPay"],
                  let ficaRate = vars["ficaRate"],
                  let fedRate = vars["federalRate"],
                  let stateRate = vars["stateRate"] else { return nil }
            let totalRate = ficaRate + fedRate + stateRate
            return gross * (1 - totalRate / 100)
        },
        "annualToMonthlyNet": { vars in
            guard let annual = vars["annualSalary"],
                  let totalRate = vars["totalDeductionRate"] else { return nil }
            return annual * (1 - totalRate / 100) / 12
        },
        "taxRefund": { vars in
            guard let withheld = vars["totalWithheld"],
                  let owed = vars["taxOwed"] else { return nil }
            return withheld - owed
        },
        "selfEmploymentTax": { vars in
            // SE tax is calculated on 92.35% of net SE earnings (you deduct the
            // employer-equivalent half before calculating). This matches IRS
            // Schedule SE: net earnings × 0.9235 × 0.153 = effective ~14.13%.
            guard let income = vars["freelanceIncome"] else { return nil }
            return income * 0.9235 * 0.153
        },

        // ── Insurance & Healthcare formulas ─────────────────────────────────────

        "insurancePremiumAnnual": { vars in
            guard let monthly = vars["monthlyPremium"] ?? vars["monthlyHSA"] else { return nil }
            return monthly * 12
        },
        "insuranceWorstCase": { vars in
            guard let monthly = vars["monthlyPremium"],
                  let deductible = vars["deductible"] else { return nil }
            return monthly * 12 + deductible
        },
        "premiumDifferenceAnnual": { vars in
            guard let a = vars["premiumA"], let b = vars["premiumB"] else { return nil }
            return (a - b) * 12
        },
        "insurancePremiumPlusBills": { vars in
            guard let monthly = vars["monthlyPremium"],
                  let bills = vars["medicalBills"] else { return nil }
            return monthly * 12 + bills
        },
        "planCostDifference": { vars in
            guard let hdhpPrem = vars["hdhpPremium"],
                  let hdhpDed = vars["hdhpDeductible"],
                  let ppoPrem = vars["ppoPremium"],
                  let ppoCopay = vars["ppoCopay"],
                  let visits = vars["visits"] else { return nil }
            let hdhpTotal = hdhpPrem * 12 + hdhpDed
            let ppoTotal = ppoPrem * 12 + ppoCopay * visits
            return abs(hdhpTotal - ppoTotal)
        },
        "insurancePlanCompare": { vars in
            guard let premA = vars["premiumA"],
                  let dedA = vars["deductibleA"],
                  let premB = vars["premiumB"],
                  let dedB = vars["deductibleB"] else { return nil }
            let totalA = premA * 12 + dedA
            let totalB = premB * 12 + dedB
            return abs(totalA - totalB)
        },
        "coinsuranceCost": { vars in
            guard let bill = vars["billAmount"] ?? vars["totalBill"],
                  let pct = vars["coinsurancePercent"] else { return nil }
            return bill * pct / 100
        },
        "copayTotal": { vars in
            guard let copay = vars["copayAmount"],
                  let visits = vars["visitCount"] else { return nil }
            return copay * visits
        },
        "copayMixed": { vars in
            guard let primaryCopay = vars["copayPrimary"],
                  let specCopay = vars["copaySpecialist"],
                  let primaryVisits = vars["primaryVisits"],
                  let specVisits = vars["specialistVisits"] else { return nil }
            return primaryCopay * primaryVisits + specCopay * specVisits
        },
        "totalWithCoinsurance": { vars in
            guard let bill = vars["totalBill"],
                  let deductible = vars["deductible"],
                  let pct = vars["coinsurancePercent"] else { return nil }
            return deductible + (bill - deductible) * pct / 100
        },
        "oopRemaining": { vars in
            guard let max = vars["oopMax"],
                  let paid = vars["amountPaid"] else { return nil }
            return max - paid
        },
        "oopActualCost": { vars in
            guard let max = vars["oopMax"],
                  let paid = vars["amountPaid"],
                  let cost = vars["procedureCost"] else { return nil }
            let remaining = max - paid
            return min(remaining, cost)
        },
        "oopWithCap": { vars in
            guard let deductible = vars["deductible"],
                  let bill = vars["totalBill"],
                  let pct = vars["coinsurancePercent"],
                  let max = vars["oopMax"] else { return nil }
            let uncapped = deductible + (bill - deductible) * pct / 100
            return min(uncapped, max)
        },
        "oopDifference": { vars in
            guard let a = vars["oopMaxA"], let b = vars["oopMaxB"] else { return nil }
            return b - a
        },
        "maxAnnualCost": { vars in
            guard let monthly = vars["monthlyPremium"],
                  let max = vars["oopMax"] else { return nil }
            return monthly * 12 + max
        },
        "planAnnualWithCopay": { vars in
            guard let monthly = vars["monthlyPremium"],
                  let copay = vars["copayAmount"],
                  let visits = vars["visitCount"] else { return nil }
            return monthly * 12 + copay * visits
        },
        "ppoPremiumExtra": { vars in
            guard let ppo = vars["ppoPremium"],
                  let hdhp = vars["hdhpPremium"] else { return nil }
            return (ppo - hdhp) * 12
        },
        "hdhpVsPpoGap": { vars in
            guard let hdhpPrem = vars["hdhpPremium"],
                  let hdhpDed = vars["hdhpDeductible"],
                  let ppoPrem = vars["ppoPremium"] else { return nil }
            let hdhpTotal = hdhpPrem * 12 + hdhpDed
            let ppoTotal = ppoPrem * 12
            return abs(hdhpTotal - ppoTotal)
        },
        "hsaTaxSaving": { vars in
            guard let contrib = vars["hsaContribution"] ?? vars["expenseCost"],
                  let rate = vars["taxRate"] else { return nil }
            return contrib * rate / 100
        },
        "hsaAnnualContribution": { vars in
            guard let monthly = vars["monthlyHSA"] else { return nil }
            return monthly * 12
        },
        "hsaEffectiveCost": { vars in
            guard let cost = vars["expenseCost"],
                  let rate = vars["taxRate"] else { return nil }
            return cost - cost * rate / 100
        },
        "hdhpNetAdvantage": { vars in
            guard let hdhp = vars["hdhpPremium"],
                  let ppo = vars["ppoPremium"],
                  let hsaSaving = vars["hsaTaxSaving"] else { return nil }
            return (ppo - hdhp) * 12 + hsaSaving
        },
        "hsaTotalTaxSaving": { vars in
            guard let contrib = vars["hsaContribution"],
                  let rate = vars["taxRate"],
                  let years = vars["years"] else { return nil }
            return contrib * rate / 100 * years
        },

        // ── Car & Big Purchases formulas ────────────────────────────────────────

        "carTotalPaid": { vars in
            guard let payment = vars["monthlyPayment"],
                  let months = vars["loanTermMonths"] else { return nil }
            return payment * months
        },
        "carInterestPaid": { vars in
            guard let loan = vars["loanAmount"],
                  let total = vars["totalPaid"] else { return nil }
            return total - loan
        },
        "carTotalWithDown": { vars in
            guard let down = vars["downPayment"],
                  let payment = vars["monthlyPayment"],
                  let months = vars["termMonths"] else { return nil }
            return down + payment * months
        },
        "loanTotalDifference": { vars in
            guard let payA = vars["paymentA"], let termA = vars["termA"],
                  let payB = vars["paymentB"], let termB = vars["termB"] else { return nil }
            return abs(payB * termB - payA * termA)
        },
        "extraInterestCost": { vars in
            guard let total60 = vars["total60"], let total72 = vars["total72"],
                  let loan = vars["loanAmount"] else { return nil }
            return (total72 - loan) - (total60 - loan)
        },
        "carTotalFromYears": { vars in
            guard let payment = vars["monthlyPayment"] ?? vars["budget"],
                  let years = vars["termYears"] else { return nil }
            return payment * years * 12
        },
        "monthlyDifference": { vars in
            // Generic: difference between two monthly amounts
            if let a = vars["payment5"], let b = vars["payment6"] { return a - b }
            if let a = vars["payment10"], let b = vars["payment20"] { return a - b }
            if let a = vars["oldPayment"], let b = vars["newPayment"] { return a - b }
            if let a = vars["standardPayment"], let b = vars["idrPayment"] { return (a - b) }
            return nil
        },
        "termInterestDifference": { vars in
            guard let loan = vars["loanAmount"],
                  let pay48 = vars["payment48"],
                  let pay72 = vars["payment72"] else { return nil }
            let int48 = pay48 * 48 - loan
            let int72 = pay72 * 72 - loan
            return int72 - int48
        },
        "interestPercentOfTotal": { vars in
            guard let loan = vars["loanAmount"],
                  let payB = vars["paymentB"],
                  let termB = vars["termB"] else { return nil }
            let totalB = payB * termB
            let interest = totalB - loan
            return interest / totalB * 100
        },
        "carDownPaymentAmount": { vars in
            guard let price = vars["carPrice"],
                  let pct = vars["downPercent"] else { return nil }
            return price * pct / 100
        },
        "carLoanAfterDown": { vars in
            guard let price = vars["carPrice"],
                  let down = vars["downPayment"] else { return nil }
            return price - down
        },
        "carInterestOnLoan": { vars in
            guard let price = vars["carPrice"],
                  let downPct = vars["downPercent"],
                  let intPct = vars["interestRate"] else { return nil }
            let loan = price * (1 - downPct / 100)
            return loan * intPct / 100
        },
        "interestSaving": { vars in
            guard let int10 = vars["interest10"],
                  let int20 = vars["interest20"] else { return nil }
            return int10 - int20
        },
        "totalCostDifference": { vars in
            guard let downA = vars["downA"], let payA = vars["paymentA"], let termA = vars["termA"],
                  let downB = vars["downB"], let payB = vars["paymentB"], let termB = vars["termB"] else { return nil }
            let totalA = downA + payA * termA
            let totalB = downB + payB * termB
            return abs(totalA - totalB)
        },
        "carMaxPayment": { vars in
            guard let income = vars["monthlyIncome"] else { return nil }
            return income * 0.10
        },
        "carMaxPaymentFromAnnual": { vars in
            guard let annual = vars["annualSalary"] else { return nil }
            return annual / 12 * 0.10
        },
        "paymentVsBudget": { vars in
            guard let income = vars["monthlyIncome"],
                  let payment = vars["monthlyPayment"] else { return nil }
            return abs(income * 0.10 - payment)
        },
        "carMaxAffordable": { vars in
            guard let income = vars["monthlyIncome"] else { return nil }
            let maxPayment = income * 0.10
            let maxFinanced = maxPayment * 48
            return maxFinanced / 0.80
        },
        "carValueAfterDep": { vars in
            guard let price = vars["carPrice"],
                  let pct = vars["depPercent"] else { return nil }
            return price * (1 - pct / 100)
        },
        "carDepreciationAmount": { vars in
            guard let price = vars["carPrice"],
                  let pct = vars["depPercent"] else { return nil }
            return price * pct / 100
        },
        "carValueYear2": { vars in
            guard let price = vars["carPrice"],
                  let dep1 = vars["depYear1"],
                  let dep2 = vars["depYear2"] else { return nil }
            return price * (1 - dep1 / 100) * (1 - dep2 / 100)
        },
        "carTotalDepreciation": { vars in
            guard let price = vars["carPrice"],
                  let valueAfter = vars["valueAfter3"] else { return nil }
            return price - valueAfter
        },
        "depreciationDifference": { vars in
            guard let newPrice = vars["newPrice"], let newVal = vars["newValueY3"],
                  let usedPrice = vars["usedPrice"], let usedVal = vars["usedValueY3"] else { return nil }
            let newDep = newPrice - newVal
            let usedDep = usedPrice - usedVal
            return abs(newDep - usedDep)
        },

        // ── Student Loans & Education formulas ──────────────────────────────────

        "annualPayment": { vars in
            guard let monthly = vars["monthlyPayment"] else { return nil }
            return monthly * 12
        },
        "estimatedMonthly": { vars in
            guard let balance = vars["loanBalance"],
                  let per10k = vars["paymentPer10k"] else { return nil }
            return (balance / 10000) * per10k
        },
        "monthlyInterestCharge": { vars in
            guard let balance = vars["loanBalance"],
                  let rate = vars["interestRate"] else { return nil }
            return balance * rate / 100 / 12
        },
        "principalPayment": { vars in
            guard let payment = vars["monthlyPayment"],
                  let interest = vars["monthlyInterest"] else { return nil }
            return payment - interest
        },
        "loanTotalFromYears": { vars in
            guard let payment = vars["monthlyPayment"],
                  let years = vars["termYears"] else { return nil }
            return payment * years * 12
        },
        "totalInterestPaid": { vars in
            guard let total = vars["totalPaid"],
                  let loan = vars["loanAmount"] else { return nil }
            return total - loan
        },
        "termCostDifference": { vars in
            guard let pay10 = vars["payment10"],
                  let pay20 = vars["payment20"] else { return nil }
            return pay20 * 240 - pay10 * 120
        },
        "percentMoreCost": { vars in
            guard let standard = vars["totalStandard"],
                  let extended = vars["totalExtended"] else { return nil }
            return (extended - standard) / standard * 100
        },
        "extraPaymentSaving": { vars in
            guard let original = vars["originalTotal"],
                  let newTotal = vars["newTotal"] else { return nil }
            // Also works for refi: old total - new total
            if let old = vars["oldTotal"] { return old - newTotal }
            return original - newTotal
        },
        "annualSaving": { vars in
            guard let monthly = vars["monthlySaving"] else { return nil }
            return monthly * 12
        },
        "refiTotalSaving": { vars in
            guard let oldPay = vars["oldPayment"], let oldMonths = vars["remainingMonths"],
                  let newPay = vars["newPayment"], let newMonths = vars["newTermMonths"] else { return nil }
            return oldPay * oldMonths - newPay * newMonths
        },
        "newMonthlyInterest": { vars in
            guard let balance = vars["loanBalance"],
                  let rate = vars["newRate"] else { return nil }
            return balance * rate / 100 / 12
        },
        // NOTE: idrAnnualPayment / monthlyFromAnnual / idrMonthlyFromIncome /
        // annualPaymentDifference / idrVsStandardDifference were the formulas behind
        // the original 5 numerical IDR templates. The IDR lesson was reframed to a
        // concept lesson in 2026-05 because real-world IDR rules vary too much by
        // plan and are in flux post-SAVE litigation — a single canonical formula
        // was misleading. We keep these formula entries because:
        //   1. They're correct as a canonical baseline mental model
        //   2. Future numerical sub-lessons may revive them when policy stabilizes
        // No templates currently reference them.
        "idrAnnualPayment": { vars in
            guard let discretionary = vars["discretionaryIncome"],
                  let pct = vars["idrPercent"] else { return nil }
            return discretionary * pct / 100
        },
        "monthlyFromAnnual": { vars in
            guard let annual = vars["annualPayment"] else { return nil }
            return annual / 12
        },
        "idrMonthlyFromIncome": { vars in
            guard let income = vars["annualIncome"],
                  let poverty = vars["povertyLine"],
                  let pct = vars["idrPercent"] else { return nil }
            let discretionary = income - poverty * 1.5   // 150% poverty multiplier
            return discretionary * pct / 100 / 12
        },
        "annualPaymentDifference": { vars in
            guard let standard = vars["standardPayment"],
                  let idr = vars["idrPayment"] else { return nil }
            return (standard - idr) * 12
        },
        "idrVsStandardDifference": { vars in
            guard let standardTotal = vars["standardTotal"],
                  let idrTotal = vars["idrTotal"] else { return nil }
            return abs(standardTotal - idrTotal)
        },
        "pslfTotalPaid": { vars in
            guard let payment = vars["monthlyPayment"] ?? vars["idrPayment"] ?? vars["pslfPayment"] else { return nil }
            return payment * 120
        },
        "pslfForgiveness": { vars in
            guard let balance = vars["loanBalance"] else { return nil }
            let payment = vars["idrPayment"] ?? vars["monthlyPayment"]
            let totalPaid = vars["totalPaid"]
            if let p = payment {
                return balance - p * 120
            }
            if let t = totalPaid {
                return balance - t
            }
            return nil
        },
        "pslfSavings": { vars in
            guard let standardTotal = vars["standardTotal"],
                  let idr = vars["idrPayment"] else { return nil }
            return standardTotal - idr * 120
        },
        "refiVsPslfDifference": { vars in
            guard let refiPay = vars["refiPayment"],
                  let refiMonths = vars["refiMonths"],
                  let pslfPay = vars["pslfPayment"] else { return nil }
            return abs(refiPay * refiMonths - pslfPay * 120)
        },

        // MARK: - Smart Shopping: Coupon vs Cashback
        "couponSaving": { vars in
            guard let price = vars["price"], let pct = vars["couponPct"] else { return nil }
            return price * pct / 100
        },
        "cashbackAmount": { vars in
            guard let price = vars["price"], let pct = vars["cashbackPct"] else { return nil }
            return price * pct / 100
        },
        "couponPlusCashback": { vars in
            guard let price = vars["price"],
                  let cp = vars["couponPct"],
                  let cb = vars["cashbackPct"] else { return nil }
            let couponPart = price * cp / 100
            let afterCoupon = price - couponPart
            let cashbackPart = afterCoupon * cb / 100
            return couponPart + cashbackPart
        },
        "couponVsCashbackDiff": { vars in
            guard let price = vars["price"],
                  let cp = vars["couponPct"],
                  let cb = vars["cashbackPct"] else { return nil }
            return abs(price * cp / 100 - price * cb / 100)
        },
        "couponCashbackFinalPrice": { vars in
            guard let price = vars["price"],
                  let cp = vars["couponPct"],
                  let cb = vars["cashbackPct"] else { return nil }
            // Coupon first, cashback on the discounted price
            let salePrice = price * (1 - cp / 100)
            let cashback = salePrice * cb / 100
            return salePrice - cashback
        },

        // MARK: - Smart Shopping: Discount + Tax
        "salePricePlusTax": { vars in
            guard let price = vars["originalPrice"],
                  let disc = vars["discountPercent"],
                  let tax = vars["taxPercent"] else { return nil }
            return price * (1 - disc / 100) * (1 + tax / 100)
        },
        "taxOnSalePrice": { vars in
            guard let price = vars["originalPrice"],
                  let disc = vars["discountPercent"],
                  let tax = vars["taxPercent"] else { return nil }
            return price * (1 - disc / 100) * tax / 100
        },
        "stackedSalePricePlusTax": { vars in
            guard let price = vars["originalPrice"],
                  let first = vars["firstDiscount"],
                  let second = vars["secondDiscount"],
                  let tax = vars["taxPercent"] else { return nil }
            return price * (1 - first / 100) * (1 - second / 100) * (1 + tax / 100)
        },
        "discountTaxSaving": { vars in
            guard let price = vars["originalPrice"],
                  let disc = vars["discountPercent"],
                  let tax = vars["taxPercent"] else { return nil }
            // Full price with tax minus sale price with tax
            return price * (1 + tax / 100) - price * (1 - disc / 100) * (1 + tax / 100)
        },

        // MARK: - Smart Shopping: Membership Worth
        "membershipBreakeven": { vars in
            // Generic: works for monthly (monthlyFee) or annual (annualFee)
            let fee = vars["monthlyFee"] ?? vars["annualFee"]
            guard let f = fee, let saving = vars["savingPerUse"], saving > 0 else { return nil }
            return (f / saving).rounded(.up)
        },
        "membershipNetSavings": { vars in
            let fee = vars["monthlyFee"] ?? vars["annualFee"]
            guard let f = fee,
                  let saving = vars["savingPerUse"],
                  let uses = vars["usesPerPeriod"] else { return nil }
            return uses * saving - f
        },
        "membershipBreakevenDiff": { vars in
            guard let feeA = vars["feeA"], let saveA = vars["saveA"], saveA > 0,
                  let feeB = vars["feeB"], let saveB = vars["saveB"], saveB > 0 else { return nil }
            let breakA = (feeA / saveA).rounded(.up)
            let breakB = (feeB / saveB).rounded(.up)
            return abs(breakA - breakB)
        },

        // MARK: - Money Math: Subscription audit
        "sumThreeSubscriptions": { vars in
            guard let a = vars["sub1"], let b = vars["sub2"], let c = vars["sub3"] else { return nil }
            return a + b + c
        },
        "annualizedSubscriptions": { vars in
            guard let a = vars["sub1"], let b = vars["sub2"], let c = vars["sub3"] else { return nil }
            return (a + b + c) * 12
        },
        "annualSubscriptionSaving": { vars in
            guard let s = vars["subToCut"] else { return nil }
            return s * 12
        },

        // MARK: - Money Math: Sales tax with budget
        "preTaxMax": { vars in
            guard let budget = vars["budget"], let tax = vars["taxPercent"] else { return nil }
            return budget / (1 + tax / 100)
        },
        "asymmetryGap": { vars in
            guard let budget = vars["budget"], let tax = vars["taxPercent"] else { return nil }
            return budget / (1 + tax / 100) - budget * (1 - tax / 100)
        },

        // MARK: - Money Math: 50/30/20
        "percentOfIncome": { vars in
            guard let income = vars["income"], let pct = vars["pct"] else { return nil }
            return income * pct / 100
        },
        "needsOverCap": { vars in
            guard let income = vars["income"], let needs = vars["needs"] else { return nil }
            return needs - income * 0.5
        },
        "monthlyToReachGoal": { vars in
            guard let goal = vars["goal"], let months = vars["months"], months > 0 else { return nil }
            return goal / months
        },

        // MARK: - Money Math: Latte factor
        "dailyToAnnual": { vars in
            guard let daily = vars["dailyCost"] else { return nil }
            return daily * 365
        },
        "workdayToAnnual": { vars in
            guard let daily = vars["dailyCost"] else { return nil }
            return daily * 260
        },
        "dailyHabitSavingsAnnual": { vars in
            guard let current = vars["currentCost"], let alt = vars["alternativeCost"] else { return nil }
            return (current - alt) * 365
        },
        "dailyVsWorkdayCostDiff": { vars in
            guard let daily = vars["habitDailyCost"], let workday = vars["habitWorkdayCost"] else { return nil }
            return abs(daily * 365 - workday * 260)
        },
        "multipleHabitsAnnual": { vars in
            guard let coffee = vars["coffeeCost"],
                  let lunch = vars["lunchCost"],
                  let snack = vars["snackCost"] else { return nil }
            return (coffee + snack) * 365 + lunch * 260
        },

        // MARK: - Money Math: Weekly / monthly conversions
        "weeklyToMonthlyCorrect": { vars in
            guard let w = vars["weekly"] else { return nil }
            return w * 52 / 12
        },
        "biweeklyToMonthly": { vars in
            guard let b = vars["biweekly"] else { return nil }
            return b * 26 / 12
        },
        "monthlyToWeekly": { vars in
            guard let m = vars["monthly"] else { return nil }
            return m * 12 / 52
        },
        "wrongMultiplierShortfall": { vars in
            guard let w = vars["weekly"] else { return nil }
            // Right (52 weeks) − Wrong (4 × 12 = 48 weeks) = w × 4
            return w * 4
        },
        "biweeklyWrongMultiplierShortfall": { vars in
            guard let b = vars["biweekly"] else { return nil }
            // Right (× 26) − Wrong (× 2 × 12 = × 24) = b × 2
            return b * 2
        },

        // MARK: - Salary: Rework additions
        "afterTaxMonthlyRaise": { vars in
            guard let salary = vars["annualSalary"], let pct = vars["raisePercent"] else { return nil }
            return (salary * pct / 100) / 12 * 0.72
        },
        "totalWeeklyWithOT": { vars in
            guard let rate = vars["regularRate"], let total = vars["totalHours"] else { return nil }
            let regHours = min(total, 40.0)
            let otHours = max(0, total - 40)
            return regHours * rate + otHours * rate * 1.5
        },
        "weeklyMonthlyOfferDiff": { vars in
            guard let w = vars["weeklyPay"], let m = vars["monthlyPay"] else { return nil }
            return abs(w * 52 - m * 12)
        },

        // MARK: - Salary: Hourly to salary (reuses annualFromHourly, hourlyFromAnnual)
        "offerComparisonDiff": { vars in
            guard let h = vars["hourlyRate"], let s = vars["annualSalary"] else { return nil }
            return abs(h * 2000 - s)
        },

        // MARK: - Salary: Total compensation
        "totalCompensationNoBonus": { vars in
            guard let base = vars["baseSalary"],
                  let ins = vars["insuranceValue"],
                  let match = vars["matchAmount"] else { return nil }
            return base + ins + match
        },
        "totalCompDifference": { vars in
            guard let bA = vars["baseA"], let bnA = vars["benefitsA"],
                  let bB = vars["baseB"], let bnB = vars["benefitsB"] else { return nil }
            return abs((bA + bnA) - (bB + bnB))
        },
        "effectiveHourlyOfTotalComp": { vars in
            guard let tc = vars["totalComp"] else { return nil }
            return tc / 2000
        },
        "totalCompMinusBase": { vars in
            guard let tc = vars["totalComp"], let base = vars["baseSalary"] else { return nil }
            return tc - base
        },
        "benefitsAsPercent": { vars in
            guard let b = vars["benefitsValue"], let base = vars["baseSalary"], base > 0 else { return nil }
            return b / base * 100
        },

        // MARK: - Salary: Side hustle
        "effectiveHourlyRate": { vars in
            guard let earnings = vars["earnings"], let exp = vars["expenses"],
                  let hours = vars["hours"], hours > 0 else { return nil }
            return (earnings - exp) / hours
        },
        "simpleHourlyRate": { vars in
            guard let earnings = vars["earnings"], let hours = vars["hours"], hours > 0 else { return nil }
            return earnings / hours
        },
        "sideVsDayJobGap": { vars in
            guard let s = vars["sideHourly"], let d = vars["dayHourly"] else { return nil }
            return d - s
        },
        "sideHustlePercentOfDayJob": { vars in
            guard let s = vars["sideHourly"], let sal = vars["annualSalary"], sal > 0 else { return nil }
            let dayHourly = sal / 2000
            return s / dayHourly * 100
        },
        "sideHustleAnnualNet": { vars in
            guard let w = vars["weeklyEarnings"] else { return nil }
            return w * 50
        },

        // MARK: - Debt: Balance transfer math (Phase 2 Batch 2c)
        // Fee charged by the new card to accept the transfer (typically 3-5% of balance).
        "balanceTransferFee": { vars in
            guard let balance = vars["balance"],
                  let feePct = vars["feePct"] else { return nil }
            return balance * feePct / 100
        },
        // Interest you would have paid on the OLD card during the 0% promo window.
        "interestSavedDuringPromo": { vars in
            guard let balance = vars["balance"],
                  let oldApr = vars["oldApr"],
                  let promoMonths = vars["promoMonths"] else { return nil }
            return balance * oldApr / 100 * promoMonths / 12
        },
        // Net benefit of the transfer = interest saved during promo − transfer fee.
        // Negative = the fee outweighs the savings.
        "balanceTransferNetWin": { vars in
            guard let balance = vars["balance"],
                  let oldApr = vars["oldApr"],
                  let promoMonths = vars["promoMonths"],
                  let feePct = vars["feePct"] else { return nil }
            let interestSaved = balance * oldApr / 100 * promoMonths / 12
            let fee = balance * feePct / 100
            return interestSaved - fee
        },
        // Monthly payment required to fully pay off (balance + transfer fee) before promo ends.
        "balanceTransferRequiredMonthly": { vars in
            guard let balance = vars["balance"],
                  let promoMonths = vars["promoMonths"], promoMonths > 0,
                  let feePct = vars["feePct"] else { return nil }
            return balance * (1 + feePct / 100) / promoMonths
        },

        // MARK: - Debt: CC payoff time (Phase 2 Batch 2c)
        // Months to pay off a balance at fixed monthly payment given APR.
        // Exact: months = ln(p / (p − b·r)) / ln(1+r) where r = APR/1200.
        // For mental-math template use, we compute exact months and round.
        "payoffMonths": { vars in
            guard let balance = vars["balance"],
                  let apr = vars["apr"],
                  let payment = vars["monthlyPayment"] else { return nil }
            let r = apr / 1200
            let monthlyInterest = balance * r
            // If payment doesn't even cover monthly interest, payoff is impossible — return a big number
            guard payment > monthlyInterest else { return 9999 }
            // months = ln(payment / (payment − balance*r)) / ln(1 + r)
            let months = log(payment / (payment - balance * r)) / log(1 + r)
            return months.rounded()
        },
        // Net principal reduction per month after interest is taken out
        "principalAfterInterest": { vars in
            guard let balance = vars["balance"],
                  let apr = vars["apr"],
                  let payment = vars["monthlyPayment"] else { return nil }
            let monthlyInterest = balance * apr / 1200
            return payment - monthlyInterest
        },

        // MARK: - Salary: 401(k) paycheck impact (Phase 2 Batch 2c)
        // A pre-tax 401(k) contribution reduces taxable income but not FICA wages,
        // so the actual take-home reduction is contribution × (1 − marginal income tax rate).
        // Example: $300 contribution at 22% bracket → $234 net paycheck cost ($300 − $66 tax saved).
        "pretaxNetCost": { vars in
            guard let contribution = vars["contribution"],
                  let rate = vars["marginalRate"] else { return nil }
            return contribution * (1 - rate / 100)
        },
        "pretaxTaxSaved": { vars in
            guard let contribution = vars["contribution"],
                  let rate = vars["marginalRate"] else { return nil }
            return contribution * rate / 100
        },

        // MARK: - Investing reworks
        "roiPercentDiff": { vars in
            guard let costA = vars["costA"], let gainA = vars["gainA"], costA > 0,
                  let costB = vars["costB"], let gainB = vars["gainB"], costB > 0 else { return nil }
            return abs(gainA / costA * 100 - gainB / costB * 100)
        },
        "rothGrowthTaxSaved": { vars in
            guard let value = vars["finalValue"], let rate = vars["taxRate"] else { return nil }
            return value * rate / 100
        },
        "compoundPctInterest": { vars in
            guard let final = vars["finalValue"], let contributed = vars["totalContributed"], final > 0 else { return nil }
            return (final - contributed) / final * 100
        },
        "compoundDifference": { vars in
            guard let a = vars["finalA"], let b = vars["finalB"] else { return nil }
            return abs(a - b)
        },
        "compoundBackwardsFromGoal": { vars in
            guard let goal = vars["goal"], let multiplier = vars["multiplier"], multiplier > 0 else { return nil }
            return goal / multiplier
        },

        // MARK: - Investing: Dollar-Cost Averaging
        "dcaTotalInvested": { vars in
            guard let amt = vars["monthlyAmount"], let m = vars["months"] else { return nil }
            return amt * m
        },
        "sharesBought": { vars in
            guard let amt = vars["investmentAmount"], let price = vars["pricePerShare"], price > 0 else { return nil }
            return (amt / price).rounded(.down)
        },
        "dcaAverageCost": { vars in
            guard let total = vars["totalInvested"], let shares = vars["totalShares"], shares > 0 else { return nil }
            return total / shares
        },
        "dcaVsLumpSumSaving": { vars in
            guard let dca = vars["dcaCost"], let lump = vars["lumpCost"], let shares = vars["shares"] else { return nil }
            return (lump - dca) * shares
        },
        "monthlyOverYears": { vars in
            guard let amt = vars["monthlyAmount"], let yrs = vars["years"] else { return nil }
            return amt * 12 * yrs
        },

        // MARK: - Investing: Fund fees
        "annualFundFee": { vars in
            guard let pv = vars["portfolioValue"], let er = vars["expenseRatio"] else { return nil }
            return pv * er / 100
        },
        "feeDifferenceAnnual": { vars in
            guard let pv = vars["portfolioValue"],
                  let ra = vars["expenseRatioA"],
                  let rb = vars["expenseRatioB"] else { return nil }
            return pv * (ra - rb) / 100
        },
        "feeCostOverYears": { vars in
            guard let pv = vars["portfolioValue"],
                  let ra = vars["expenseRatioA"],
                  let rb = vars["expenseRatioB"] else { return nil }
            return pv * (ra - rb) / 100 * 10
        },
        "feeImpact30yr": { vars in
            guard let proj = vars["projectedBalance"], let ef = vars["extraFee"] else { return nil }
            // Rule of thumb: every 0.5% extra fee costs ~10% of final balance over 30 yrs
            return proj * ef / 100 * 20
        },

        // MARK: - Investing: Emergency fund
        "essentialsMonthlyFour": { vars in
            guard let r = vars["rent"], let f = vars["food"],
                  let i = vars["insurance"], let t = vars["transport"] else { return nil }
            return r + f + i + t
        },
        "emergencyFundSixMonths": { vars in
            guard let e = vars["essentials"] else { return nil }
            return e * 6
        },
        "monthsOfRunway": { vars in
            guard let s = vars["savings"], let e = vars["essentials"], e > 0 else { return nil }
            return (s / e).rounded(.down)
        },
        "runwayGainFromCuts": { vars in
            guard let s = vars["savings"], let e = vars["essentials"],
                  let cut = vars["cutAmount"], e > cut else { return nil }
            let original = (s / e).rounded(.down)
            let after = (s / (e - cut)).rounded(.down)
            return after - original
        },
        "monthsToReachEFTarget": { vars in
            guard let target = vars["target"], let current = vars["currentSaved"],
                  let monthly = vars["monthlyContribution"], monthly > 0 else { return nil }
            return ((target - current) / monthly).rounded(.up)
        },

        // MARK: - Investing: Rental yield
        "grossRentalYield": { vars in
            guard let rent = vars["monthlyRent"], let price = vars["propertyPrice"], price > 0 else { return nil }
            return (rent * 12) / price * 100
        },
        "annualFromMonthlyRent": { vars in
            guard let rent = vars["monthlyRent"] else { return nil }
            return rent * 12
        },
        "yieldComparison": { vars in
            guard let pA = vars["priceA"], let rA = vars["rentA"], pA > 0,
                  let pB = vars["priceB"], let rB = vars["rentB"], pB > 0 else { return nil }
            return abs((rA * 12 / pA) - (rB * 12 / pB)) * 100
        },
        "netRentalYield": { vars in
            guard let rent = vars["monthlyRent"], let price = vars["propertyPrice"], price > 0 else { return nil }
            return (rent * 12 * 0.82) / price * 100  // 10% mgmt + 8% vacancy
        },
        "requiredRentForYield": { vars in
            guard let price = vars["propertyPrice"], let yield = vars["targetYield"] else { return nil }
            return price * yield / 100 / 12
        },

        // MARK: - Investing: On Track (Am I saving enough?)
        "savingsMultiple": { vars in
            guard let s = vars["currentSavings"], let sal = vars["currentSalary"], sal > 0 else { return nil }
            return s / sal * 100  // expressed as percent (e.g., 123% = 1.23x)
        },
        "savingsTargetByMultiple": { vars in
            guard let sal = vars["currentSalary"], let m = vars["targetMultiple"] else { return nil }
            return sal * m
        },
        "gapToSavingsTarget": { vars in
            guard let sal = vars["currentSalary"], let m = vars["targetMultiple"],
                  let saved = vars["currentSavings"] else { return nil }
            return max(0, sal * m - saved)
        },
        "monthlyToCloseGap": { vars in
            guard let gap = vars["gap"], let yrs = vars["years"], yrs > 0 else { return nil }
            return gap / (yrs * 12)
        },
        "extraMonthlyFromRateBump": { vars in
            guard let sal = vars["currentSalary"], let cur = vars["currentRate"], let tgt = vars["targetRate"] else { return nil }
            return (tgt - cur) * sal / 100 / 12
        },

        // MARK: - Debt reworks
        "interestTaxPercent": { vars in
            guard let loan = vars["loanAmount"], let pay = vars["monthlyPayment"], let m = vars["numMonths"], loan > 0 else { return nil }
            let totalInterest = pay * m - loan
            return totalInterest / loan * 100
        },
        "saveVsBorrowDiff": { vars in
            guard let pay = vars["monthlyPayment"], let months = vars["numMonths"],
                  let cash = vars["purchasePrice"] else { return nil }
            return pay * months - cash
        },
        "newDTIwithPayment": { vars in
            guard let income = vars["monthlyIncome"], let cur = vars["currentDebt"],
                  let np = vars["newPayment"], income > 0 else { return nil }
            return (cur + np) / income * 100
        },
        "principalReductionWithExtra": { vars in
            guard let bal = vars["balance"], let apr = vars["apr"],
                  let total = vars["totalPayment"] else { return nil }
            let interest = bal * apr / 100 / 12
            return total - interest
        },

        // MARK: - Debt: Avalanche vs Snowball
        "aprDifference": { vars in
            guard let a = vars["aprA"], let b = vars["aprB"] else { return nil }
            return abs(a - b)
        },
        "monthlyInterestSavedByPriority": { vars in
            guard let extra = vars["extraPayment"], let high = vars["highRate"], let low = vars["lowRate"] else { return nil }
            return extra * (high - low) / 100 / 12
        },
        "avalancheVsSnowballSaving": { vars in
            guard let extra = vars["extraPayment"], let aprA = vars["aprA"], let aprB = vars["aprB"] else { return nil }
            return extra * (aprA - aprB) / 100
        },
        "psychologyPremium24mo": { vars in
            guard let m = vars["monthlySaving"] else { return nil }
            return m * 24
        },

        // MARK: - Debt: APR vs APY
        "apyFromApr": { vars in
            guard let apr = vars["apr"] else { return nil }
            return (pow(1 + apr / 100 / 12, 12) - 1) * 100
        },
        "monthlyRatePctFromApr": { vars in
            guard let apr = vars["apr"] else { return nil }
            return apr / 12
        },
        "trueCardRateDiff": { vars in
            guard let aprX = vars["aprX"], let apyY = vars["apyY"] else { return nil }
            let apyX = (pow(1 + aprX / 100 / 12, 12) - 1) * 100
            return abs(apyX - apyY)
        },
        "annualInterestViaApy": { vars in
            // Templates pass APY directly (it's the rate the user sees on a HYSA tile).
            // Annual interest = balance × APY% — same one-step "percent of" the
            // user learns in the lesson shortcut.
            guard let bal = vars["balance"], let apy = vars["apy"] else { return nil }
            return bal * apy / 100
        },

        // MARK: - Debt: BNPL
        "bnplTotal": { vars in
            guard let n = vars["numPayments"], let amt = vars["paymentAmount"] else { return nil }
            return n * amt
        },
        "bnplWithOneLateFee": { vars in
            guard let amt = vars["paymentAmount"] else { return nil }
            return 4 * amt + 35  // 4 payments + standard $35 late fee
        },
        "bnplSurchargePercent": { vars in
            guard let orig = vars["originalPrice"], orig > 0 else { return nil }
            if let paid = vars["totalPaid"] {
                return (paid - orig) / orig * 100
            }
            // No totalPaid supplied — assume one missed payment with $35 late fee
            return 35 / orig * 100
        },
        "bnplStackedMonthly": { vars in
            guard let a = vars["paymentA"], let b = vars["paymentB"], let c = vars["paymentC"] else { return nil }
            return a + b + c
        },
        "bnplAnnual": { vars in
            guard let m = vars["monthlyBnpl"] else { return nil }
            return m * 12
        },

        // MARK: - Housing reworks
        "minIncomeForRent": { vars in
            guard let rent = vars["monthlyRent"] else { return nil }
            return rent / 0.28
        },
        "rentAboveAvgImpact": { vars in
            guard let rent = vars["currentRent"], let inc = vars["increasePercent"] else { return nil }
            return rent * (inc - 4) / 100
        },
        "monthsToRecoupMoving": { vars in
            guard let cost = vars["movingCost"], let inc = vars["monthlyIncrease"], inc > 0 else { return nil }
            return (cost / inc).rounded()
        },
        "mortgageRateFactor": { vars in
            guard let loan = vars["loanAmount"], let f = vars["factor"] else { return nil }
            return loan * f
        },
        "mortgageRateDiff": { vars in
            guard let loan = vars["loanAmount"] else { return nil }
            return loan * 0.0013  // 0.0067 - 0.0054
        },
        "mortgageWithTaxAndInsurance": { vars in
            guard let loan = vars["loanAmount"], let f = vars["factor"],
                  let ti = vars["taxAndInsurance"] else { return nil }
            return loan * f + ti
        },
        "mortgageVsRentMonthlyDiff": { vars in
            guard let rent = vars["monthlyRent"], let loan = vars["loanAmount"],
                  let f = vars["factor"], let ti = vars["taxAndInsurance"] else { return nil }
            return abs(rent - (loan * f + ti))
        },

        // MARK: - Housing: Affordability (Phase 2 Batch 2c)
        // The 28% rule applied to GROSS monthly income gives the max PITI you can afford.
        "maxPitiFromGross": { vars in
            guard let monthlyGross = vars["monthlyGross"] else { return nil }
            return monthlyGross * 0.28
        },
        // Loan amount you can support given monthly P&I and a rate factor (e.g. 0.006 at 6%/30yr).
        "loanFromPAndI": { vars in
            guard let pAndI = vars["pAndI"], let f = vars["factor"], f > 0 else { return nil }
            return pAndI / f
        },
        // Monthly PMI = loan × annual PMI% / 12. PMI typically 0.3-1.5% annual on conventional loans <20% down.
        "monthlyPMI": { vars in
            guard let loan = vars["loanAmount"], let pmiPct = vars["pmiPct"] else { return nil }
            return loan * pmiPct / 1200
        },
        // Reverse: minimum gross monthly income needed to afford a given home, using 28% rule.
        // Assumes provided rateFactor + tax/ins as % of price.
        "minIncomeForPrice": { vars in
            guard let price = vars["purchasePrice"],
                  let downPct = vars["downPct"],
                  let f = vars["factor"] else { return nil }
            let loan = price * (1 - downPct / 100)
            let pAndI = loan * f
            // Assume ~1.5% annual tax + ins (per price). Could parameterize later.
            let monthlyTaxIns = price * 0.015 / 12
            let piti = pAndI + monthlyTaxIns
            return piti / 0.28
        },

        // MARK: - Housing: Roommate
        "halfOfRent": { vars in
            guard let r = vars["sharedRent"] else { return nil }
            return r / 2
        },
        "roommateSavingWithUtilities": { vars in
            guard let sr = vars["soloRent"], let su = vars["soloUtilities"],
                  let shr = vars["sharedRent"], let shu = vars["sharedUtilities"] else { return nil }
            return (sr + su) - (shr + shu) / 2
        },
        "smallerShareRent": { vars in
            guard let r = vars["sharedRent"], let big = vars["bigShare"] else { return nil }
            return r * (100 - big) / 100
        },
        "monthlyToAnnualSimple": { vars in
            guard let m = vars["monthlySaving"] else { return nil }
            return m * 12
        },
        "roommateAnnualSaving": { vars in
            guard let solo = vars["soloRent"], let shared = vars["sharedRent"] else { return nil }
            return (solo - shared / 2) * 12
        },

        // MARK: - Housing: True cost
        "trueHousingCost": { vars in
            guard let r = vars["rent"], let u = vars["utilities"],
                  let i = vars["insurance"], let p = vars["parking"] else { return nil }
            return r + u + i + p
        },
        "housingExtraBeyondRent": { vars in
            guard let tc = vars["trueCost"], let r = vars["rent"] else { return nil }
            return tc - r
        },
        "trueHousingDiff": { vars in
            guard let rA = vars["rentA"], let aA = vars["addonsA"],
                  let rB = vars["rentB"], let aB = vars["addonsB"] else { return nil }
            return abs((rA + aA) - (rB + aB))
        },
        "trueCostExtraPct": { vars in
            guard let r = vars["rent"], let tc = vars["trueCost"], r > 0 else { return nil }
            return (tc - r) / r * 100
        },
        "housingPctOfIncome": { vars in
            guard let income = vars["monthlyIncome"], let tc = vars["trueCost"], income > 0 else { return nil }
            return tc / income * 100
        },

        // MARK: - Housing: Lease break
        "leaseBreakFeeOnly": { vars in
            guard let m = vars["monthsPenalty"], let r = vars["monthlyRent"] else { return nil }
            return m * r
        },
        "leaseBreakTotalCost": { vars in
            guard let m = vars["monthsPenalty"], let r = vars["monthlyRent"], let mc = vars["movingCost"] else { return nil }
            return m * r + mc
        },
        "leaseBreakeven": { vars in
            guard let total = vars["totalBreakCost"], let saving = vars["monthlySaving"], saving > 0 else { return nil }
            return (total / saving).rounded(.up)
        },
        "leaseStaySavings": { vars in
            guard let ml = vars["monthsLeft"], let tc = vars["totalBreakCost"], let s = vars["monthlySaving"] else { return nil }
            // Money saved by staying = break cost − (savings from cheaper place over remaining months)
            return tc - ml * s
        },
        "leaseBreakNetCost": { vars in
            guard let ml = vars["monthsLeft"],
                  let cr = vars["currentRent"], let nr = vars["newRent"],
                  let bf = vars["breakFee"], let mc = vars["movingCost"] else { return nil }
            return (bf + mc) - ml * (cr - nr)
        },

        // MARK: - Taxes reworks
        "refundMonthlyLoan": { vars in
            guard let r = vars["refundAmount"] else { return nil }
            return r / 12
        },
        "refundInvestedGain": { vars in
            guard let r = vars["refundAmount"] else { return nil }
            return r * 0.03  // ~3% gain from half-year average return
        },
        "annualOverWithholding": { vars in
            guard let w = vars["monthlyWithheld"], let o = vars["monthlyOwed"] else { return nil }
            return (w - o) * 12
        },
        "quarterlyEstimatedTax": { vars in
            // SE tax applies to 92.35% of earnings; income tax applies to all.
            guard let income = vars["quarterlyIncome"], let inc = vars["incomeTaxPct"] else { return nil }
            return income * 0.9235 * 0.153 + income * inc / 100
        },

        // MARK: - Taxes: Standard vs Itemized
        "itemizedTotal": { vars in
            guard let m = vars["mortgageInt"], let s = vars["stateTax"], let c = vars["charity"] else { return nil }
            return m + s + c
        },
        "itemizedExcess": { vars in
            guard let i = vars["itemizedAmount"], let s = vars["standardAmount"] else { return nil }
            return i - s
        },
        "itemizedSavingDollars": { vars in
            guard let e = vars["excessAmount"], let r = vars["taxRate"] else { return nil }
            return e * r / 100
        },
        "itemizedDecisionSaving": { vars in
            guard let m = vars["mortgageInt"], let s = vars["stateTax"], let c = vars["charity"],
                  let r = vars["taxRate"] else { return nil }
            let itemized = m + s + c
            let excess = max(0, itemized - 15750)
            return excess * r / 100
        },
        "itemizedLifetime": { vars in
            guard let a = vars["annualSaving"], let y = vars["years"] else { return nil }
            return a * y
        },

        // MARK: - Taxes: Capital gains
        "shortTermCapGainsTax": { vars in
            guard let g = vars["gain"], let r = vars["ordinaryRate"] else { return nil }
            return g * r / 100
        },
        "longTermCapGainsTax": { vars in
            guard let g = vars["gain"], let r = vars["ltcgRate"] else { return nil }
            return g * r / 100
        },
        "capGainsTimingSaving": { vars in
            guard let g = vars["gain"], let o = vars["ordinaryRate"], let l = vars["ltcgRate"] else { return nil }
            return g * (o - l) / 100
        },
        "capGainsTaxDifference": { vars in
            guard let gA = vars["gainA"], let o = vars["ordinaryRate"],
                  let gB = vars["gainB"], let l = vars["ltcgRate"] else { return nil }
            return abs(gA * o / 100 - gB * l / 100)
        },

        // MARK: - Taxes: W-4 Adjust
        "w4MonthlyBump": { vars in
            guard let r = vars["refundAmount"] else { return nil }
            return r / 12
        },
        "w4BiweeklyBump": { vars in
            guard let r = vars["refundAmount"] else { return nil }
            return r / 26
        },
        "w4AnnualInvested": { vars in
            guard let b = vars["biweeklyBump"] else { return nil }
            return b * 26 * 1.03
        },
        "w4RefundGain": { vars in
            guard let r = vars["refundAmount"] else { return nil }
            return r * 0.03
        },
        "w4LifetimeGain": { vars in
            guard let r = vars["refundAmount"], let y = vars["years"] else { return nil }
            return r * 0.03 * y
        },

        // MARK: - Insurance reworks
        "insuranceExposureRange": { vars in
            guard let d = vars["deductible"] else { return nil }
            return d  // range = deductible
        },
        "erVisitCost": { vars in
            guard let total = vars["totalBill"], let ded = vars["deductible"],
                  let paid = vars["deductibleSoFar"], let coins = vars["coinsurancePercent"] else { return nil }
            let remainingDed = max(0, ded - paid)
            let postDed = max(0, total - ded)
            return remainingDed + postDed * coins / 100
        },
        "copayVsCoinsuranceDiff": { vars in
            guard let cost = vars["visitCost"], let copay = vars["copayAmount"], let coins = vars["coinsurancePercent"] else { return nil }
            let coinAmt = cost * coins / 100
            return abs(copay - coinAmt)
        },
        "hdhpPpoVisitsBreakeven": { vars in
            guard let hdhpP = vars["hdhpPremium"], let hdhpV = vars["hdhpVisitCost"],
                  let ppoP = vars["ppoPremium"], let ppoC = vars["ppoCopay"] else { return nil }
            let annualSaving = (ppoP - hdhpP) * 12
            let perVisitGap = hdhpV - ppoC
            guard perVisitGap > 0 else { return nil }
            return (annualSaving / perVisitGap).rounded(.up)
        },
        "hsaRetirementTaxSaved": { vars in
            guard let med = vars["medicalAmount"], let rate = vars["taxRate"] else { return nil }
            return med * rate / 100
        },

        // MARK: - Insurance FSA
        "fsaTaxSavings": { vars in
            guard let e = vars["fsaElection"], let r = vars["taxRate"] else { return nil }
            return e * r / 100
        },
        "fsaNetResult": { vars in
            guard let e = vars["fsaElection"], let r = vars["taxRate"], let s = vars["actualSpent"] else { return nil }
            return e * r / 100 - (e - s)
        },
        "fsaBreakevenSpend": { vars in
            guard let e = vars["fsaElection"], let r = vars["taxRate"] else { return nil }
            return e * (1 - r / 100)
        },
        "fsaElectionDiffSaving": { vars in
            guard let a = vars["electionA"], let b = vars["electionB"], let r = vars["taxRate"] else { return nil }
            return abs(a - b) * r / 100
        },
        "fsaMaxAdditional": { vars in
            guard let s = vars["guaranteedSpend"], let r = vars["taxRate"], r < 100 else { return nil }
            return s * (r / (100 - r))
        },

        // MARK: - Insurance Life
        "lifeBaseline10x": { vars in
            guard let s = vars["annualSalary"] else { return nil }
            return s * 10
        },
        "lifeAdjustedCoverage": { vars in
            guard let s = vars["annualSalary"], let m = vars["mortgageBalance"], let sv = vars["savings"] else { return nil }
            return s * 10 + m - sv
        },
        "lifeAnnualDiff": { vars in
            guard let pA = vars["premiumA"], let pB = vars["premiumB"] else { return nil }
            return (pB - pA) * 12
        },
        "lifeCostPer100k": { vars in
            guard let c = vars["coverage"], let p = vars["premium"], c > 0 else { return nil }
            return (p * 12) / (c / 100000)
        },
        "lifeLifetimeCost": { vars in
            guard let p = vars["monthlyPremium"] else { return nil }
            return p * 360
        },

        // MARK: - Insurance Prescription
        "rxAnnualSaving": { vars in
            guard let b = vars["brandCopay"], let g = vars["genericCopay"] else { return nil }
            return (b - g) * 12
        },
        "rxMultipleSaving": { vars in
            guard let c1 = vars["copay1"], let g1 = vars["generic1"],
                  let c2 = vars["copay2"], let g2 = vars["generic2"] else { return nil }
            return ((c1 - g1) + (c2 - g2)) * 12
        },
        "rxGoodrxSaving": { vars in
            guard let b = vars["brandCopay"], let g = vars["goodrxPrice"] else { return nil }
            return (b - g) * 12
        },
        "rxMonthlyDiff": { vars in
            guard let b = vars["brandCopay"], let g = vars["genericCopay"] else { return nil }
            return b - g
        },
        "rxLifetimeSaving": { vars in
            guard let m = vars["monthlyDiff"], let y = vars["years"] else { return nil }
            return m * 12 * y
        },

        // MARK: - Car reworks
        "carTermExtraCost": { vars in
            guard let p48 = vars["payment48"], let p72 = vars["payment72"] else { return nil }
            return p72 * 72 - p48 * 48
        },
        "interestSavingFromDownPayment": { vars in
            guard let i = vars["totalInterest"], let li = vars["lowerInterest"] else { return nil }
            return i - li
        },
        "carTotalCost3yr": { vars in
            guard let p = vars["carPrice"], let dep = vars["depPercent"], let ops = vars["monthlyOps"] else { return nil }
            return p * dep / 100 + ops * 36
        },

        // MARK: - Car TCO
        "carMonthlyOwnership": { vars in
            guard let p = vars["payment"], let i = vars["insurance"],
                  let g = vars["gas"], let m = vars["maintenance"] else { return nil }
            return p + i + g + m
        },
        "tcoMonthlyDifference": { vars in
            guard let pA = vars["paymentA"], let oA = vars["opsA"],
                  let pB = vars["paymentB"], let oB = vars["opsB"] else { return nil }
            return abs((pA + oA) - (pB + oB))
        },
        "keepVsBuyDiff": { vars in
            guard let mk = vars["maintenanceKeep"], let ik = vars["insuranceKeep"], let gk = vars["gasKeep"],
                  let pn = vars["paymentNew"], let on = vars["opsNew"] else { return nil }
            return (pn + on) - (mk + ik + gk)
        },
        "carPctOfIncome": { vars in
            guard let inc = vars["monthlyIncome"], let tco = vars["tcoMonthly"], inc > 0 else { return nil }
            return tco / inc * 100
        },
        "tcoAnnual": { vars in
            guard let m = vars["tcoMonthly"] else { return nil }
            return m * 12
        },

        // MARK: - Car Lease vs Buy
        "leaseTotalSpent": { vars in
            guard let m = vars["monthlyLease"], let mo = vars["months"] else { return nil }
            return m * mo
        },
        "buyNetCost": { vars in
            guard let p = vars["monthlyPayment"], let m = vars["months"], let r = vars["residualValue"] else { return nil }
            return p * m - r
        },
        "leaseVsBuy3yrDiff": { vars in
            guard let l = vars["monthlyLease"], let p = vars["monthlyPayment"], let r = vars["residualValue"] else { return nil }
            let leaseCost = l * 36
            let buyNet = p * 36 - r
            return abs(leaseCost - buyNet)
        },
        "leaseMonthlyFromTotal": { vars in
            guard let t = vars["leaseTotal"] else { return nil }
            return t / 36
        },
        "leaseVsBuyLifetime": { vars in
            guard let l = vars["leasePerCar"], let p = vars["carPrice"] else { return nil }
            let leaseLifetime = l * 3.33  // ~3.33 cars over 10 years
            return abs(leaseLifetime - p)
        },

        // MARK: - Car Trade-in
        "tradeInPremium": { vars in
            guard let t = vars["tradeInOffer"], let p = vars["privatePrice"] else { return nil }
            return p - t
        },
        "tradeInHourlyValue": { vars in
            guard let pr = vars["premium"], let h = vars["hours"], h > 0 else { return nil }
            return pr / h
        },
        "tradeInTaxBenefit": { vars in
            guard let t = vars["tradeInOffer"], let r = vars["taxRate"] else { return nil }
            return t * r / 100
        },
        "tradeInAdjustedPremium": { vars in
            guard let p = vars["privatePrice"], let t = vars["tradeInOffer"], let ts = vars["taxSaving"] else { return nil }
            return (p - t) - ts
        },
        "tradeInHourlyAdjusted": { vars in
            guard let p = vars["privatePrice"], let t = vars["tradeInOffer"],
                  let ts = vars["taxSaving"], let h = vars["hours"], h > 0 else { return nil }
            return ((p - t) - ts) / h
        },

        // MARK: - Student Loan rule of thumb
        "slRuleOfThumb110": { vars in
            guard let b = vars["loanBalance"] else { return nil }
            return b / 10000 * 110
        },
        "slCustomPer10k": { vars in
            guard let b = vars["loanBalance"], let r = vars["paymentPer10k"] else { return nil }
            return b / 10000 * r
        },
        "slPaymentRange": { vars in
            guard let b = vars["loanBalance"] else { return nil }
            return b / 10000 * 20  // $120 - $100
        },
        "slEstByApr": { vars in
            guard let b = vars["loanBalance"], let apr = vars["apr"] else { return nil }
            let factor: Double = apr <= 5 ? 105 : 115
            return b / 10000 * factor
        },
        "slInterestPercent": { vars in
            guard let loan = vars["loanAmount"], let paid = vars["totalPaid"], loan > 0 else { return nil }
            return (paid - loan) / loan * 100
        },
        "refiVsPslfDiff120": { vars in
            guard let refi = vars["refiPayment"], let pslf = vars["pslfPayment"] else { return nil }
            return (refi - pslf) * 120
        },

        // MARK: - SL Employer Benefit
        "annualToMonthlySimple": { vars in
            guard let a = vars["annualBenefit"] else { return nil }
            return a / 12
        },
        "employerBenefitMultiYear": { vars in
            guard let a = vars["annualBenefit"], let y = vars["years"] else { return nil }
            return a * y
        },
        "employerInterestSaving": { vars in
            guard let a = vars["annualBenefit"], let y = vars["years"], let r = vars["interestRate"] else { return nil }
            return a * y * r / 100 * 0.5  // rough: half the years of avoided interest
        },
        "employerBenefitGrossUp": { vars in
            guard let a = vars["annualBenefit"], let r = vars["taxRate"], r < 100 else { return nil }
            return a / (1 - r / 100)
        },
        "employerBenefitLifetimeValue": { vars in
            guard let a = vars["annualBenefit"], let y = vars["years"], let r = vars["taxRate"], r < 100 else { return nil }
            return (a / (1 - r / 100)) * y
        },

        // MARK: - SL Grace Period
        "dailyInterest": { vars in
            guard let b = vars["balance"], let r = vars["interestRate"] else { return nil }
            return b * r / 100 / 365
        },
        "gracePeriodTotal": { vars in
            guard let d = vars["dailyAmount"] else { return nil }
            return d * 180
        },
        "gracePeriodFullSaving": { vars in
            guard let a = vars["accruedAmount"] else { return nil }
            return a * 1.05  // capitalized + ~5% future interest on it
        },
        "balanceAfterGrace": { vars in
            guard let b = vars["originalBalance"], let r = vars["interestRate"] else { return nil }
            return b + b * r / 100 * 0.5  // half year of interest
        },
        "gracePeriodLifetimeImpact": { vars in
            guard let a = vars["accruedAmount"], let r = vars["interestRate"] else { return nil }
            return a * r / 100 * 5  // 5 years average
        },

        // MARK: - SL Parent PLUS
        "plusVsPrivateAnnualInterest": { vars in
            guard let b = vars["loanBalance"], let p = vars["plusRate"], let pr = vars["privateRate"] else { return nil }
            return b * (p - pr) / 100
        },
        "plusVsPrivate10yr": { vars in
            guard let b = vars["loanBalance"], let p = vars["plusRate"], let pr = vars["privateRate"] else { return nil }
            return b * (p - pr) / 100 * 10
        },
        "plusOriginationFee": { vars in
            guard let b = vars["loanBalance"] else { return nil }
            return b * 4.228 / 100
        },
        "plusVsPrivateTotalWithOrigination": { vars in
            guard let b = vars["loanBalance"], let pr = vars["privateRate"] else { return nil }
            // 8.94% = Parent PLUS fixed rate, 2025-26 academic year (loans disbursed
            // July 1, 2025 – June 30, 2026). 4.228% = origination fee, stable.
            return b * (8.94 - pr) / 100 * 10 + b * 4.228 / 100
        },
        "plusVsPrivateMonthlyInterest": { vars in
            guard let b = vars["loanBalance"], let pr = vars["privateRate"] else { return nil }
            // 8.94% = Parent PLUS fixed rate, 2025-26 academic year.
            return b * (8.94 - pr) / 100 / 12
        },
    ]

    /// Distinguishes the two failure modes when looking up and running a formula
    /// from the registry. A missing key is a developer error (typo in JSON);
    /// a nil return from a registered formula is a data error (template variable
    /// names don't match what the formula expects).
    enum FormulaResult: Equatable {
        case ok(Double)
        case formulaNotRegistered
        case formulaReturnedNil
    }

    static func compute(formula: String, variables: [String: Double]) -> FormulaResult {
        guard let fn = formulas[formula] else { return .formulaNotRegistered }
        guard let value = fn(variables) else { return .formulaReturnedNil }
        return .ok(value)
    }

    // MARK: - Distractor generation

    /// Returns a proportional step size that creates believable wrong answers.
    /// The step targets roughly 5-8% of the correct answer, rounded to a
    /// "psychologically natural" number so distractors look like real mistakes
    /// rather than random noise.
    ///
    /// Examples:
    ///   correct = 78,000  → step = 5,000  (distractors: 73K, 83K, 68K …)
    ///   correct = 2,083   → step = 100    (distractors: 1,983, 2,183 …)
    ///   correct = 312     → step = 20     (distractors: 292, 332, 272 …)
    ///   correct = 45      → step = 3      (distractors: 42, 48, 39 …)
    ///   correct = 8.50    → step = 0.50   (distractors: 8.00, 9.00, 7.50 …)
    ///   correct = 1.20    → step = 0.10   (distractors: 1.10, 1.30, 1.00 …)
    private static func niceStep(for correct: Double) -> Double {
        let magnitude = abs(correct)
        guard magnitude > 0 else { return 1 }

        // Target ~7% of the answer
        let raw = magnitude * 0.07

        // Round to a "nice" number: 1, 2, 3, 5, 10, 20, 25, 50, 100, 200, 500…
        // Find the power-of-10 bucket, then snap to the nearest nice fraction.
        let power = floor(log10(raw))
        let base = pow(10, power)                // e.g., raw=350 → base=100
        let ratio = raw / base                   // e.g., 3.5

        let nice: Double
        if ratio < 1.5      { nice = 1 }        // snap to 1×base
        else if ratio < 3.5 { nice = 2.5 }      // snap to 2.5×base
        else if ratio < 7.5 { nice = 5 }        // snap to 5×base
        else                 { nice = 10 }       // snap to 10×base

        let step = nice * base

        // Floor: never smaller than 0.01 (our rounding precision)
        // Also avoid sub-penny steps that produce identical rounded values.
        return max(step, 0.01)
    }

    private static func distractors(
        correct: Double,
        strategy: DistractorStrategy,
        variables: [String: Double],
        using rng: inout SeededRandomGenerator
    ) -> [Double] {
        var candidates: [Double] = []

        let step = niceStep(for: correct)

        // Multipliers give us ±1 step, ±2 steps, ±3 steps — enough variety to
        // pick 3 distinct wrong answers from. We generate both directions so
        // small correct values (where subtracting would go ≤ 0) still have
        // enough positive candidates.
        let multipliers: [Double] = [1, -1, 2, -2, 3, -3, 4, -4]

        switch strategy {
        case .roundedNeighbor:
            for m in multipliers {
                candidates.append((correct + step * m).rounded2dp)
            }

        case .offByDecimal:
            // Decimal-shift distractors: ×10 and ÷10 represent the classic
            // "misplaced decimal" mistake. We also add proportional neighbors
            // so the option set has a natural spread even when the decimal
            // shifts land very far away.
            let shifted10x = (correct * 10).rounded2dp
            let shifted01x = (correct / 10).rounded2dp

            candidates += [shifted10x, shifted01x]
            for m in multipliers {
                candidates.append((correct + step * m).rounded2dp)
            }

        case .commonMistake:
            // ── Tip-splitting mistakes ──
            if let bill = variables["billAmount"] {
                candidates.append(bill.rounded2dp)
                if let pct = variables["tipPercent"] {
                    candidates.append((bill * 0.10).rounded2dp)           // wrong percent (10%)
                    candidates.append((bill * pct / 100 * 2).rounded2dp)  // doubled tip
                    candidates.append((bill * pct / 100).rounded2dp)      // full tip (forgot to split)
                }
                if let n = variables["numPeople"] {
                    candidates.append((bill / n).rounded2dp)              // share with no tip
                }
            }

            // ── Percentage-off mistakes ──
            // Confuse "X% off" with "pay X%" (e.g., 20% off $80 → $16 vs $64)
            if let price = variables["price"], let pct = variables["discountPercent"] {
                let discountAmount = price * pct / 100
                let salePrice = price - discountAmount
                candidates.append(discountAmount.rounded2dp)              // discount amount vs sale price
                candidates.append(salePrice.rounded2dp)                   // sale price vs discount amount
                candidates.append((price * (100 - pct) / 100).rounded2dp) // redundant with sale price but safe
            }

            // ── Stacked-discount mistake: additive instead of sequential ──
            if let price = variables["price"],
               let d1 = variables["discount1"],
               let d2 = variables["discount2"] {
                let additive = price * (1 - (d1 + d2) / 100)
                candidates.append(additive.rounded2dp)
            }

            // ── Tax bracket mistake: flat rate instead of marginal ──
            if let income = variables["income"],
               let rate = variables["topRate"] ?? variables["rate2"] ?? variables["taxRate"] {
                let flatTax = income * rate / 100
                candidates.append(flatTax.rounded2dp)
            }

            // ── Rent affordability: forget ÷12 or use wrong percentage ──
            if let salary = variables["monthlySalary"] {
                candidates.append((salary * 0.30).rounded2dp)             // 30% rule confusion
                candidates.append((salary * 0.25).rounded2dp)             // 25% rule confusion
            }

            // ── Interest: simple vs compound confusion / wrong period ──
            if let principal = variables["principal"] ?? variables["amount"],
               let rate = variables["rate"] ?? variables["annualRate"] {
                candidates.append((principal * rate / 100).rounded2dp)     // 1-year interest only
                candidates.append((principal * rate / 1000).rounded2dp)    // decimal shift on rate
            }

            // Proportional neighbors as fallback (always included so we have enough)
            for m in [1.0, -1.0, 2.0, -2.0, 3.0, -3.0] {
                candidates.append((correct + step * m).rounded2dp)
            }
        }

        // Deduplicate, remove the correct answer and non-positive values
        var seen = Set<Double>([correct])
        var unique: [Double] = []
        for c in candidates where c > 0 && !seen.contains(c) {
            seen.insert(c)
            unique.append(c)
        }

        // Pick 3 using rng
        var result: [Double] = []
        while result.count < 3 && !unique.isEmpty {
            let idx = Int(rng.next() % UInt64(unique.count))
            result.append(unique[idx])
            unique.remove(at: idx)
        }

        // Fallback: walk outward at the same proportional step until we have 3
        var fallbackDelta = step
        while result.count < 3 {
            let candidate = (correct + fallbackDelta).rounded2dp
            if candidate > 0 && !result.contains(candidate) && candidate != correct {
                result.append(candidate)
            }
            fallbackDelta += step
        }

        return result
    }

    // MARK: - Template rendering

    private static func render(_ template: String, variables: [String: Double]) -> String {
        var result = template
        let groupFormatter: NumberFormatter = {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.usesGroupingSeparator = true
            return f
        }()
        for (key, value) in variables {
            let text: String
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                let intVal = Int(value)
                // Use comma grouping for large integers so prompts read naturally
                text = intVal >= 1_000
                    ? (groupFormatter.string(from: NSNumber(value: intVal)) ?? String(intVal))
                    : String(intVal)
            } else {
                text = String(format: "%.2f", value)
            }
            result = result.replacingOccurrences(of: "{{\(key)}}", with: text)
        }
        return result
    }
}

private extension Double {
    var rounded2dp: Double { (self * 100).rounded() / 100 }
}
