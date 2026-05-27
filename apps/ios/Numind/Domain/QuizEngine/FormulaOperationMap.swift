import Foundation

/// Maps each quiz answer formula to the sequence of mental arithmetic operations
/// required to solve it, using the actual resolved variable values.
///
/// This is the only per-formula piece in the difficulty system. The scoring engine
/// (`DifficultyScorer`) is generic — this map is what makes it aware of each
/// question type's computation chain.
enum FormulaOperationMap {

    /// Returns the mental operation chain for the given formula and resolved variables.
    /// Returns an empty array for formulas with trivial or unmappable computations.
    static func operations(formula: String, variables: [String: Double]) -> [MentalOp] {
        switch formula {

        // MARK: - Tips

        case "tipAmount":
            guard let bill = variables["billAmount"],
                  let pct = variables["tipPercent"] else { return [] }
            return [.percentOf(pct: pct, amount: bill)]

        case "billWithTip":
            guard let bill = variables["billAmount"],
                  let pct = variables["tipPercent"] else { return [] }
            let tip = bill * pct / 100
            return [.percentOf(pct: pct, amount: bill),
                    .add(a: bill, b: tip)]

        case "tipPerPerson":
            guard let bill = variables["billAmount"],
                  let pct = variables["tipPercent"],
                  let n = variables["numPeople"], n > 0 else { return [] }
            let tip = bill * pct / 100
            return [.percentOf(pct: pct, amount: bill),
                    .divide(a: tip, by: n)]

        case "billWithTipPerPerson":
            guard let bill = variables["billAmount"],
                  let pct = variables["tipPercent"],
                  let n = variables["numPeople"], n > 0 else { return [] }
            let tip = bill * pct / 100
            let total = bill + tip
            return [.percentOf(pct: pct, amount: bill),
                    .add(a: bill, b: tip),
                    .divide(a: total, by: n)]

        case "tipOnTotal":
            guard let bill = variables["billAmount"],
                  let tipPct = variables["tipPercent"],
                  let taxPct = variables["taxPercent"] else { return [] }
            let tax = bill * taxPct / 100
            let taxedBill = bill + tax
            return [.percentOf(pct: taxPct, amount: bill),
                    .add(a: bill, b: tax),
                    .percentOf(pct: tipPct, amount: taxedBill)]

        // MARK: - Discounts

        case "discountAmount":
            guard let price = variables["originalPrice"],
                  let pct = variables["discountPercent"] else { return [] }
            return [.percentOf(pct: pct, amount: price)]

        case "salePrice":
            guard let price = variables["originalPrice"],
                  let pct = variables["discountPercent"] else { return [] }
            let discount = price * pct / 100
            return [.percentOf(pct: pct, amount: price),
                    .subtract(b: discount, from: price)]

        case "stackedFinalPrice":
            guard let price = variables["originalPrice"],
                  let first = variables["firstDiscount"],
                  let second = variables["secondDiscount"] else { return [] }
            let afterFirst = price * (1 - first / 100)
            let firstDiscount = price * first / 100
            let secondDiscount = afterFirst * second / 100
            return [.percentOf(pct: first, amount: price),
                    .subtract(b: firstDiscount, from: price),
                    .percentOf(pct: second, amount: afterFirst),
                    .subtract(b: secondDiscount, from: afterFirst)]

        case "stackedTotalSaving":
            guard let price = variables["originalPrice"],
                  let first = variables["firstDiscount"],
                  let second = variables["secondDiscount"] else { return [] }
            let afterFirst = price * (1 - first / 100)
            let final = afterFirst * (1 - second / 100)
            return [.percentOf(pct: first, amount: price),
                    .percentOf(pct: second, amount: afterFirst),
                    .subtract(b: final, from: price)]

        case "bogoPerItemPrice":
            guard let price = variables["itemPrice"] else { return [] }
            return [.multiply(a: price, by: 2),
                    .divide(a: 2 * price, by: 3)]

        case "bogoSavings":
            // You save exactly one item's price — trivially single-step
            guard let price = variables["itemPrice"] else { return [] }
            return [.multiply(a: price, by: 1)]   // score as near-zero difficulty

        // MARK: - Tax

        case "taxAmount":
            guard let price = variables["originalPrice"],
                  let pct = variables["taxPercent"] else { return [] }
            return [.percentOf(pct: pct, amount: price)]

        case "priceWithTax":
            guard let price = variables["originalPrice"],
                  let pct = variables["taxPercent"] else { return [] }
            let tax = price * pct / 100
            return [.percentOf(pct: pct, amount: price),
                    .add(a: price, b: tax)]

        // MARK: - Money Math

        case "totalCost":
            guard let price = variables["itemPrice"],
                  let qty = variables["quantity"] else { return [] }
            return [.multiply(a: price, by: qty)]

        case "unitPrice":
            guard let total = variables["totalPrice"],
                  let qty = variables["quantity"], qty > 0 else { return [] }
            return [.divide(a: total, by: qty)]

        case "budgetRemaining":
            guard let budget = variables["budget"],
                  let spent = variables["spent"] else { return [] }
            return [.subtract(b: spent, from: budget)]

        case "budgetAfterPurchase":
            guard let budget = variables["budget"],
                  let qty = variables["quantity"],
                  let price = variables["itemPrice"] else { return [] }
            let cost = qty * price
            return [.multiply(a: price, by: qty),
                    .subtract(b: cost, from: budget)]

        case "monthlyToYearly":
            guard let monthly = variables["monthlyPrice"] else { return [] }
            return [.multiply(a: monthly, by: 12)]

        case "annualPlanSaving":
            guard let monthly = variables["monthlyPrice"],
                  let annual = variables["annualPrice"] else { return [] }
            return [.multiply(a: monthly, by: 12), .subtract(b: annual, from: monthly * 12)]

        case "yearlyToMonthly":
            guard let yearly = variables["yearlyPrice"] else { return [] }
            return [.divide(a: yearly, by: 12)]

        case "costPerUse":
            guard let price = variables["itemPrice"],
                  let uses = variables["numberOfUses"], uses > 0 else { return [] }
            return [.divide(a: price, by: uses)]

        case "totalMonthlyPayments":
            guard let p1 = variables["payment1"],
                  let p2 = variables["payment2"] else { return [] }
            return [.add(a: p1, b: p2)]

        // MARK: - Shared Math Shortcuts

        case "doubleOf":
            guard let amount = variables["originalAmount"] else { return [] }
            return [.multiply(a: amount, by: 2)]

        case "halfOf":
            guard let amount = variables["originalAmount"] else { return [] }
            return [.divide(a: amount, by: 2)]

        case "tripleOf":
            guard let amount = variables["originalAmount"] else { return [] }
            return [.multiply(a: amount, by: 3)]

        case "quarterOf":
            guard let amount = variables["originalAmount"] else { return [] }
            return [.divide(a: amount, by: 4)]

        case "twentyPercentOf":
            guard let amount = variables["originalAmount"] else { return [] }
            return [.percentOf(pct: 20, amount: amount)]

        case "multiplyBy5":
            guard let amount = variables["originalAmount"] else { return [] }
            return [.multiply(a: amount, by: 5)]

        case "splitFive":
            guard let total = variables["totalAmount"] else { return [] }
            return [.divide(a: total, by: 5)]

        case "estimateSumNearestTen":
            guard let a = variables["priceA"],
                  let b = variables["priceB"] else { return [] }
            let roundA = (a / 10).rounded() * 10
            let roundB = (b / 10).rounded() * 10
            return [.add(a: roundA, b: roundB)]

        case "hourlyFromAnnual":
            guard let annual = variables["annualSalary"] else { return [] }
            return [.divide(a: annual, by: 2000)]

        case "annualFromHourly":
            guard let hourly = variables["hourlyRate"] else { return [] }
            return [.multiply(a: hourly, by: 2000)]

        case "percentRaise":
            guard let base = variables["basePrice"], base > 0,
                  let increase = variables["increaseAmount"] else { return [] }
            return [.divide(a: increase, by: base),
                    .multiply(a: increase / base, by: 100)]

        case "percentDrop":
            guard let base = variables["basePrice"], base > 0,
                  let decrease = variables["decreaseAmount"] else { return [] }
            return [.divide(a: decrease, by: base),
                    .multiply(a: decrease / base, by: 100)]

        // MARK: - Salary & Income

        case "grossToNet":
            guard let gross = variables["grossPay"],
                  let pct = variables["deductionPercent"] else { return [] }
            let deduction = gross * pct / 100
            return [.percentOf(pct: pct, amount: gross),
                    .subtract(b: deduction, from: gross)]

        case "annualToMonthly":
            guard let annual = variables["annualSalary"] else { return [] }
            return [.divide(a: annual, by: 12)]

        case "monthlyToAnnual":
            guard let monthly = variables["monthlyIncome"] else { return [] }
            return [.multiply(a: monthly, by: 12)]

        case "raiseAmount":
            guard let salary = variables["annualSalary"],
                  let pct = variables["raisePercent"] else { return [] }
            return [.percentOf(pct: pct, amount: salary)]

        case "raisedSalary":
            guard let salary = variables["annualSalary"],
                  let pct = variables["raisePercent"] else { return [] }
            let raise = salary * pct / 100
            return [.percentOf(pct: pct, amount: salary),
                    .add(a: salary, b: raise)]

        case "overtimePay":
            guard let rate = variables["regularRate"],
                  let hours = variables["overtimeHours"] else { return [] }
            let otRate = rate * 1.5
            return [.multiply(a: rate, by: 1.5),
                    .multiply(a: otRate, by: hours)]

        case "biweeklyToAnnual":
            guard let biweekly = variables["biweeklySalary"] else { return [] }
            return [.multiply(a: biweekly, by: 26)]

        case "weeklyToAnnual":
            guard let weekly = variables["weeklySalary"] else { return [] }
            return [.multiply(a: weekly, by: 52)]

        case "payPeriodDifference":
            guard let weekly = variables["weeklyPay"],
                  let biweekly = variables["biweeklyPay"] else { return [] }
            return [.multiply(a: weekly, by: 52), .multiply(a: biweekly, by: 26),
                    .subtract(b: min(weekly * 52, biweekly * 26), from: max(weekly * 52, biweekly * 26))]

        // MARK: - Investing

        case "simpleInterest":
            guard let principal = variables["principal"],
                  let rate = variables["interestRate"],
                  let years = variables["years"] else { return [] }
            let interest = principal * rate / 100
            return [.percentOf(pct: rate, amount: principal),
                    .multiply(a: interest, by: years)]

        case "totalWithInterest":
            guard let principal = variables["principal"],
                  let rate = variables["interestRate"],
                  let years = variables["years"] else { return [] }
            let annualInterest = principal * rate / 100
            let totalInterest = annualInterest * years
            return [.percentOf(pct: rate, amount: principal),
                    .multiply(a: annualInterest, by: years),
                    .add(a: principal, b: totalInterest)]

        case "rule72":
            // Mirror the formula's permissive rate-input handling so the
            // difficulty op-chain stays accurate for both investing and HYSA uses.
            let raw = variables["interestRate"] ?? variables["apy"] ?? variables["apr"] ?? variables["rate"]
            guard let rate = raw, rate > 0 else { return [] }
            return [.divide(a: 72, by: rate)]

        case "roiPercent":
            guard let cost = variables["cost"], cost > 0,
                  let gain = variables["gain"] else { return [] }
            return [.divide(a: gain, by: cost),
                    .multiply(a: gain / cost, by: 100)]

        case "dollarReturn":
            guard let cost = variables["cost"],
                  let pct = variables["roiPercent"] else { return [] }
            return [.percentOf(pct: pct, amount: cost)]

        case "monthlyInvestmentReturn":
            guard let principal = variables["principal"],
                  let rate = variables["interestRate"] else { return [] }
            let annual = principal * rate / 100
            return [.percentOf(pct: rate, amount: principal),
                    .divide(a: annual, by: 12)]

        // 401(k) Match
        case "employerMatchAmount":
            guard let contribution = variables["contribution"],
                  let matchPct = variables["matchPercent"] else { return [] }
            return [.percentOf(pct: matchPct, amount: contribution)]

        case "totalWithMatch":
            guard let contribution = variables["contribution"],
                  let matchPct = variables["matchPercent"] else { return [] }
            let match = contribution * matchPct / 100
            return [.percentOf(pct: matchPct, amount: contribution),
                    .add(a: contribution, b: match)]

        case "employerMatchFromSalary":
            guard let salary = variables["annualSalary"],
                  let contribPct = variables["contribPercent"],
                  let matchPct = variables["matchPercent"] else { return [] }
            let contrib = salary * contribPct / 100
            return [.percentOf(pct: contribPct, amount: salary),
                    .percentOf(pct: matchPct, amount: contrib)]

        case "totalContribFromSalary":
            guard let salary = variables["annualSalary"],
                  let contribPct = variables["contribPercent"],
                  let matchPct = variables["matchPercent"] else { return [] }
            let contrib = salary * contribPct / 100
            let match = contrib * matchPct / 100
            return [.percentOf(pct: contribPct, amount: salary),
                    .percentOf(pct: matchPct, amount: contrib),
                    .add(a: contrib, b: match)]

        // Roth vs Traditional IRA
        case "rothTaxPaid", "traditionalTaxSaved", "rothVsTradDifference":
            guard let contribution = variables["contribution"],
                  let taxRate = variables["taxRate"] else { return [] }
            return [.percentOf(pct: taxRate, amount: contribution)]

        case "rothAfterTaxCost":
            guard let contribution = variables["contribution"],
                  let taxRate = variables["taxRate"] else { return [] }
            let tax = contribution * taxRate / 100
            return [.percentOf(pct: taxRate, amount: contribution),
                    .add(a: contribution, b: tax)]

        case "traditionalNetCost":
            guard let contribution = variables["contribution"],
                  let taxRate = variables["taxRate"] else { return [] }
            let saved = contribution * taxRate / 100
            return [.percentOf(pct: taxRate, amount: contribution),
                    .subtract(b: saved, from: contribution)]

        // Compound Growth
        case "totalContributed":
            guard let monthly = variables["monthlyAmount"],
                  let years = variables["years"] else { return [] }
            let annual = monthly * 12
            return [.multiply(a: monthly, by: 12),
                    .multiply(a: annual, by: years)]

        case "interestEarned":
            guard let total = variables["totalContributed"],
                  let finalVal = variables["finalValue"] else { return [] }
            return [.subtract(b: total, from: finalVal)]

        case "finalAccountValue":
            guard let total = variables["totalContributed"],
                  let growth = variables["growthAmount"] else { return [] }
            return [.add(a: total, b: growth)]

        // Inflation-Adjusted Raise
        case "inflationAdjustedRaise":
            guard let raise_ = variables["raisePercent"],
                  let inflation = variables["inflationPercent"] else { return [] }
            return [.subtract(b: inflation, from: raise_)]

        case "inflationAdjustedRaiseA":
            guard let raise_ = variables["raisePercentA"],
                  let inflation = variables["inflationPercent"] else { return [] }
            return [.subtract(b: inflation, from: raise_)]

        case "realRaiseDollars":
            guard let salary = variables["annualSalary"],
                  let raise_ = variables["raisePercent"],
                  let inflation = variables["inflationPercent"] else { return [] }
            let realPct = raise_ - inflation
            return [.subtract(b: inflation, from: raise_),
                    .percentOf(pct: abs(realPct), amount: salary)]

        case "salaryInRealTerms":
            guard let salary = variables["annualSalary"],
                  let raise_ = variables["raisePercent"],
                  let inflation = variables["inflationPercent"] else { return [] }
            let newSalary = salary * (1 + raise_ / 100)
            return [.percentOf(pct: raise_, amount: salary),
                    .add(a: salary, b: salary * raise_ / 100),
                    .divide(a: newSalary, by: 1 + inflation / 100)]

        // MARK: - Debt & Loans

        case "creditCardMonthlyInterest":
            guard let balance = variables["balance"],
                  let apr = variables["apr"] else { return [] }
            let annual = balance * apr / 100
            return [.percentOf(pct: apr, amount: balance),
                    .divide(a: annual, by: 12)]

        case "creditCardAnnualInterest":
            guard let balance = variables["balance"],
                  let apr = variables["apr"] else { return [] }
            return [.percentOf(pct: apr, amount: balance)]

        case "minimumPaymentTwoPercent":
            guard let balance = variables["balance"] else { return [] }
            return [.percentOf(pct: 2, amount: balance)]

        case "realisticMinPayment":
            guard let balance = variables["balance"],
                  let apr = variables["apr"] else { return [] }
            let principalPortion = balance * 0.01
            let monthlyInterest = balance * apr / 1200
            return [.percentOf(pct: 1, amount: balance),
                    .percentOf(pct: apr / 12, amount: balance),
                    .add(a: principalPortion, b: monthlyInterest)]

        case "debtToIncomeRatio":
            guard let debt = variables["totalDebt"],
                  let income = variables["monthlyIncome"], income > 0 else { return [] }
            return [.divide(a: debt, by: income),
                    .multiply(a: debt / income, by: 100)]

        case "loanTotalRepayment":
            guard let payment = variables["monthlyPayment"],
                  let months = variables["numMonths"] else { return [] }
            return [.multiply(a: payment, by: months)]

        case "loanTotalInterest":
            guard let payment = variables["monthlyPayment"],
                  let months = variables["numMonths"],
                  let principal = variables["loanAmount"] else { return [] }
            let total = payment * months
            return [.multiply(a: payment, by: months),
                    .subtract(b: principal, from: total)]

        case "balanceAfterMonthlyInterest":
            guard let balance = variables["balance"],
                  let apr = variables["apr"] else { return [] }
            let monthlyInterest = balance * apr / 100 / 12
            return [.percentOf(pct: apr / 12, amount: balance),
                    .add(a: balance, b: monthlyInterest)]

        case "extraPaymentAnnualSaving":
            guard let extra = variables["extraPayment"],
                  let apr = variables["apr"] else { return [] }
            return [.percentOf(pct: apr, amount: extra)]

        // MARK: - Housing & Rent

        case "maxRent28":
            guard let monthly = variables["monthlySalary"] else { return [] }
            return [.percentOf(pct: 28, amount: monthly)]

        case "maxAnnualRent28":
            guard let monthly = variables["monthlySalary"] else { return [] }
            let monthlyMax = monthly * 0.28
            return [.percentOf(pct: 28, amount: monthly),
                    .multiply(a: monthlyMax, by: 12)]

        case "rentIncrease":
            guard let rent = variables["currentRent"],
                  let pct = variables["increasePercent"] else { return [] }
            return [.percentOf(pct: pct, amount: rent)]

        case "newRentAfterIncrease":
            guard let rent = variables["currentRent"],
                  let pct = variables["increasePercent"] else { return [] }
            let inc = rent * pct / 100
            return [.percentOf(pct: pct, amount: rent),
                    .add(a: rent, b: inc)]

        case "moveInTotal":
            guard let first = variables["firstMonth"],
                  let last = variables["lastMonth"],
                  let deposit = variables["securityDeposit"] else { return [] }
            let broker = variables["brokerFee"] ?? 0
            return [.add(a: first, b: last),
                    .add(a: first + last, b: deposit),
                    .add(a: first + last + deposit, b: broker)]

        case "moveInThreeMonths":
            guard let rent = variables["monthlyRent"] else { return [] }
            return [.multiply(a: rent, by: 3)]

        case "moveInWithBrokerFee":
            guard let rent = variables["monthlyRent"],
                  let broker = variables["brokerFee"] else { return [] }
            return [.multiply(a: rent, by: 3),
                    .add(a: rent * 3, b: broker)]

        case "pricePerSqft":
            guard let price = variables["monthlyRent"],
                  let sqft = variables["squareFeet"], sqft > 0 else { return [] }
            return [.divide(a: price, by: sqft)]

        case "monthlyMortgage":
            guard let principal = variables["loanAmount"],
                  let rate = variables["annualRate"],
                  let years = variables["loanYears"], years > 0 else { return [] }
            let interest = principal * rate / 100 / 12
            let principalPart = principal / (years * 12)
            return [.percentOf(pct: rate / 12, amount: principal),
                    .divide(a: principal, by: years * 12),
                    .add(a: interest, b: principalPart)]

        // MARK: - Taxes & Paycheck

        case "marginalTax":
            guard let income = variables["taxableIncome"],
                  let bracket1 = variables["bracket1Limit"],
                  let rate1 = variables["rate1"],
                  let rate2 = variables["rate2"] else { return [] }
            let tax1 = min(income, bracket1) * rate1 / 100
            let excess = max(0, income - bracket1)
            return [.percentOf(pct: rate1, amount: min(income, bracket1)),
                    .percentOf(pct: rate2, amount: excess),
                    .add(a: tax1, b: excess * rate2 / 100)]

        case "marginalTax3Tier":
            // Mirrors the 3-tier real-bracket formula in QuizEngine. Mental-math
            // chain reflects only the tiers the income actually crosses, so
            // questions wholly within tier 1 score easy; questions spanning all
            // three tiers score hard.
            guard let income = variables["taxableIncome"],
                  let b1 = variables["bracket1Limit"],
                  let b2 = variables["bracket2Limit"],
                  let r1 = variables["rate1"],
                  let r2 = variables["rate2"],
                  let r3 = variables["rate3"] else { return [] }
            if income <= b1 {
                return [.percentOf(pct: r1, amount: income)]
            }
            if income <= b2 {
                let tier1Tax = b1 * r1 / 100
                return [.percentOf(pct: r1, amount: b1),
                        .percentOf(pct: r2, amount: income - b1),
                        .add(a: tier1Tax, b: (income - b1) * r2 / 100)]
            }
            let tier1Tax = b1 * r1 / 100
            let tier2Tax = (b2 - b1) * r2 / 100
            return [.percentOf(pct: r1, amount: b1),
                    .percentOf(pct: r2, amount: b2 - b1),
                    .percentOf(pct: r3, amount: income - b2),
                    .add(a: tier1Tax, b: tier2Tax),
                    .add(a: tier1Tax + tier2Tax, b: (income - b2) * r3 / 100)]

        case "paycheckNet":
            guard let gross = variables["grossPay"],
                  let ficaRate = variables["ficaRate"],
                  let fedRate = variables["federalRate"],
                  let stateRate = variables["stateRate"] else { return [] }
            let totalRate = ficaRate + fedRate + stateRate
            let deductions = gross * totalRate / 100
            return [.add(a: ficaRate, b: fedRate + stateRate),
                    .percentOf(pct: totalRate, amount: gross),
                    .subtract(b: deductions, from: gross)]

        case "annualToMonthlyNet":
            guard let annual = variables["annualSalary"],
                  let totalRate = variables["totalDeductionRate"] else { return [] }
            let net = annual * (1 - totalRate / 100)
            return [.percentOf(pct: totalRate, amount: annual),
                    .divide(a: net, by: 12)]

        case "taxRefund":
            guard let withheld = variables["totalWithheld"],
                  let owed = variables["taxOwed"] else { return [] }
            return [.subtract(b: owed, from: withheld)]

        case "selfEmploymentTax":
            guard let income = variables["freelanceIncome"] else { return [] }
            // 92.35% × 15.3% — two mental operations
            return [.multiply(a: income, by: 0.9235),
                    .percentOf(pct: 15.3, amount: income * 0.9235)]

        // MARK: - Insurance & Healthcare

        case "insurancePremiumAnnual", "hsaAnnualContribution":
            let monthly = variables["monthlyPremium"] ?? variables["monthlyHSA"] ?? 0
            return [.multiply(a: monthly, by: 12)]

        case "insuranceWorstCase":
            guard let monthly = variables["monthlyPremium"],
                  let deductible = variables["deductible"] else { return [] }
            let annual = monthly * 12
            return [.multiply(a: monthly, by: 12),
                    .add(a: annual, b: deductible)]

        case "premiumDifferenceAnnual", "ppoPremiumExtra":
            let a = variables["premiumA"] ?? variables["ppoPremium"] ?? 0
            let b = variables["premiumB"] ?? variables["hdhpPremium"] ?? 0
            let diff = a - b
            return [.subtract(b: b, from: a),
                    .multiply(a: diff, by: 12)]

        case "insurancePremiumPlusBills":
            guard let monthly = variables["monthlyPremium"],
                  let bills = variables["medicalBills"] else { return [] }
            let annual = monthly * 12
            return [.multiply(a: monthly, by: 12),
                    .add(a: annual, b: bills)]

        case "planCostDifference":
            guard let hdhpPrem = variables["hdhpPremium"],
                  let hdhpDed = variables["hdhpDeductible"],
                  let ppoPrem = variables["ppoPremium"],
                  let ppoCopay = variables["ppoCopay"],
                  let visits = variables["visits"] else { return [] }
            let hdhpTotal = hdhpPrem * 12 + hdhpDed
            let ppoTotal = ppoPrem * 12 + ppoCopay * visits
            return [.multiply(a: hdhpPrem, by: 12), .add(a: hdhpPrem * 12, b: hdhpDed),
                    .multiply(a: ppoPrem, by: 12), .multiply(a: ppoCopay, by: visits),
                    .subtract(b: min(hdhpTotal, ppoTotal), from: max(hdhpTotal, ppoTotal))]

        case "insurancePlanCompare":
            guard let premA = variables["premiumA"],
                  let dedA = variables["deductibleA"],
                  let premB = variables["premiumB"],
                  let dedB = variables["deductibleB"] else { return [] }
            let totalA = premA * 12 + dedA
            let totalB = premB * 12 + dedB
            return [.multiply(a: premA, by: 12), .add(a: premA * 12, b: dedA),
                    .multiply(a: premB, by: 12), .add(a: premB * 12, b: dedB),
                    .subtract(b: min(totalA, totalB), from: max(totalA, totalB))]

        case "coinsuranceCost":
            let bill = variables["billAmount"] ?? variables["totalBill"] ?? 0
            guard let pct = variables["coinsurancePercent"] else { return [] }
            return [.percentOf(pct: pct, amount: bill)]

        case "copayTotal":
            guard let copay = variables["copayAmount"],
                  let visits = variables["visitCount"] else { return [] }
            return [.multiply(a: copay, by: visits)]

        case "copayMixed":
            guard let pc = variables["copayPrimary"], let sc = variables["copaySpecialist"],
                  let pv = variables["primaryVisits"], let sv = variables["specialistVisits"] else { return [] }
            return [.multiply(a: pc, by: pv),
                    .multiply(a: sc, by: sv),
                    .add(a: pc * pv, b: sc * sv)]

        case "totalWithCoinsurance":
            guard let bill = variables["totalBill"],
                  let deductible = variables["deductible"],
                  let pct = variables["coinsurancePercent"] else { return [] }
            let remainder = bill - deductible
            let coinsurance = remainder * pct / 100
            return [.subtract(b: deductible, from: bill),
                    .percentOf(pct: pct, amount: remainder),
                    .add(a: deductible, b: coinsurance)]

        case "oopRemaining", "oopDifference":
            let max = variables["oopMax"] ?? variables["oopMaxB"] ?? 0
            let paid = variables["amountPaid"] ?? variables["oopMaxA"] ?? 0
            return [.subtract(b: paid, from: max)]

        case "oopActualCost":
            guard let max = variables["oopMax"],
                  let paid = variables["amountPaid"],
                  let cost = variables["procedureCost"] else { return [] }
            return [.subtract(b: paid, from: max),
                    .subtract(b: min(max - paid, cost), from: cost)]

        case "oopWithCap":
            guard let deductible = variables["deductible"],
                  let bill = variables["totalBill"],
                  let pct = variables["coinsurancePercent"],
                  let max = variables["oopMax"] else { return [] }
            let coinsurance = (bill - deductible) * pct / 100
            return [.subtract(b: deductible, from: bill),
                    .percentOf(pct: pct, amount: bill - deductible),
                    .add(a: deductible, b: coinsurance)]

        case "maxAnnualCost":
            guard let monthly = variables["monthlyPremium"],
                  let max = variables["oopMax"] else { return [] }
            let annual = monthly * 12
            return [.multiply(a: monthly, by: 12),
                    .add(a: annual, b: max)]

        case "planAnnualWithCopay":
            guard let monthly = variables["monthlyPremium"],
                  let copay = variables["copayAmount"],
                  let visits = variables["visitCount"] else { return [] }
            let annual = monthly * 12
            let copayTotal = copay * visits
            return [.multiply(a: monthly, by: 12),
                    .multiply(a: copay, by: visits),
                    .add(a: annual, b: copayTotal)]

        case "hdhpVsPpoGap":
            guard let hdhpPrem = variables["hdhpPremium"],
                  let hdhpDed = variables["hdhpDeductible"],
                  let ppoPrem = variables["ppoPremium"] else { return [] }
            let hdhpTotal = hdhpPrem * 12 + hdhpDed
            let ppoTotal = ppoPrem * 12
            return [.multiply(a: hdhpPrem, by: 12), .add(a: hdhpPrem * 12, b: hdhpDed),
                    .multiply(a: ppoPrem, by: 12),
                    .subtract(b: min(hdhpTotal, ppoTotal), from: max(hdhpTotal, ppoTotal))]

        case "hsaTaxSaving":
            let contrib = variables["hsaContribution"] ?? variables["expenseCost"] ?? 0
            guard let rate = variables["taxRate"] else { return [] }
            return [.percentOf(pct: rate, amount: contrib)]

        case "hsaEffectiveCost":
            guard let cost = variables["expenseCost"],
                  let rate = variables["taxRate"] else { return [] }
            let saving = cost * rate / 100
            return [.percentOf(pct: rate, amount: cost),
                    .subtract(b: saving, from: cost)]

        case "hdhpNetAdvantage":
            guard let hdhp = variables["hdhpPremium"],
                  let ppo = variables["ppoPremium"],
                  let hsaSaving = variables["hsaTaxSaving"] else { return [] }
            let premSaving = (ppo - hdhp) * 12
            return [.subtract(b: hdhp, from: ppo),
                    .multiply(a: ppo - hdhp, by: 12),
                    .add(a: premSaving, b: hsaSaving)]

        case "hsaTotalTaxSaving":
            guard let contrib = variables["hsaContribution"],
                  let rate = variables["taxRate"],
                  let years = variables["years"] else { return [] }
            let annual = contrib * rate / 100
            return [.percentOf(pct: rate, amount: contrib),
                    .multiply(a: annual, by: years)]

        // MARK: - Car & Big Purchases

        case "carTotalPaid":
            guard let payment = variables["monthlyPayment"],
                  let months = variables["loanTermMonths"] else { return [] }
            return [.multiply(a: payment, by: months)]

        case "carInterestPaid":
            guard let loan = variables["loanAmount"],
                  let total = variables["totalPaid"] else { return [] }
            return [.subtract(b: loan, from: total)]

        case "carTotalWithDown":
            guard let down = variables["downPayment"],
                  let payment = variables["monthlyPayment"],
                  let months = variables["termMonths"] else { return [] }
            let financed = payment * months
            return [.multiply(a: payment, by: months),
                    .add(a: down, b: financed)]

        case "loanTotalDifference":
            guard let payA = variables["paymentA"], let termA = variables["termA"],
                  let payB = variables["paymentB"], let termB = variables["termB"] else { return [] }
            let totalA = payA * termA
            let totalB = payB * termB
            return [.multiply(a: payA, by: termA),
                    .multiply(a: payB, by: termB),
                    .subtract(b: min(totalA, totalB), from: max(totalA, totalB))]

        case "extraInterestCost":
            guard let total60 = variables["total60"], let total72 = variables["total72"],
                  let loan = variables["loanAmount"] else { return [] }
            return [.subtract(b: loan, from: total60),
                    .subtract(b: loan, from: total72),
                    .subtract(b: total60 - loan, from: total72 - loan)]

        case "carTotalFromYears", "loanTotalFromYears":
            let payment = variables["monthlyPayment"] ?? variables["budget"] ?? 0
            guard let years = variables["termYears"] else { return [] }
            let months = years * 12
            return [.multiply(a: years, by: 12),
                    .multiply(a: payment, by: months)]

        case "monthlyDifference":
            if let a = variables["payment5"], let b = variables["payment6"] {
                return [.subtract(b: b, from: a)]
            }
            if let a = variables["payment10"], let b = variables["payment20"] {
                return [.subtract(b: b, from: a)]
            }
            if let a = variables["oldPayment"], let b = variables["newPayment"] {
                return [.subtract(b: b, from: a)]
            }
            if let a = variables["standardPayment"], let b = variables["idrPayment"] {
                return [.subtract(b: b, from: a)]
            }
            return []

        case "termInterestDifference":
            guard let loan = variables["loanAmount"],
                  let pay48 = variables["payment48"],
                  let pay72 = variables["payment72"] else { return [] }
            let int48 = pay48 * 48 - loan
            let int72 = pay72 * 72 - loan
            return [.multiply(a: pay48, by: 48), .subtract(b: loan, from: pay48 * 48),
                    .multiply(a: pay72, by: 72), .subtract(b: loan, from: pay72 * 72),
                    .subtract(b: int48, from: int72)]

        case "interestPercentOfTotal":
            guard let loan = variables["loanAmount"],
                  let payB = variables["paymentB"],
                  let termB = variables["termB"] else { return [] }
            let totalB = payB * termB
            let interest = totalB - loan
            return [.multiply(a: payB, by: termB),
                    .subtract(b: loan, from: totalB),
                    .divide(a: interest, by: totalB)]

        case "carDownPaymentAmount":
            guard let price = variables["carPrice"],
                  let pct = variables["downPercent"] else { return [] }
            return [.percentOf(pct: pct, amount: price)]

        case "carLoanAfterDown":
            guard let price = variables["carPrice"],
                  let down = variables["downPayment"] else { return [] }
            return [.subtract(b: down, from: price)]

        case "carInterestOnLoan":
            guard let price = variables["carPrice"],
                  let downPct = variables["downPercent"],
                  let intPct = variables["interestRate"] else { return [] }
            let loan = price * (1 - downPct / 100)
            return [.percentOf(pct: downPct, amount: price),
                    .subtract(b: price * downPct / 100, from: price),
                    .percentOf(pct: intPct, amount: loan)]

        case "interestSaving":
            guard let int10 = variables["interest10"],
                  let int20 = variables["interest20"] else { return [] }
            return [.subtract(b: int20, from: int10)]

        case "totalCostDifference":
            guard let downA = variables["downA"], let payA = variables["paymentA"], let termA = variables["termA"],
                  let downB = variables["downB"], let payB = variables["paymentB"], let termB = variables["termB"] else { return [] }
            let totalA = downA + payA * termA
            let totalB = downB + payB * termB
            return [.multiply(a: payA, by: termA), .add(a: downA, b: payA * termA),
                    .multiply(a: payB, by: termB), .add(a: downB, b: payB * termB),
                    .subtract(b: min(totalA, totalB), from: max(totalA, totalB))]

        case "carMaxPayment":
            guard let income = variables["monthlyIncome"] else { return [] }
            return [.percentOf(pct: 10, amount: income)]

        case "carMaxPaymentFromAnnual":
            guard let annual = variables["annualSalary"] else { return [] }
            let monthly = annual / 12
            return [.divide(a: annual, by: 12),
                    .percentOf(pct: 10, amount: monthly)]

        case "paymentVsBudget":
            guard let income = variables["monthlyIncome"],
                  let payment = variables["monthlyPayment"] else { return [] }
            let budget = income * 0.10
            return [.percentOf(pct: 10, amount: income),
                    .subtract(b: min(budget, payment), from: max(budget, payment))]

        case "carMaxAffordable":
            guard let income = variables["monthlyIncome"] else { return [] }
            let maxPayment = income * 0.10
            let maxFinanced = maxPayment * 48
            return [.percentOf(pct: 10, amount: income),
                    .multiply(a: maxPayment, by: 48),
                    .divide(a: maxFinanced, by: 0.80)]

        case "carValueAfterDep":
            guard let price = variables["carPrice"],
                  let pct = variables["depPercent"] else { return [] }
            let dep = price * pct / 100
            return [.percentOf(pct: pct, amount: price),
                    .subtract(b: dep, from: price)]

        case "carDepreciationAmount":
            guard let price = variables["carPrice"],
                  let pct = variables["depPercent"] else { return [] }
            return [.percentOf(pct: pct, amount: price)]

        case "carValueYear2":
            guard let price = variables["carPrice"],
                  let dep1 = variables["depYear1"],
                  let dep2 = variables["depYear2"] else { return [] }
            let afterY1 = price * (1 - dep1 / 100)
            return [.percentOf(pct: dep1, amount: price),
                    .subtract(b: price * dep1 / 100, from: price),
                    .percentOf(pct: dep2, amount: afterY1),
                    .subtract(b: afterY1 * dep2 / 100, from: afterY1)]

        case "carTotalDepreciation":
            guard let price = variables["carPrice"],
                  let value = variables["valueAfter3"] else { return [] }
            return [.subtract(b: value, from: price)]

        case "depreciationDifference":
            guard let newPrice = variables["newPrice"], let newVal = variables["newValueY3"],
                  let usedPrice = variables["usedPrice"], let usedVal = variables["usedValueY3"] else { return [] }
            let newDep = newPrice - newVal
            let usedDep = usedPrice - usedVal
            return [.subtract(b: newVal, from: newPrice),
                    .subtract(b: usedVal, from: usedPrice),
                    .subtract(b: min(newDep, usedDep), from: max(newDep, usedDep))]

        // MARK: - Student Loans & Education

        case "annualPayment", "annualSaving":
            let monthly = variables["monthlyPayment"] ?? variables["monthlySaving"] ?? 0
            return [.multiply(a: monthly, by: 12)]

        case "estimatedMonthly":
            guard let balance = variables["loanBalance"],
                  let per10k = variables["paymentPer10k"] else { return [] }
            let units = balance / 10000
            return [.divide(a: balance, by: 10000),
                    .multiply(a: units, by: per10k)]

        case "monthlyInterestCharge", "newMonthlyInterest":
            let balance = variables["loanBalance"] ?? 0
            let rate = variables["interestRate"] ?? variables["newRate"] ?? 0
            let annual = balance * rate / 100
            return [.percentOf(pct: rate, amount: balance),
                    .divide(a: annual, by: 12)]

        case "principalPayment":
            guard let payment = variables["monthlyPayment"],
                  let interest = variables["monthlyInterest"] else { return [] }
            return [.subtract(b: interest, from: payment)]

        case "totalInterestPaid":
            guard let total = variables["totalPaid"],
                  let loan = variables["loanAmount"] else { return [] }
            return [.subtract(b: loan, from: total)]

        case "termCostDifference":
            guard let pay10 = variables["payment10"],
                  let pay20 = variables["payment20"] else { return [] }
            let total10 = pay10 * 120
            let total20 = pay20 * 240
            return [.multiply(a: pay10, by: 120),
                    .multiply(a: pay20, by: 240),
                    .subtract(b: total10, from: total20)]

        case "percentMoreCost":
            guard let standard = variables["totalStandard"],
                  let extended = variables["totalExtended"] else { return [] }
            let diff = extended - standard
            return [.subtract(b: standard, from: extended),
                    .divide(a: diff, by: standard)]

        case "extraPaymentSaving":
            let original = variables["originalTotal"] ?? variables["oldTotal"] ?? 0
            guard let newTotal = variables["newTotal"] else { return [] }
            return [.subtract(b: newTotal, from: original)]

        case "refiTotalSaving":
            guard let oldPay = variables["oldPayment"], let oldMonths = variables["remainingMonths"],
                  let newPay = variables["newPayment"], let newMonths = variables["newTermMonths"] else { return [] }
            return [.multiply(a: oldPay, by: oldMonths),
                    .multiply(a: newPay, by: newMonths),
                    .subtract(b: newPay * newMonths, from: oldPay * oldMonths)]

        case "idrAnnualPayment":
            guard let discretionary = variables["discretionaryIncome"],
                  let pct = variables["idrPercent"] else { return [] }
            return [.percentOf(pct: pct, amount: discretionary)]

        case "monthlyFromAnnual":
            guard let annual = variables["annualPayment"] else { return [] }
            return [.divide(a: annual, by: 12)]

        case "idrMonthlyFromIncome":
            guard let income = variables["annualIncome"],
                  let poverty = variables["povertyLine"],
                  let pct = variables["idrPercent"] else { return [] }
            let povertyThreshold = poverty * 1.5
            let discretionary = income - povertyThreshold
            let annual = discretionary * pct / 100
            return [.multiply(a: poverty, by: 1.5),
                    .subtract(b: povertyThreshold, from: income),
                    .percentOf(pct: pct, amount: discretionary),
                    .divide(a: annual, by: 12)]

        case "annualPaymentDifference":
            guard let standard = variables["standardPayment"],
                  let idr = variables["idrPayment"] else { return [] }
            let diff = standard - idr
            return [.subtract(b: idr, from: standard),
                    .multiply(a: diff, by: 12)]

        case "idrVsStandardDifference":
            guard let standardTotal = variables["standardTotal"],
                  let idrTotal = variables["idrTotal"] else { return [] }
            return [.subtract(b: min(standardTotal, idrTotal), from: max(standardTotal, idrTotal))]

        case "pslfTotalPaid":
            let payment = variables["monthlyPayment"] ?? variables["idrPayment"] ?? variables["pslfPayment"] ?? 0
            return [.multiply(a: payment, by: 120)]

        case "pslfForgiveness":
            guard let balance = variables["loanBalance"] else { return [] }
            if let payment = variables["idrPayment"] ?? variables["monthlyPayment"] {
                let paid = payment * 120
                return [.multiply(a: payment, by: 120),
                        .subtract(b: paid, from: balance)]
            }
            if let totalPaid = variables["totalPaid"] {
                return [.subtract(b: totalPaid, from: balance)]
            }
            return []

        case "pslfSavings":
            guard let standardTotal = variables["standardTotal"],
                  let idr = variables["idrPayment"] else { return [] }
            let pslfTotal = idr * 120
            return [.multiply(a: idr, by: 120),
                    .subtract(b: pslfTotal, from: standardTotal)]

        case "refiVsPslfDifference":
            guard let refiPay = variables["refiPayment"],
                  let refiMonths = variables["refiMonths"],
                  let pslfPay = variables["pslfPayment"] else { return [] }
            let refiTotal = refiPay * refiMonths
            let pslfTotal = pslfPay * 120
            return [.multiply(a: refiPay, by: refiMonths),
                    .multiply(a: pslfPay, by: 120),
                    .subtract(b: min(refiTotal, pslfTotal), from: max(refiTotal, pslfTotal))]

        // MARK: - Smart Shopping: Coupon vs Cashback

        case "couponSaving":
            guard let price = variables["price"],
                  let pct = variables["couponPct"] else { return [] }
            return [.percentOf(pct: pct, amount: price)]

        case "cashbackAmount":
            guard let price = variables["price"],
                  let pct = variables["cashbackPct"] else { return [] }
            return [.percentOf(pct: pct, amount: price)]

        case "couponPlusCashback":
            guard let price = variables["price"],
                  let cp = variables["couponPct"],
                  let cb = variables["cashbackPct"] else { return [] }
            let coupon = price * cp / 100
            let afterCoupon = price - coupon
            let cashback = afterCoupon * cb / 100
            return [.percentOf(pct: cp, amount: price),
                    .subtract(b: coupon, from: price),
                    .percentOf(pct: cb, amount: afterCoupon),
                    .add(a: coupon, b: cashback)]

        case "couponVsCashbackDiff":
            guard let price = variables["price"],
                  let cp = variables["couponPct"],
                  let cb = variables["cashbackPct"] else { return [] }
            let couponAmt = price * cp / 100
            let cashAmt = price * cb / 100
            return [.percentOf(pct: cp, amount: price),
                    .percentOf(pct: cb, amount: price),
                    .subtract(b: min(couponAmt, cashAmt), from: max(couponAmt, cashAmt))]

        case "couponCashbackFinalPrice":
            guard let price = variables["price"],
                  let cp = variables["couponPct"],
                  let cb = variables["cashbackPct"] else { return [] }
            let salePrice = price * (1 - cp / 100)
            let cashback = salePrice * cb / 100
            let coupon = price * cp / 100
            return [.percentOf(pct: cp, amount: price),
                    .subtract(b: coupon, from: price),
                    .percentOf(pct: cb, amount: salePrice),
                    .subtract(b: cashback, from: salePrice)]

        // MARK: - Smart Shopping: Discount + Tax

        case "salePricePlusTax":
            guard let price = variables["originalPrice"],
                  let disc = variables["discountPercent"],
                  let tax = variables["taxPercent"] else { return [] }
            let salePrice = price * (1 - disc / 100)
            let taxAmt = salePrice * tax / 100
            return [.percentOf(pct: disc, amount: price),
                    .subtract(b: price * disc / 100, from: price),
                    .percentOf(pct: tax, amount: salePrice),
                    .add(a: salePrice, b: taxAmt)]

        case "taxOnSalePrice":
            guard let price = variables["originalPrice"],
                  let disc = variables["discountPercent"],
                  let tax = variables["taxPercent"] else { return [] }
            let salePrice = price * (1 - disc / 100)
            return [.percentOf(pct: disc, amount: price),
                    .subtract(b: price * disc / 100, from: price),
                    .percentOf(pct: tax, amount: salePrice)]

        case "stackedSalePricePlusTax":
            guard let price = variables["originalPrice"],
                  let first = variables["firstDiscount"],
                  let second = variables["secondDiscount"],
                  let tax = variables["taxPercent"] else { return [] }
            let afterFirst = price * (1 - first / 100)
            let afterSecond = afterFirst * (1 - second / 100)
            return [.percentOf(pct: first, amount: price),
                    .subtract(b: price * first / 100, from: price),
                    .percentOf(pct: second, amount: afterFirst),
                    .subtract(b: afterFirst * second / 100, from: afterFirst),
                    .percentOf(pct: tax, amount: afterSecond),
                    .add(a: afterSecond, b: afterSecond * tax / 100)]

        case "discountTaxSaving":
            guard let price = variables["originalPrice"],
                  let disc = variables["discountPercent"],
                  let tax = variables["taxPercent"] else { return [] }
            let fullWithTax = price * (1 + tax / 100)
            let saleWithTax = price * (1 - disc / 100) * (1 + tax / 100)
            return [.percentOf(pct: tax, amount: price),
                    .add(a: price, b: price * tax / 100),
                    .percentOf(pct: disc, amount: price),
                    .subtract(b: saleWithTax, from: fullWithTax)]

        // MARK: - Smart Shopping: Membership Worth

        case "membershipBreakeven":
            let fee = variables["monthlyFee"] ?? variables["annualFee"]
            guard let f = fee, let saving = variables["savingPerUse"], saving > 0 else { return [] }
            return [.divide(a: f, by: saving)]

        case "membershipNetSavings":
            let fee = variables["monthlyFee"] ?? variables["annualFee"]
            guard let f = fee,
                  let saving = variables["savingPerUse"],
                  let uses = variables["usesPerPeriod"] else { return [] }
            let gross = uses * saving
            return [.multiply(a: uses, by: saving),
                    .subtract(b: f, from: gross)]

        case "membershipBreakevenDiff":
            guard let feeA = variables["feeA"], let saveA = variables["saveA"], saveA > 0,
                  let feeB = variables["feeB"], let saveB = variables["saveB"], saveB > 0 else { return [] }
            let breakA = (feeA / saveA).rounded(.up)
            let breakB = (feeB / saveB).rounded(.up)
            return [.divide(a: feeA, by: saveA),
                    .divide(a: feeB, by: saveB),
                    .subtract(b: min(breakA, breakB), from: max(breakA, breakB))]

        // MARK: - Money Math: Subscription audit
        case "sumThreeSubscriptions":
            guard let a = variables["sub1"], let b = variables["sub2"], let c = variables["sub3"] else { return [] }
            return [.add(a: a, b: b), .add(a: a + b, b: c)]

        case "annualizedSubscriptions":
            guard let a = variables["sub1"], let b = variables["sub2"], let c = variables["sub3"] else { return [] }
            let sum = a + b + c
            return [.add(a: a, b: b), .add(a: a + b, b: c), .multiply(a: sum, by: 12)]

        case "annualSubscriptionSaving":
            guard let s = variables["subToCut"] else { return [] }
            return [.multiply(a: s, by: 12)]

        // MARK: - Money Math: Sales tax with budget
        case "preTaxMax":
            guard let budget = variables["budget"], let tax = variables["taxPercent"] else { return [] }
            return [.divide(a: budget, by: 1 + tax / 100)]

        case "asymmetryGap":
            guard let budget = variables["budget"], let tax = variables["taxPercent"] else { return [] }
            let right = budget / (1 + tax / 100)
            let wrong = budget * (1 - tax / 100)
            return [.divide(a: budget, by: 1 + tax / 100),
                    .percentOf(pct: tax, amount: budget),
                    .subtract(b: wrong, from: right)]

        // MARK: - Money Math: 50/30/20
        case "percentOfIncome":
            guard let income = variables["income"], let pct = variables["pct"] else { return [] }
            return [.percentOf(pct: pct, amount: income)]

        case "needsOverCap":
            guard let income = variables["income"], let needs = variables["needs"] else { return [] }
            let cap = income * 0.5
            return [.percentOf(pct: 50, amount: income),
                    .subtract(b: cap, from: needs)]

        case "monthlyToReachGoal":
            guard let goal = variables["goal"], let months = variables["months"], months > 0 else { return [] }
            return [.divide(a: goal, by: months)]

        // MARK: - Money Math: Latte factor
        case "dailyToAnnual":
            guard let daily = variables["dailyCost"] else { return [] }
            return [.multiply(a: daily, by: 365)]

        case "workdayToAnnual":
            guard let daily = variables["dailyCost"] else { return [] }
            return [.multiply(a: daily, by: 260)]

        case "dailyHabitSavingsAnnual":
            guard let current = variables["currentCost"], let alt = variables["alternativeCost"] else { return [] }
            return [.subtract(b: alt, from: current),
                    .multiply(a: current - alt, by: 365)]

        case "dailyVsWorkdayCostDiff":
            guard let daily = variables["habitDailyCost"], let workday = variables["habitWorkdayCost"] else { return [] }
            let a = daily * 365
            let b = workday * 260
            return [.multiply(a: daily, by: 365),
                    .multiply(a: workday, by: 260),
                    .subtract(b: min(a, b), from: max(a, b))]

        case "multipleHabitsAnnual":
            guard let coffee = variables["coffeeCost"],
                  let lunch = variables["lunchCost"],
                  let snack = variables["snackCost"] else { return [] }
            let daily = coffee + snack
            return [.add(a: coffee, b: snack),
                    .multiply(a: daily, by: 365),
                    .multiply(a: lunch, by: 260),
                    .add(a: daily * 365, b: lunch * 260)]

        // MARK: - Money Math: Weekly / monthly conversions
        case "weeklyToMonthlyCorrect":
            guard let w = variables["weekly"] else { return [] }
            return [.multiply(a: w, by: 52), .divide(a: w * 52, by: 12)]

        case "biweeklyToMonthly":
            guard let b = variables["biweekly"] else { return [] }
            return [.multiply(a: b, by: 26), .divide(a: b * 26, by: 12)]

        case "monthlyToWeekly":
            guard let m = variables["monthly"] else { return [] }
            return [.multiply(a: m, by: 12), .divide(a: m * 12, by: 52)]

        case "wrongMultiplierShortfall":
            guard let w = variables["weekly"] else { return [] }
            return [.multiply(a: w, by: 4)]

        case "biweeklyWrongMultiplierShortfall":
            guard let b = variables["biweekly"] else { return [] }
            return [.multiply(a: b, by: 2)]

        // MARK: - Salary: Rework additions
        case "afterTaxMonthlyRaise":
            guard let salary = variables["annualSalary"], let pct = variables["raisePercent"] else { return [] }
            let raise = salary * pct / 100
            let monthly = raise / 12
            return [.percentOf(pct: pct, amount: salary),
                    .divide(a: raise, by: 12),
                    .multiply(a: monthly, by: 0.72)]

        case "totalWeeklyWithOT":
            guard let rate = variables["regularRate"], let total = variables["totalHours"] else { return [] }
            let regHours = min(total, 40.0)
            let otHours = max(0, total - 40)
            return [.multiply(a: regHours, by: rate),
                    .multiply(a: otHours, by: rate * 1.5),
                    .add(a: regHours * rate, b: otHours * rate * 1.5)]

        case "weeklyMonthlyOfferDiff":
            guard let w = variables["weeklyPay"], let m = variables["monthlyPay"] else { return [] }
            let annualW = w * 52
            let annualM = m * 12
            return [.multiply(a: w, by: 52),
                    .multiply(a: m, by: 12),
                    .subtract(b: min(annualW, annualM), from: max(annualW, annualM))]

        // MARK: - Salary: Hourly to salary
        case "offerComparisonDiff":
            guard let h = variables["hourlyRate"], let s = variables["annualSalary"] else { return [] }
            let annualHourly = h * 2000
            return [.multiply(a: h, by: 2000),
                    .subtract(b: min(annualHourly, s), from: max(annualHourly, s))]

        // MARK: - Salary: Total compensation
        case "totalCompensationNoBonus":
            guard let base = variables["baseSalary"],
                  let ins = variables["insuranceValue"],
                  let match = variables["matchAmount"] else { return [] }
            return [.add(a: base, b: ins), .add(a: base + ins, b: match)]

        case "totalCompDifference":
            guard let bA = variables["baseA"], let bnA = variables["benefitsA"],
                  let bB = variables["baseB"], let bnB = variables["benefitsB"] else { return [] }
            let totalA = bA + bnA
            let totalB = bB + bnB
            return [.add(a: bA, b: bnA),
                    .add(a: bB, b: bnB),
                    .subtract(b: min(totalA, totalB), from: max(totalA, totalB))]

        case "effectiveHourlyOfTotalComp":
            guard let tc = variables["totalComp"] else { return [] }
            return [.divide(a: tc, by: 2000)]

        case "totalCompMinusBase":
            guard let tc = variables["totalComp"], let base = variables["baseSalary"] else { return [] }
            return [.subtract(b: base, from: tc)]

        case "benefitsAsPercent":
            guard let b = variables["benefitsValue"], let base = variables["baseSalary"], base > 0 else { return [] }
            return [.divide(a: b, by: base), .multiply(a: b / base, by: 100)]

        // MARK: - Salary: Side hustle
        case "effectiveHourlyRate":
            guard let earnings = variables["earnings"], let exp = variables["expenses"],
                  let hours = variables["hours"], hours > 0 else { return [] }
            let net = earnings - exp
            return [.subtract(b: exp, from: earnings),
                    .divide(a: net, by: hours)]

        case "simpleHourlyRate":
            guard let earnings = variables["earnings"], let hours = variables["hours"], hours > 0 else { return [] }
            return [.divide(a: earnings, by: hours)]

        case "sideVsDayJobGap":
            guard let s = variables["sideHourly"], let d = variables["dayHourly"] else { return [] }
            return [.subtract(b: s, from: d)]

        case "sideHustlePercentOfDayJob":
            guard let s = variables["sideHourly"], let sal = variables["annualSalary"], sal > 0 else { return [] }
            let dayHourly = sal / 2000
            return [.divide(a: sal, by: 2000),
                    .divide(a: s, by: dayHourly),
                    .multiply(a: s / dayHourly, by: 100)]

        case "sideHustleAnnualNet":
            guard let w = variables["weeklyEarnings"] else { return [] }
            return [.multiply(a: w, by: 50)]

        // MARK: - Debt: Balance transfer math (Phase 2 Batch 2c)
        case "balanceTransferFee":
            guard let balance = variables["balance"],
                  let feePct = variables["feePct"] else { return [] }
            return [.percentOf(pct: feePct, amount: balance)]

        case "interestSavedDuringPromo":
            guard let balance = variables["balance"],
                  let oldApr = variables["oldApr"],
                  let promoMonths = variables["promoMonths"] else { return [] }
            let yearlyInterest = balance * oldApr / 100
            return [.percentOf(pct: oldApr, amount: balance),
                    .divide(a: yearlyInterest, by: 12),
                    .multiply(a: yearlyInterest / 12, by: promoMonths)]

        case "balanceTransferNetWin":
            guard let balance = variables["balance"],
                  let oldApr = variables["oldApr"],
                  let promoMonths = variables["promoMonths"],
                  let feePct = variables["feePct"] else { return [] }
            let interestSaved = balance * oldApr / 100 * promoMonths / 12
            let fee = balance * feePct / 100
            return [.percentOf(pct: oldApr, amount: balance),
                    .multiply(a: balance * oldApr / 100 / 12, by: promoMonths),
                    .percentOf(pct: feePct, amount: balance),
                    .subtract(b: fee, from: interestSaved)]

        case "balanceTransferRequiredMonthly":
            guard let balance = variables["balance"],
                  let promoMonths = variables["promoMonths"], promoMonths > 0,
                  let feePct = variables["feePct"] else { return [] }
            let withFee = balance * (1 + feePct / 100)
            return [.percentOf(pct: feePct, amount: balance),
                    .divide(a: withFee, by: promoMonths)]

        // MARK: - Debt: CC payoff time (Phase 2 Batch 2c)
        case "payoffMonths":
            guard let balance = variables["balance"],
                  let apr = variables["apr"],
                  let _ = variables["monthlyPayment"] else { return [] }
            // Surface the mental-math approximation chain: monthly interest, principal slice, months ≈ balance / principal slice
            return [.percentOf(pct: apr / 12, amount: balance),
                    .divide(a: balance, by: 1)]

        case "principalAfterInterest":
            guard let balance = variables["balance"],
                  let apr = variables["apr"],
                  let payment = variables["monthlyPayment"] else { return [] }
            let monthlyInterest = balance * apr / 1200
            return [.percentOf(pct: apr / 12, amount: balance),
                    .subtract(b: monthlyInterest, from: payment)]

        // MARK: - Salary: 401(k) paycheck impact (Phase 2 Batch 2c)
        case "pretaxNetCost":
            guard let contribution = variables["contribution"],
                  let rate = variables["marginalRate"] else { return [] }
            let taxSaved = contribution * rate / 100
            return [.percentOf(pct: rate, amount: contribution),
                    .subtract(b: taxSaved, from: contribution)]

        case "pretaxTaxSaved":
            guard let contribution = variables["contribution"],
                  let rate = variables["marginalRate"] else { return [] }
            return [.percentOf(pct: rate, amount: contribution)]

        // MARK: - Investing reworks
        case "roiPercentDiff":
            guard let costA = variables["costA"], let gainA = variables["gainA"], costA > 0,
                  let costB = variables["costB"], let gainB = variables["gainB"], costB > 0 else { return [] }
            let roiA = gainA / costA * 100
            let roiB = gainB / costB * 100
            return [.divide(a: gainA, by: costA),
                    .divide(a: gainB, by: costB),
                    .subtract(b: min(roiA, roiB), from: max(roiA, roiB))]

        case "rothGrowthTaxSaved":
            guard let value = variables["finalValue"], let rate = variables["taxRate"] else { return [] }
            return [.percentOf(pct: rate, amount: value)]

        case "compoundPctInterest":
            guard let final = variables["finalValue"], let contributed = variables["totalContributed"], final > 0 else { return [] }
            return [.subtract(b: contributed, from: final),
                    .divide(a: final - contributed, by: final),
                    .multiply(a: (final - contributed) / final, by: 100)]

        case "compoundDifference":
            guard let a = variables["finalA"], let b = variables["finalB"] else { return [] }
            return [.subtract(b: min(a, b), from: max(a, b))]

        case "compoundBackwardsFromGoal":
            guard let goal = variables["goal"], let m = variables["multiplier"], m > 0 else { return [] }
            return [.divide(a: goal, by: m)]

        // MARK: - DCA
        case "dcaTotalInvested":
            guard let amt = variables["monthlyAmount"], let m = variables["months"] else { return [] }
            return [.multiply(a: amt, by: m)]

        case "sharesBought":
            guard let amt = variables["investmentAmount"], let p = variables["pricePerShare"], p > 0 else { return [] }
            return [.divide(a: amt, by: p)]

        case "dcaAverageCost":
            guard let t = variables["totalInvested"], let s = variables["totalShares"], s > 0 else { return [] }
            return [.divide(a: t, by: s)]

        case "dcaVsLumpSumSaving":
            guard let dca = variables["dcaCost"], let lump = variables["lumpCost"], let s = variables["shares"] else { return [] }
            return [.subtract(b: dca, from: lump), .multiply(a: lump - dca, by: s)]

        case "monthlyOverYears":
            guard let amt = variables["monthlyAmount"], let y = variables["years"] else { return [] }
            return [.multiply(a: amt, by: 12), .multiply(a: amt * 12, by: y)]

        // MARK: - Fund fees
        case "annualFundFee":
            guard let pv = variables["portfolioValue"], let er = variables["expenseRatio"] else { return [] }
            return [.percentOf(pct: er, amount: pv)]

        case "feeDifferenceAnnual":
            guard let pv = variables["portfolioValue"],
                  let ra = variables["expenseRatioA"],
                  let rb = variables["expenseRatioB"] else { return [] }
            return [.percentOf(pct: ra, amount: pv),
                    .percentOf(pct: rb, amount: pv),
                    .subtract(b: pv * rb / 100, from: pv * ra / 100)]

        case "feeCostOverYears":
            guard let pv = variables["portfolioValue"],
                  let ra = variables["expenseRatioA"],
                  let rb = variables["expenseRatioB"] else { return [] }
            let annual = pv * (ra - rb) / 100
            return [.subtract(b: rb, from: ra),
                    .percentOf(pct: ra - rb, amount: pv),
                    .multiply(a: annual, by: 10)]

        case "feeImpact30yr":
            guard let proj = variables["projectedBalance"], let ef = variables["extraFee"] else { return [] }
            return [.percentOf(pct: ef, amount: proj), .multiply(a: proj * ef / 100, by: 20)]

        // MARK: - Emergency fund
        case "essentialsMonthlyFour":
            guard let r = variables["rent"], let f = variables["food"],
                  let i = variables["insurance"], let t = variables["transport"] else { return [] }
            return [.add(a: r, b: f), .add(a: r + f, b: i), .add(a: r + f + i, b: t)]

        case "emergencyFundSixMonths":
            guard let e = variables["essentials"] else { return [] }
            return [.multiply(a: e, by: 6)]

        case "monthsOfRunway":
            guard let s = variables["savings"], let e = variables["essentials"], e > 0 else { return [] }
            return [.divide(a: s, by: e)]

        case "runwayGainFromCuts":
            guard let s = variables["savings"], let e = variables["essentials"],
                  let cut = variables["cutAmount"], e > cut else { return [] }
            let orig = (s / e).rounded(.down)
            let after = (s / (e - cut)).rounded(.down)
            return [.divide(a: s, by: e),
                    .subtract(b: cut, from: e),
                    .divide(a: s, by: e - cut),
                    .subtract(b: orig, from: after)]

        case "monthsToReachEFTarget":
            guard let target = variables["target"], let current = variables["currentSaved"],
                  let monthly = variables["monthlyContribution"], monthly > 0 else { return [] }
            return [.subtract(b: current, from: target),
                    .divide(a: target - current, by: monthly)]

        // MARK: - Rental yield
        case "grossRentalYield":
            guard let r = variables["monthlyRent"], let p = variables["propertyPrice"], p > 0 else { return [] }
            return [.multiply(a: r, by: 12), .divide(a: r * 12, by: p), .multiply(a: r * 12 / p, by: 100)]

        case "annualFromMonthlyRent":
            guard let r = variables["monthlyRent"] else { return [] }
            return [.multiply(a: r, by: 12)]

        case "yieldComparison":
            guard let pA = variables["priceA"], let rA = variables["rentA"], pA > 0,
                  let pB = variables["priceB"], let rB = variables["rentB"], pB > 0 else { return [] }
            let yA = rA * 12 / pA * 100
            let yB = rB * 12 / pB * 100
            return [.divide(a: rA * 12, by: pA),
                    .divide(a: rB * 12, by: pB),
                    .subtract(b: min(yA, yB), from: max(yA, yB))]

        case "netRentalYield":
            guard let r = variables["monthlyRent"], let p = variables["propertyPrice"], p > 0 else { return [] }
            return [.multiply(a: r, by: 12),
                    .multiply(a: r * 12, by: 0.82),
                    .divide(a: r * 12 * 0.82, by: p),
                    .multiply(a: r * 12 * 0.82 / p, by: 100)]

        case "requiredRentForYield":
            guard let p = variables["propertyPrice"], let y = variables["targetYield"] else { return [] }
            return [.percentOf(pct: y, amount: p), .divide(a: p * y / 100, by: 12)]

        // MARK: - Am I on track?
        case "savingsMultiple":
            guard let s = variables["currentSavings"], let sal = variables["currentSalary"], sal > 0 else { return [] }
            return [.divide(a: s, by: sal), .multiply(a: s / sal, by: 100)]

        case "savingsTargetByMultiple":
            guard let sal = variables["currentSalary"], let m = variables["targetMultiple"] else { return [] }
            return [.multiply(a: sal, by: m)]

        case "gapToSavingsTarget":
            guard let sal = variables["currentSalary"], let m = variables["targetMultiple"],
                  let saved = variables["currentSavings"] else { return [] }
            return [.multiply(a: sal, by: m), .subtract(b: saved, from: sal * m)]

        case "monthlyToCloseGap":
            guard let g = variables["gap"], let y = variables["years"], y > 0 else { return [] }
            return [.multiply(a: y, by: 12), .divide(a: g, by: y * 12)]

        case "extraMonthlyFromRateBump":
            guard let sal = variables["currentSalary"], let cur = variables["currentRate"], let tgt = variables["targetRate"] else { return [] }
            return [.subtract(b: cur, from: tgt),
                    .percentOf(pct: tgt - cur, amount: sal),
                    .divide(a: sal * (tgt - cur) / 100, by: 12)]

        // MARK: - Debt reworks
        case "interestTaxPercent":
            guard let loan = variables["loanAmount"], let pay = variables["monthlyPayment"], let m = variables["numMonths"], loan > 0 else { return [] }
            let totalInt = pay * m - loan
            return [.multiply(a: pay, by: m),
                    .subtract(b: loan, from: pay * m),
                    .divide(a: totalInt, by: loan),
                    .multiply(a: totalInt / loan, by: 100)]

        case "saveVsBorrowDiff":
            guard let pay = variables["monthlyPayment"], let m = variables["numMonths"], let cash = variables["purchasePrice"] else { return [] }
            return [.multiply(a: pay, by: m), .subtract(b: cash, from: pay * m)]

        case "newDTIwithPayment":
            guard let income = variables["monthlyIncome"], let cur = variables["currentDebt"],
                  let np = variables["newPayment"], income > 0 else { return [] }
            return [.add(a: cur, b: np), .divide(a: cur + np, by: income), .multiply(a: (cur + np) / income, by: 100)]

        case "principalReductionWithExtra":
            guard let bal = variables["balance"], let apr = variables["apr"], let total = variables["totalPayment"] else { return [] }
            let interest = bal * apr / 100 / 12
            return [.percentOf(pct: apr, amount: bal),
                    .divide(a: bal * apr / 100, by: 12),
                    .subtract(b: interest, from: total)]

        // MARK: - Avalanche vs Snowball
        case "aprDifference":
            guard let a = variables["aprA"], let b = variables["aprB"] else { return [] }
            return [.subtract(b: min(a, b), from: max(a, b))]

        case "monthlyInterestSavedByPriority":
            guard let e = variables["extraPayment"], let h = variables["highRate"], let l = variables["lowRate"] else { return [] }
            return [.subtract(b: l, from: h), .percentOf(pct: h - l, amount: e), .divide(a: e * (h - l) / 100, by: 12)]

        case "avalancheVsSnowballSaving":
            guard let e = variables["extraPayment"], let a = variables["aprA"], let b = variables["aprB"] else { return [] }
            return [.subtract(b: b, from: a), .percentOf(pct: a - b, amount: e)]

        case "psychologyPremium24mo":
            guard let m = variables["monthlySaving"] else { return [] }
            return [.multiply(a: m, by: 24)]

        // MARK: - APR vs APY
        case "apyFromApr":
            guard let apr = variables["apr"] else { return [] }
            // Approximation: APY ≈ APR + APR²/200 for monthly compounding
            return [.divide(a: apr, by: 12), .multiply(a: apr, by: apr / 200)]

        case "monthlyRatePctFromApr":
            guard let apr = variables["apr"] else { return [] }
            return [.divide(a: apr, by: 12)]

        case "trueCardRateDiff":
            guard let aprX = variables["aprX"], let apyY = variables["apyY"] else { return [] }
            return [.divide(a: aprX, by: 12), .subtract(b: min(aprX, apyY), from: max(aprX, apyY))]

        case "annualInterestViaApy":
            // Templates pass APY directly; mental math is a single "percent of"
            // step (e.g. 4.5% of $10,000), not a per-period compounding chain.
            guard let bal = variables["balance"], let apy = variables["apy"] else { return [] }
            return [.percentOf(pct: apy, amount: bal)]

        // MARK: - BNPL
        case "bnplTotal":
            guard let n = variables["numPayments"], let amt = variables["paymentAmount"] else { return [] }
            return [.multiply(a: n, by: amt)]

        case "bnplWithOneLateFee":
            guard let amt = variables["paymentAmount"] else { return [] }
            return [.multiply(a: 4, by: amt), .add(a: 4 * amt, b: 35)]

        case "bnplSurchargePercent":
            guard let orig = variables["originalPrice"], orig > 0 else { return [] }
            if let paid = variables["totalPaid"] {
                return [.subtract(b: orig, from: paid), .divide(a: paid - orig, by: orig), .multiply(a: (paid - orig) / orig, by: 100)]
            }
            // Default: $35 late fee divided by original price
            return [.divide(a: 35, by: orig), .multiply(a: 35 / orig, by: 100)]

        case "bnplStackedMonthly":
            guard let a = variables["paymentA"], let b = variables["paymentB"], let c = variables["paymentC"] else { return [] }
            return [.add(a: a, b: b), .add(a: a + b, b: c)]

        case "bnplAnnual":
            guard let m = variables["monthlyBnpl"] else { return [] }
            return [.multiply(a: m, by: 12)]

        // MARK: - Housing reworks
        case "minIncomeForRent":
            guard let r = variables["monthlyRent"] else { return [] }
            return [.divide(a: r, by: 0.28)]

        case "rentAboveAvgImpact":
            guard let r = variables["currentRent"], let i = variables["increasePercent"] else { return [] }
            return [.subtract(b: 4, from: i), .percentOf(pct: i - 4, amount: r)]

        case "monthsToRecoupMoving":
            guard let c = variables["movingCost"], let i = variables["monthlyIncrease"], i > 0 else { return [] }
            return [.divide(a: c, by: i)]

        case "mortgageRateFactor":
            guard let loan = variables["loanAmount"], let f = variables["factor"] else { return [] }
            return [.multiply(a: loan, by: f)]

        case "mortgageRateDiff":
            guard let loan = variables["loanAmount"] else { return [] }
            return [.multiply(a: loan, by: 0.0013)]

        case "mortgageWithTaxAndInsurance":
            guard let loan = variables["loanAmount"], let f = variables["factor"], let ti = variables["taxAndInsurance"] else { return [] }
            return [.multiply(a: loan, by: f), .add(a: loan * f, b: ti)]

        case "mortgageVsRentMonthlyDiff":
            guard let rent = variables["monthlyRent"], let loan = variables["loanAmount"],
                  let f = variables["factor"], let ti = variables["taxAndInsurance"] else { return [] }
            let mort = loan * f + ti
            return [.multiply(a: loan, by: f), .add(a: loan * f, b: ti),
                    .subtract(b: min(rent, mort), from: max(rent, mort))]

        // MARK: - Housing: Affordability (Phase 2 Batch 2c)
        case "maxPitiFromGross":
            guard let monthlyGross = variables["monthlyGross"] else { return [] }
            return [.percentOf(pct: 28, amount: monthlyGross)]

        case "loanFromPAndI":
            guard let pAndI = variables["pAndI"], let f = variables["factor"], f > 0 else { return [] }
            return [.divide(a: pAndI, by: f)]

        case "monthlyPMI":
            guard let loan = variables["loanAmount"], let pmiPct = variables["pmiPct"] else { return [] }
            let annual = loan * pmiPct / 100
            return [.percentOf(pct: pmiPct, amount: loan),
                    .divide(a: annual, by: 12)]

        case "minIncomeForPrice":
            guard let price = variables["purchasePrice"],
                  let downPct = variables["downPct"],
                  let f = variables["factor"] else { return [] }
            let loan = price * (1 - downPct / 100)
            let pAndI = loan * f
            let monthlyTaxIns = price * 0.015 / 12
            let piti = pAndI + monthlyTaxIns
            return [.subtract(b: price * downPct / 100, from: price),
                    .multiply(a: loan, by: f),
                    .add(a: pAndI, b: monthlyTaxIns),
                    .divide(a: piti, by: 0.28)]

        // MARK: - Roommate
        case "halfOfRent":
            guard let r = variables["sharedRent"] else { return [] }
            return [.divide(a: r, by: 2)]

        case "roommateSavingWithUtilities":
            guard let sr = variables["soloRent"], let su = variables["soloUtilities"],
                  let shr = variables["sharedRent"], let shu = variables["sharedUtilities"] else { return [] }
            return [.add(a: sr, b: su), .add(a: shr, b: shu),
                    .divide(a: shr + shu, by: 2),
                    .subtract(b: (shr + shu) / 2, from: sr + su)]

        case "smallerShareRent":
            guard let r = variables["sharedRent"], let big = variables["bigShare"] else { return [] }
            return [.subtract(b: big, from: 100), .percentOf(pct: 100 - big, amount: r)]

        case "monthlyToAnnualSimple":
            guard let m = variables["monthlySaving"] else { return [] }
            return [.multiply(a: m, by: 12)]

        case "roommateAnnualSaving":
            guard let solo = variables["soloRent"], let shared = variables["sharedRent"] else { return [] }
            let monthly = solo - shared / 2
            return [.divide(a: shared, by: 2), .subtract(b: shared / 2, from: solo), .multiply(a: monthly, by: 12)]

        // MARK: - True cost
        case "trueHousingCost":
            guard let r = variables["rent"], let u = variables["utilities"],
                  let i = variables["insurance"], let p = variables["parking"] else { return [] }
            return [.add(a: r, b: u), .add(a: r + u, b: i), .add(a: r + u + i, b: p)]

        case "housingExtraBeyondRent":
            guard let tc = variables["trueCost"], let r = variables["rent"] else { return [] }
            return [.subtract(b: r, from: tc)]

        case "trueHousingDiff":
            guard let rA = variables["rentA"], let aA = variables["addonsA"],
                  let rB = variables["rentB"], let aB = variables["addonsB"] else { return [] }
            let tA = rA + aA
            let tB = rB + aB
            return [.add(a: rA, b: aA), .add(a: rB, b: aB),
                    .subtract(b: min(tA, tB), from: max(tA, tB))]

        case "trueCostExtraPct":
            guard let r = variables["rent"], let tc = variables["trueCost"], r > 0 else { return [] }
            return [.subtract(b: r, from: tc), .divide(a: tc - r, by: r), .multiply(a: (tc - r) / r, by: 100)]

        case "housingPctOfIncome":
            guard let i = variables["monthlyIncome"], let tc = variables["trueCost"], i > 0 else { return [] }
            return [.divide(a: tc, by: i), .multiply(a: tc / i, by: 100)]

        // MARK: - Lease break
        case "leaseBreakFeeOnly":
            guard let m = variables["monthsPenalty"], let r = variables["monthlyRent"] else { return [] }
            return [.multiply(a: m, by: r)]

        case "leaseBreakTotalCost":
            guard let m = variables["monthsPenalty"], let r = variables["monthlyRent"], let mc = variables["movingCost"] else { return [] }
            return [.multiply(a: m, by: r), .add(a: m * r, b: mc)]

        case "leaseBreakeven":
            guard let t = variables["totalBreakCost"], let s = variables["monthlySaving"], s > 0 else { return [] }
            return [.divide(a: t, by: s)]

        case "leaseStaySavings":
            guard let ml = variables["monthsLeft"], let tc = variables["totalBreakCost"], let s = variables["monthlySaving"] else { return [] }
            return [.multiply(a: ml, by: s), .subtract(b: ml * s, from: tc)]

        case "leaseBreakNetCost":
            guard let ml = variables["monthsLeft"], let cr = variables["currentRent"], let nr = variables["newRent"],
                  let bf = variables["breakFee"], let mc = variables["movingCost"] else { return [] }
            let breakTotal = bf + mc
            let savings = ml * (cr - nr)
            return [.add(a: bf, b: mc), .subtract(b: nr, from: cr),
                    .multiply(a: ml, by: cr - nr),
                    .subtract(b: savings, from: breakTotal)]

        // MARK: - Taxes reworks
        case "refundMonthlyLoan":
            guard let r = variables["refundAmount"] else { return [] }
            return [.divide(a: r, by: 12)]

        case "refundInvestedGain":
            guard let r = variables["refundAmount"] else { return [] }
            return [.percentOf(pct: 3, amount: r)]

        case "annualOverWithholding":
            guard let w = variables["monthlyWithheld"], let o = variables["monthlyOwed"] else { return [] }
            return [.subtract(b: o, from: w), .multiply(a: w - o, by: 12)]

        case "quarterlyEstimatedTax":
            guard let i = variables["quarterlyIncome"], let inc = variables["incomeTaxPct"] else { return [] }
            return [.multiply(a: i, by: 0.9235),
                    .percentOf(pct: 15.3, amount: i * 0.9235),
                    .percentOf(pct: inc, amount: i),
                    .add(a: i * 0.9235 * 0.153, b: i * inc / 100)]

        // MARK: - Standard vs Itemized
        case "itemizedTotal":
            guard let m = variables["mortgageInt"], let s = variables["stateTax"], let c = variables["charity"] else { return [] }
            return [.add(a: m, b: s), .add(a: m + s, b: c)]

        case "itemizedExcess":
            guard let i = variables["itemizedAmount"], let s = variables["standardAmount"] else { return [] }
            return [.subtract(b: s, from: i)]

        case "itemizedSavingDollars":
            guard let e = variables["excessAmount"], let r = variables["taxRate"] else { return [] }
            return [.percentOf(pct: r, amount: e)]

        case "itemizedDecisionSaving":
            guard let m = variables["mortgageInt"], let s = variables["stateTax"], let c = variables["charity"],
                  let r = variables["taxRate"] else { return [] }
            let itemized = m + s + c
            return [.add(a: m, b: s), .add(a: m + s, b: c),
                    .subtract(b: 15750, from: itemized),
                    .percentOf(pct: r, amount: max(0, itemized - 15750))]

        case "itemizedLifetime":
            guard let a = variables["annualSaving"], let y = variables["years"] else { return [] }
            return [.multiply(a: a, by: y)]

        // MARK: - Capital Gains
        case "shortTermCapGainsTax":
            guard let g = variables["gain"], let r = variables["ordinaryRate"] else { return [] }
            return [.percentOf(pct: r, amount: g)]

        case "longTermCapGainsTax":
            guard let g = variables["gain"], let r = variables["ltcgRate"] else { return [] }
            return [.percentOf(pct: r, amount: g)]

        case "capGainsTimingSaving":
            guard let g = variables["gain"], let o = variables["ordinaryRate"], let l = variables["ltcgRate"] else { return [] }
            return [.subtract(b: l, from: o), .percentOf(pct: o - l, amount: g)]

        case "capGainsTaxDifference":
            guard let gA = variables["gainA"], let o = variables["ordinaryRate"],
                  let gB = variables["gainB"], let l = variables["ltcgRate"] else { return [] }
            let taxA = gA * o / 100
            let taxB = gB * l / 100
            return [.percentOf(pct: o, amount: gA), .percentOf(pct: l, amount: gB),
                    .subtract(b: min(taxA, taxB), from: max(taxA, taxB))]

        // MARK: - W-4 Adjust
        case "w4MonthlyBump":
            guard let r = variables["refundAmount"] else { return [] }
            return [.divide(a: r, by: 12)]

        case "w4BiweeklyBump":
            guard let r = variables["refundAmount"] else { return [] }
            return [.divide(a: r, by: 26)]

        case "w4AnnualInvested":
            guard let b = variables["biweeklyBump"] else { return [] }
            return [.multiply(a: b, by: 26), .multiply(a: b * 26, by: 1.03)]

        case "w4RefundGain":
            guard let r = variables["refundAmount"] else { return [] }
            return [.percentOf(pct: 3, amount: r)]

        case "w4LifetimeGain":
            guard let r = variables["refundAmount"], let y = variables["years"] else { return [] }
            return [.percentOf(pct: 3, amount: r), .multiply(a: r * 0.03, by: y)]

        // MARK: - Insurance reworks
        case "insuranceExposureRange":
            return [.subtract(b: 0, from: variables["deductible"] ?? 0)]  // trivial

        case "erVisitCost":
            guard let total = variables["totalBill"], let ded = variables["deductible"],
                  let paid = variables["deductibleSoFar"], let coins = variables["coinsurancePercent"] else { return [] }
            let remainingDed = max(0, ded - paid)
            let postDed = max(0, total - ded)
            return [.subtract(b: paid, from: ded),
                    .subtract(b: ded, from: total),
                    .percentOf(pct: coins, amount: postDed),
                    .add(a: remainingDed, b: postDed * coins / 100)]

        case "copayVsCoinsuranceDiff":
            guard let cost = variables["visitCost"], let copay = variables["copayAmount"], let coins = variables["coinsurancePercent"] else { return [] }
            let coinAmt = cost * coins / 100
            return [.percentOf(pct: coins, amount: cost),
                    .subtract(b: min(copay, coinAmt), from: max(copay, coinAmt))]

        case "hdhpPpoVisitsBreakeven":
            guard let hp = variables["hdhpPremium"], let hv = variables["hdhpVisitCost"],
                  let pp = variables["ppoPremium"], let pc = variables["ppoCopay"] else { return [] }
            let saving = (pp - hp) * 12
            let gap = hv - pc
            guard gap > 0 else { return [] }
            return [.subtract(b: hp, from: pp), .multiply(a: pp - hp, by: 12),
                    .subtract(b: pc, from: hv), .divide(a: saving, by: gap)]

        case "hsaRetirementTaxSaved":
            guard let m = variables["medicalAmount"], let r = variables["taxRate"] else { return [] }
            return [.percentOf(pct: r, amount: m)]

        // MARK: - FSA
        case "fsaTaxSavings":
            guard let e = variables["fsaElection"], let r = variables["taxRate"] else { return [] }
            return [.percentOf(pct: r, amount: e)]

        case "fsaNetResult":
            guard let e = variables["fsaElection"], let r = variables["taxRate"], let s = variables["actualSpent"] else { return [] }
            let saved = e * r / 100
            let forfeit = e - s
            return [.percentOf(pct: r, amount: e), .subtract(b: s, from: e),
                    .subtract(b: forfeit, from: saved)]

        case "fsaBreakevenSpend":
            guard let e = variables["fsaElection"], let r = variables["taxRate"] else { return [] }
            return [.subtract(b: r, from: 100), .percentOf(pct: 100 - r, amount: e)]

        case "fsaElectionDiffSaving":
            guard let a = variables["electionA"], let b = variables["electionB"], let r = variables["taxRate"] else { return [] }
            return [.subtract(b: min(a, b), from: max(a, b)), .percentOf(pct: r, amount: abs(a - b))]

        case "fsaMaxAdditional":
            guard let s = variables["guaranteedSpend"], let r = variables["taxRate"], r < 100 else { return [] }
            return [.subtract(b: r, from: 100), .divide(a: r, by: 100 - r), .multiply(a: s, by: r / (100 - r))]

        // MARK: - Life Insurance
        case "lifeBaseline10x":
            guard let s = variables["annualSalary"] else { return [] }
            return [.multiply(a: s, by: 10)]

        case "lifeAdjustedCoverage":
            guard let s = variables["annualSalary"], let m = variables["mortgageBalance"], let sv = variables["savings"] else { return [] }
            return [.multiply(a: s, by: 10), .add(a: s * 10, b: m), .subtract(b: sv, from: s * 10 + m)]

        case "lifeAnnualDiff":
            guard let pA = variables["premiumA"], let pB = variables["premiumB"] else { return [] }
            return [.subtract(b: pA, from: pB), .multiply(a: pB - pA, by: 12)]

        case "lifeCostPer100k":
            guard let c = variables["coverage"], let p = variables["premium"], c > 0 else { return [] }
            return [.multiply(a: p, by: 12), .divide(a: c, by: 100000), .divide(a: p * 12, by: c / 100000)]

        case "lifeLifetimeCost":
            guard let p = variables["monthlyPremium"] else { return [] }
            return [.multiply(a: p, by: 360)]

        // MARK: - Prescription
        case "rxAnnualSaving":
            guard let b = variables["brandCopay"], let g = variables["genericCopay"] else { return [] }
            return [.subtract(b: g, from: b), .multiply(a: b - g, by: 12)]

        case "rxMultipleSaving":
            guard let c1 = variables["copay1"], let g1 = variables["generic1"],
                  let c2 = variables["copay2"], let g2 = variables["generic2"] else { return [] }
            let total = (c1 - g1) + (c2 - g2)
            return [.subtract(b: g1, from: c1), .subtract(b: g2, from: c2), .multiply(a: total, by: 12)]

        case "rxGoodrxSaving":
            guard let b = variables["brandCopay"], let g = variables["goodrxPrice"] else { return [] }
            return [.subtract(b: g, from: b), .multiply(a: b - g, by: 12)]

        case "rxMonthlyDiff":
            guard let b = variables["brandCopay"], let g = variables["genericCopay"] else { return [] }
            return [.subtract(b: g, from: b)]

        case "rxLifetimeSaving":
            guard let m = variables["monthlyDiff"], let y = variables["years"] else { return [] }
            return [.multiply(a: m, by: 12), .multiply(a: m * 12, by: y)]

        // MARK: - Car reworks
        case "carTermExtraCost":
            guard let p48 = variables["payment48"], let p72 = variables["payment72"] else { return [] }
            return [.multiply(a: p48, by: 48), .multiply(a: p72, by: 72),
                    .subtract(b: p48 * 48, from: p72 * 72)]

        case "interestSavingFromDownPayment":
            guard let i = variables["totalInterest"], let li = variables["lowerInterest"] else { return [] }
            return [.subtract(b: li, from: i)]

        case "carTotalCost3yr":
            guard let p = variables["carPrice"], let dep = variables["depPercent"], let ops = variables["monthlyOps"] else { return [] }
            return [.percentOf(pct: dep, amount: p), .multiply(a: ops, by: 36),
                    .add(a: p * dep / 100, b: ops * 36)]

        // MARK: - Car TCO
        case "carMonthlyOwnership":
            guard let p = variables["payment"], let i = variables["insurance"],
                  let g = variables["gas"], let m = variables["maintenance"] else { return [] }
            return [.add(a: p, b: i), .add(a: p + i, b: g), .add(a: p + i + g, b: m)]

        case "tcoMonthlyDifference":
            guard let pA = variables["paymentA"], let oA = variables["opsA"],
                  let pB = variables["paymentB"], let oB = variables["opsB"] else { return [] }
            let tA = pA + oA, tB = pB + oB
            return [.add(a: pA, b: oA), .add(a: pB, b: oB),
                    .subtract(b: min(tA, tB), from: max(tA, tB))]

        case "keepVsBuyDiff":
            guard let mk = variables["maintenanceKeep"], let ik = variables["insuranceKeep"], let gk = variables["gasKeep"],
                  let pn = variables["paymentNew"], let on = variables["opsNew"] else { return [] }
            let keep = mk + ik + gk
            let buy = pn + on
            return [.add(a: mk, b: ik), .add(a: pn, b: on), .subtract(b: keep, from: buy)]

        case "carPctOfIncome":
            guard let inc = variables["monthlyIncome"], let tco = variables["tcoMonthly"], inc > 0 else { return [] }
            return [.divide(a: tco, by: inc), .multiply(a: tco / inc, by: 100)]

        case "tcoAnnual":
            guard let m = variables["tcoMonthly"] else { return [] }
            return [.multiply(a: m, by: 12)]

        // MARK: - Car Lease vs Buy
        case "leaseTotalSpent":
            guard let m = variables["monthlyLease"], let mo = variables["months"] else { return [] }
            return [.multiply(a: m, by: mo)]

        case "buyNetCost":
            guard let p = variables["monthlyPayment"], let m = variables["months"], let r = variables["residualValue"] else { return [] }
            return [.multiply(a: p, by: m), .subtract(b: r, from: p * m)]

        case "leaseVsBuy3yrDiff":
            guard let l = variables["monthlyLease"], let p = variables["monthlyPayment"], let r = variables["residualValue"] else { return [] }
            let lease = l * 36
            let buyNet = p * 36 - r
            return [.multiply(a: l, by: 36), .multiply(a: p, by: 36), .subtract(b: r, from: p * 36),
                    .subtract(b: min(lease, buyNet), from: max(lease, buyNet))]

        case "leaseMonthlyFromTotal":
            guard let t = variables["leaseTotal"] else { return [] }
            return [.divide(a: t, by: 36)]

        case "leaseVsBuyLifetime":
            guard let l = variables["leasePerCar"], let p = variables["carPrice"] else { return [] }
            return [.multiply(a: l, by: 3.33), .subtract(b: min(l * 3.33, p), from: max(l * 3.33, p))]

        // MARK: - Car Trade-in
        case "tradeInPremium":
            guard let t = variables["tradeInOffer"], let p = variables["privatePrice"] else { return [] }
            return [.subtract(b: t, from: p)]

        case "tradeInHourlyValue":
            guard let pr = variables["premium"], let h = variables["hours"], h > 0 else { return [] }
            return [.divide(a: pr, by: h)]

        case "tradeInTaxBenefit":
            guard let t = variables["tradeInOffer"], let r = variables["taxRate"] else { return [] }
            return [.percentOf(pct: r, amount: t)]

        case "tradeInAdjustedPremium":
            guard let p = variables["privatePrice"], let t = variables["tradeInOffer"], let ts = variables["taxSaving"] else { return [] }
            return [.subtract(b: t, from: p), .subtract(b: ts, from: p - t)]

        case "tradeInHourlyAdjusted":
            guard let p = variables["privatePrice"], let t = variables["tradeInOffer"],
                  let ts = variables["taxSaving"], let h = variables["hours"], h > 0 else { return [] }
            let adjusted = (p - t) - ts
            return [.subtract(b: t, from: p), .subtract(b: ts, from: p - t), .divide(a: adjusted, by: h)]

        // MARK: - SL Rule of Thumb
        case "slRuleOfThumb110":
            guard let b = variables["loanBalance"] else { return [] }
            return [.divide(a: b, by: 10000), .multiply(a: b / 10000, by: 110)]

        case "slCustomPer10k":
            guard let b = variables["loanBalance"], let r = variables["paymentPer10k"] else { return [] }
            return [.divide(a: b, by: 10000), .multiply(a: b / 10000, by: r)]

        case "slPaymentRange":
            guard let b = variables["loanBalance"] else { return [] }
            return [.divide(a: b, by: 10000), .multiply(a: b / 10000, by: 20)]

        case "slEstByApr":
            guard let b = variables["loanBalance"], let apr = variables["apr"] else { return [] }
            let f: Double = apr <= 5 ? 105 : 115
            return [.divide(a: b, by: 10000), .multiply(a: b / 10000, by: f)]

        case "slInterestPercent":
            guard let loan = variables["loanAmount"], let paid = variables["totalPaid"], loan > 0 else { return [] }
            return [.subtract(b: loan, from: paid), .divide(a: paid - loan, by: loan), .multiply(a: (paid - loan) / loan, by: 100)]

        case "refiVsPslfDiff120":
            guard let refi = variables["refiPayment"], let pslf = variables["pslfPayment"] else { return [] }
            return [.subtract(b: pslf, from: refi), .multiply(a: refi - pslf, by: 120)]

        // MARK: - SL Employer Benefit
        case "annualToMonthlySimple":
            guard let a = variables["annualBenefit"] else { return [] }
            return [.divide(a: a, by: 12)]

        case "employerBenefitMultiYear":
            guard let a = variables["annualBenefit"], let y = variables["years"] else { return [] }
            return [.multiply(a: a, by: y)]

        case "employerInterestSaving":
            guard let a = variables["annualBenefit"], let y = variables["years"], let r = variables["interestRate"] else { return [] }
            return [.multiply(a: a, by: y), .percentOf(pct: r, amount: a * y), .multiply(a: a * y * r / 100, by: 0.5)]

        case "employerBenefitGrossUp":
            guard let a = variables["annualBenefit"], let r = variables["taxRate"], r < 100 else { return [] }
            return [.subtract(b: r, from: 100), .divide(a: a, by: 1 - r / 100)]

        case "employerBenefitLifetimeValue":
            guard let a = variables["annualBenefit"], let y = variables["years"], let r = variables["taxRate"], r < 100 else { return [] }
            let grossed = a / (1 - r / 100)
            return [.divide(a: a, by: 1 - r / 100), .multiply(a: grossed, by: y)]

        // MARK: - SL Grace Period
        case "dailyInterest":
            guard let b = variables["balance"], let r = variables["interestRate"] else { return [] }
            return [.percentOf(pct: r, amount: b), .divide(a: b * r / 100, by: 365)]

        case "gracePeriodTotal":
            guard let d = variables["dailyAmount"] else { return [] }
            return [.multiply(a: d, by: 180)]

        case "gracePeriodFullSaving":
            guard let a = variables["accruedAmount"] else { return [] }
            return [.multiply(a: a, by: 1.05)]

        case "balanceAfterGrace":
            guard let b = variables["originalBalance"], let r = variables["interestRate"] else { return [] }
            return [.percentOf(pct: r, amount: b), .multiply(a: b * r / 100, by: 0.5), .add(a: b, b: b * r / 100 * 0.5)]

        case "gracePeriodLifetimeImpact":
            guard let a = variables["accruedAmount"], let r = variables["interestRate"] else { return [] }
            return [.percentOf(pct: r, amount: a), .multiply(a: a * r / 100, by: 5)]

        // MARK: - SL Parent PLUS
        case "plusVsPrivateAnnualInterest":
            guard let b = variables["loanBalance"], let p = variables["plusRate"], let pr = variables["privateRate"] else { return [] }
            return [.subtract(b: pr, from: p), .percentOf(pct: p - pr, amount: b)]

        case "plusVsPrivate10yr":
            guard let b = variables["loanBalance"], let p = variables["plusRate"], let pr = variables["privateRate"] else { return [] }
            return [.subtract(b: pr, from: p), .percentOf(pct: p - pr, amount: b), .multiply(a: b * (p - pr) / 100, by: 10)]

        case "plusOriginationFee":
            guard let b = variables["loanBalance"] else { return [] }
            return [.percentOf(pct: 4.228, amount: b)]

        case "plusVsPrivateTotalWithOrigination":
            guard let b = variables["loanBalance"], let pr = variables["privateRate"] else { return [] }
            // 8.94% = Parent PLUS rate, 2025-26 academic year.
            return [.subtract(b: pr, from: 8.94), .percentOf(pct: 8.94 - pr, amount: b),
                    .multiply(a: b * (8.94 - pr) / 100, by: 10),
                    .percentOf(pct: 4.228, amount: b)]

        case "plusVsPrivateMonthlyInterest":
            guard let b = variables["loanBalance"], let pr = variables["privateRate"] else { return [] }
            // 8.94% = Parent PLUS rate, 2025-26 academic year.
            return [.subtract(b: pr, from: 8.94), .percentOf(pct: 8.94 - pr, amount: b),
                    .divide(a: b * (8.94 - pr) / 100, by: 12)]

        // MARK: - Salary: RSUs (Phase 3 Batch 3b)
        case "rsuGrossValue":
            guard let shares = variables["sharesVested"], let price = variables["sharePrice"] else { return [] }
            return [.multiply(a: shares, by: price)]

        case "rsuNetValue":
            guard let shares = variables["sharesVested"],
                  let price = variables["sharePrice"],
                  let rate = variables["marginalRate"] else { return [] }
            let gross = shares * price
            return [.multiply(a: shares, by: price),
                    .percentOf(pct: rate, amount: gross),
                    .subtract(b: gross * rate / 100, from: gross)]

        case "rsuUnderwithholding":
            guard let value = variables["vestValue"], let rate = variables["marginalRate"] else { return [] }
            return [.subtract(b: 22, from: rate),
                    .percentOf(pct: rate - 22, amount: value)]

        case "rsuYearOneVestValue":
            guard let total = variables["totalShares"], let price = variables["sharePrice"] else { return [] }
            return [.divide(a: total, by: 4),
                    .multiply(a: total / 4, by: price)]

        // MARK: - Investing: ESPP (Phase 3 Batch 3b)
        case "esppGain":
            guard let contribution = variables["contribution"], let discount = variables["discount"], discount < 100 else { return [] }
            return [.subtract(b: discount, from: 100),
                    .divide(a: contribution * discount, by: 100 - discount)]

        case "esppLookbackGain":
            guard let contribution = variables["contribution"],
                  let startPrice = variables["startPrice"],
                  let endPrice = variables["endPrice"],
                  let discount = variables["discount"] else { return [] }
            let lookback = min(startPrice, endPrice)
            let purchase = lookback * (1 - discount / 100)
            guard purchase > 0 else { return [] }
            let shares = contribution / purchase
            return [.percentOf(pct: discount, amount: lookback),
                    .divide(a: contribution, by: purchase),
                    .subtract(b: purchase, from: endPrice),
                    .multiply(a: shares, by: endPrice - purchase)]

        // MARK: - Debt: Credit-card utilization (Phase 3 Batch 3b)
        case "cardUtilization":
            guard let balance = variables["balanceAtStatement"], let limit = variables["creditLimit"], limit > 0 else { return [] }
            return [.divide(a: balance, by: limit)]

        case "utilizationMaxBalance":
            guard let limit = variables["creditLimit"], let target = variables["targetPct"] else { return [] }
            return [.percentOf(pct: target, amount: limit)]

        case "multiCardUtilization":
            guard let bA = variables["balanceA"], let lA = variables["limitA"],
                  let bB = variables["balanceB"], let lB = variables["limitB"],
                  (lA + lB) > 0 else { return [] }
            return [.add(a: bA, b: bB),
                    .add(a: lA, b: lB),
                    .divide(a: bA + bB, by: lA + lB)]

        default:
            return []
        }
    }
}
