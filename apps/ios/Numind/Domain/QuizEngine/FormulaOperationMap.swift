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

        // MARK: - Estimation

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

        // MARK: - Travel Money

        case "foreignToUSD":
            guard let foreign = variables["foreignAmount"],
                  let rate = variables["exchangeRate"] else { return [] }
            return [.multiply(a: foreign, by: rate)]

        case "usdToForeign":
            guard let usd = variables["usdAmount"],
                  let rate = variables["foreignRate"] else { return [] }
            return [.multiply(a: usd, by: rate)]

        case "currencyMarkupCost":
            guard let amount = variables["convertAmount"],
                  let markup = variables["markupPercent"] else { return [] }
            return [.percentOf(pct: markup, amount: amount)]

        case "foreignTransactionFee":
            guard let purchase = variables["purchaseAmount"],
                  let fee = variables["feePercent"] else { return [] }
            return [.percentOf(pct: fee, amount: purchase)]

        case "totalWithForeignFee":
            guard let purchase = variables["purchaseAmount"],
                  let fee = variables["feePercent"] else { return [] }
            let feeAmount = purchase * fee / 100
            return [.percentOf(pct: fee, amount: purchase),
                    .add(a: purchase, b: feeAmount)]

        case "splitTravelCost":
            guard let total = variables["totalCost"],
                  let people = variables["numPeople"], people > 0 else { return [] }
            return [.divide(a: total, by: people)]

        case "daysOnBudget":
            guard let budget = variables["travelBudget"],
                  let daily = variables["dailyCost"], daily > 0 else { return [] }
            return [.divide(a: budget, by: daily)]

        case "hotelCostPerNight":
            guard let total = variables["hotelTotal"],
                  let nights = variables["numNights"], nights > 0 else { return [] }
            return [.divide(a: total, by: nights)]

        case "travelInsuranceCost":
            guard let trip = variables["tripCost"],
                  let pct = variables["insurancePercent"] else { return [] }
            return [.percentOf(pct: pct, amount: trip)]

        case "tripTotalWithInsurance":
            guard let trip = variables["tripCost"],
                  let pct = variables["insurancePercent"] else { return [] }
            let insurance = trip * pct / 100
            return [.percentOf(pct: pct, amount: trip),
                    .add(a: trip, b: insurance)]

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

        default:
            return []
        }
    }
}
