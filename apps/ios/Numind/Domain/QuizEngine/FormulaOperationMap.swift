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
            guard let rate = variables["interestRate"], rate > 0 else { return [] }
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
            return [.percentOf(pct: 15.3, amount: income)]

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

        default:
            return []
        }
    }
}
