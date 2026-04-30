import Foundation

struct QuizEngine {

    // MARK: - Public API

    static func generate(from template: QuizTemplate, seed: UInt64 = .random(in: 1...UInt64.max)) -> QuizQuestion {
        var rng = SeededRandomGenerator(seed: seed)

        let variables = resolveVariables(template.variableRules, using: &rng)

        guard let correctRaw = compute(formula: template.answerFormula, variables: variables) else {
            fatalError("QuizEngine: unknown formula '\(template.answerFormula)'")
        }
        let correctValue = correctRaw.rounded2dp

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

        return QuizQuestion(
            id: UUID(),
            templateId: template.id,
            difficulty: template.difficulty,
            inputMode: template.inputMode ?? .multipleChoice,
            answerFormat: template.answerFormat,
            correctValue: correctValue,
            scenario: scenario,
            prompt: render(template.promptTemplate, variables: variables),
            choices: allChoices,
            correctChoiceId: correctChoice.id,
            explanation: render(template.explanationTemplate, variables: variables)
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
        // Estimation formulas
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
        // Estimation — rounding
        "estimateSumNearestTen": { vars in
            guard let a = vars["priceA"], let b = vars["priceB"] else { return nil }
            let roundA = (a / 10).rounded() * 10
            let roundB = (b / 10).rounded() * 10
            return roundA + roundB
        },
        // Estimation — salary conversion
        "hourlyFromAnnual": { vars in
            guard let annual = vars["annualSalary"] else { return nil }
            return annual / 2000
        },
        "annualFromHourly": { vars in
            guard let hourly = vars["hourlyRate"] else { return nil }
            return hourly * 2000
        },
        // Estimation — percent change
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

        // Travel Money
        "foreignToUSD": { vars in
            guard let foreign = vars["foreignAmount"],
                  let rate = vars["exchangeRate"] else { return nil }
            return foreign * rate
        },
        "usdToForeign": { vars in
            guard let usd = vars["usdAmount"],
                  let rate = vars["foreignRate"] else { return nil }
            return usd * rate
        },
        "currencyMarkupCost": { vars in
            guard let amount = vars["convertAmount"],
                  let markup = vars["markupPercent"] else { return nil }
            return amount * markup / 100
        },
        "foreignTransactionFee": { vars in
            guard let purchase = vars["purchaseAmount"],
                  let fee = vars["feePercent"] else { return nil }
            return purchase * fee / 100
        },
        "totalWithForeignFee": { vars in
            guard let purchase = vars["purchaseAmount"],
                  let fee = vars["feePercent"] else { return nil }
            return purchase * (1 + fee / 100)
        },
        "splitTravelCost": { vars in
            guard let total = vars["totalCost"],
                  let people = vars["numPeople"], people > 0 else { return nil }
            return total / people
        },
        "daysOnBudget": { vars in
            guard let budget = vars["travelBudget"],
                  let daily = vars["dailyCost"], daily > 0 else { return nil }
            return budget / daily
        },
        "hotelCostPerNight": { vars in
            guard let total = vars["hotelTotal"],
                  let nights = vars["numNights"], nights > 0 else { return nil }
            return total / nights
        },
        "travelInsuranceCost": { vars in
            guard let trip = vars["tripCost"],
                  let pct = vars["insurancePercent"] else { return nil }
            return trip * pct / 100
        },
        "tripTotalWithInsurance": { vars in
            guard let trip = vars["tripCost"],
                  let pct = vars["insurancePercent"] else { return nil }
            return trip * (1 + pct / 100)
        },
    ]

    private static func compute(formula: String, variables: [String: Double]) -> Double? {
        formulas[formula]?(variables)
    }

    // MARK: - Distractor generation

    private static func distractors(
        correct: Double,
        strategy: DistractorStrategy,
        variables: [String: Double],
        using rng: inout SeededRandomGenerator
    ) -> [Double] {
        var candidates: [Double] = []

        switch strategy {
        case .roundedNeighbor:
            for delta in [0.5, 1.0, 1.5, 2.0, -0.5, -1.0, -1.5, -2.0, 2.5, -2.5, 3.0] {
                candidates.append((correct + delta).rounded2dp)
            }

        case .offByDecimal:
            candidates += [
                (correct * 10).rounded2dp,
                (correct / 10).rounded2dp,
                (correct + 1.0).rounded2dp,
                (correct - 1.0).rounded2dp,
                (correct + 0.5).rounded2dp,
                (correct - 0.5).rounded2dp,
            ]

        case .commonMistake:
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
            // Neighbors as fallback
            for delta in [0.5, 1.0, -0.5, -1.0, 1.5, -1.5] {
                candidates.append((correct + delta).rounded2dp)
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

        // Fallback: walk outward until we have 3
        var fallbackDelta = 0.25
        while result.count < 3 {
            let candidate = (correct + fallbackDelta).rounded2dp
            if candidate > 0 && !result.contains(candidate) {
                result.append(candidate)
            }
            fallbackDelta += 0.25
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
