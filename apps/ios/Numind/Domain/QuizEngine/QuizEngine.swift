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

        let variables = resolveVariables(template.variableRules, using: &rng)

        guard let correctRaw = compute(formula: template.answerFormula, variables: variables) else {
            fatalError("QuizEngine: unknown formula '\(template.answerFormula)'")
        }
        let correctValue = correctRaw.rounded2dp

        // Assess difficulty from the actual generated numbers, not the template's static tier.
        let ops = FormulaOperationMap.operations(formula: template.answerFormula, variables: variables)
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
            guard let rate = vars["interestRate"], rate > 0 else { return nil }
            return 72 / rate
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
            guard let income = vars["freelanceIncome"] else { return nil }
            return income * 0.153
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
            let discretionary = income - poverty * 1.5
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
    ]

    private static func compute(formula: String, variables: [String: Double]) -> Double? {
        formulas[formula]?(variables)
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
