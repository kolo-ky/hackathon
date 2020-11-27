// хелперы
func getValueFromActions(_ expression: UserActions) -> Float? {
     switch expression {
         case let .withdrawingCashFromBankDeposit(cash):
            return cash
         case let .replenishmentBankDepositInCash(cash):
            return cash
         case let .toUpBalancePhone(toUp):
            return toUp
         default: return nil
     }
}

// Абстракция данных пользователя
protocol UserData {
  var userName: String { get }    //Имя пользователя
  var userCardId: String { get }   //Номер карты
  var userCardPin: Int { get }       //Пин-код
  var userCash: Float { get set}   //Наличные пользователя
  var userBankDeposit: Float { get set}   //Банковский депозит
  var userPhone: String { get }       //Номер телефона
  var userPhoneBalance: Float { get set}    //Баланс телефона
}

// Протокол по работе с банком предоставляет доступ к данным пользователя зарегистрированного в банке
protocol BankApi {
    func doAction(userCardId: String, userCardPin: Int, actions: UserActions, userPhoneNumber: String, payment: PaymentMethod?)
    func showUserBalance()
    func showUserToppedUpMobilePhoneCash(cash: Float)
    func showUserToppedUpMobilePhoneDeposite(deposit: Float)
    func showWithdrawalDeposit(cash: Float)
    func showTopUpAccount(cash: Float)
    func showError(error: TextErrors)

    func checkUserPhone(phone: String) -> Bool
    func checkMaxUserCash(cash: Float) -> Bool
    func checkMaxAccountDeposit(withdraw: Float) -> Bool
    func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool

    mutating func topUpPhoneBalanceCash(pay: Float)
    mutating func topUpPhoneBalanceDeposit(pay: Float)
    mutating func getCashFromDeposit(cash: Float)
    mutating func putCashDeposit(topUp: Float)
}

// Тексты ошибок
enum TextErrors: String {
    case wrongPinOrCard = "Неверный пин-код или номер карты"
    case insufficientFunds = "Недостаточно средств на счете"
    case wrongCashLimit = "Недостаточно средств для пополнения депозита. Попробуйте снова, когда получите зарплату"
    case wrongPaymentMethod = "Выберите способ оплаты"
    case wrongPhoneNumber = "Неверный номер телефона"
}
 
// Виды операций, выбранных пользователем (подтверждение выбора)
enum DescriptionTypesAvailableOperations: String {
    case balanceOnBankDeposit = "Запрос баланса"
    case withdrawingCashFromBankDeposit = "Снятие наличных"
    case replenishmentBankDepositInCash = "Пополнение банковского депозита наличными"
    case phoneBalanceInCash = "Пополнение баланса телефона наличными"
    case phoneBalanceFromBankDeposit = "Пополнение баланса телефона с банковского депозита"
}
 
// Действия, которые пользователь может выбирать в банкомате (имитация кнопок)
enum UserActions {
    case balanceOnBankDeposit //запрос баланса на банковском депозите
    case withdrawingCashFromBankDeposit(cash: Float) //снятие наличных с банковского депозита
    case replenishmentBankDepositInCash(cash: Float) //пополнение банковского депозита наличными
    case toUpBalancePhone(toUp: Float) //пополнение баланса телефона наличными
}
 
// Способ оплаты/пополнения наличными или через депозит
enum PaymentMethod {
    case inCash //наличными
    case bankDeposit //через депозит
}

class User: UserData {
    let userName: String   //Имя пользователя
    let userCardId: String  //Номер карты
    let userCardPin: Int       //Пин-код
    var userCash: Float   //Наличные пользователя
    var userBankDeposit: Float   //Банковский депозит
    let userPhone: String      //Номер телефона
    var userPhoneBalance: Float //Баланс телефона
    
    init(userName: String, userCardId: String, userCardPin: Int, userCash: Float, userBankDeposit: Float, userPhone: String, userPhoneBalance: Float) {
        self.userName = userName
        self.userCardId = userCardId
        self.userCardPin = userCardPin
        self.userCash = userCash
        self.userBankDeposit = userBankDeposit
        self.userPhone = userPhone
        self.userPhoneBalance = userPhoneBalance
    }
}

class BankServer: BankApi {
    private var user: UserData
    
    func showUserBalance() {
        print("Вы выбрали операцию '\(DescriptionTypesAvailableOperations.balanceOnBankDeposit.rawValue)', ваш баланс: \(user.userBankDeposit) рублей")
    }
    func showUserToppedUpMobilePhoneCash(cash: Float){
        print("Баланс вашего телефона пополнен, на счету телефона: \(cash) рублей. Ваш Билайн")
    }
    func showUserToppedUpMobilePhoneDeposite(deposit: Float){
        print("Баланс вашего телефона пополнен, на счету телефона: \(deposit) рублей. Ваш Билайн")
    }
    func showWithdrawalDeposit(cash: Float){
        print("Вы пополнили баланс наличными на суммк \(cash) рублей")
        print("теперь на вашем балансе \(user.userBankDeposit) рублей")
        print("а в кармане \(user.userCash) рублей")
    }
    func showTopUpAccount(cash: Float){
        print("Вы сняли наличные с депозита в размере \(cash) рублей")
        print("теперь на вашем балансе \(user.userBankDeposit) рублей")
        print("а в кармане \(user.userCash) рублей")
    }
    func showError(error: TextErrors){
        print(error.rawValue)
    }

    func checkUserPhone(phone: String) -> Bool{
        return self.user.userPhone == phone
    }
    func checkMaxUserCash(cash: Float) -> Bool{
        return self.user.userCash > cash
    }
    func checkMaxAccountDeposit(withdraw: Float) -> Bool{
        return self.user.userBankDeposit > withdraw
    }
    func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool{
        return self.user.userCardId == userCardId && self.user.userCardPin == userCardPin
    }

    func topUpPhoneBalanceCash(pay: Float){
        print("Вы выбрали операцию '\(DescriptionTypesAvailableOperations.phoneBalanceInCash.rawValue)'")
        user.userPhoneBalance = user.userPhoneBalance + pay
        user.userCash = user.userCash - pay
        showUserToppedUpMobilePhoneCash(cash: user.userCash)
    }
    func topUpPhoneBalanceDeposit(pay: Float){
        print("Вы выбрали операцию '\(DescriptionTypesAvailableOperations.phoneBalanceFromBankDeposit.rawValue)'")
        user.userPhoneBalance = user.userPhoneBalance + pay
        user.userBankDeposit = user.userBankDeposit - pay
        showUserToppedUpMobilePhoneDeposite(deposit: user.userPhoneBalance)
    }
    func getCashFromDeposit(cash: Float){
        print("Вы выбрали операцию '\(DescriptionTypesAvailableOperations.withdrawingCashFromBankDeposit.rawValue)'")
        user.userBankDeposit = user.userBankDeposit - cash
        user.userCash = user.userCash + cash
        showTopUpAccount(cash: cash)
    }
    func putCashDeposit(topUp: Float){
        print("Вы выбрали операцию '\(DescriptionTypesAvailableOperations.replenishmentBankDepositInCash.rawValue)' на сумму \(topUp) рублей")
        user.userBankDeposit = user.userBankDeposit + topUp
        user.userCash = user.userCash - topUp
        showWithdrawalDeposit(cash: topUp)
    }
    
    init(user: UserData) {
        self.user = user
    }
}

extension BankServer {
    func doAction(userCardId: String, userCardPin: Int, actions: UserActions, userPhoneNumber: String, payment: PaymentMethod?) {
        if checkCurrentUser(userCardId: userCardId, userCardPin: userCardPin) {
            sayHello()
            switchAction(action: actions, payment: payment, userPhoneNumber: userPhoneNumber)
        } else {
            showError(error: TextErrors.wrongPinOrCard)
        }
    }
    
    private func switchAction(action: UserActions, payment: PaymentMethod?, userPhoneNumber: String) {
        switch action {
            // смотрим баланс
            case UserActions.balanceOnBankDeposit:
                showUserBalance()
            // берем деньги
            case UserActions.withdrawingCashFromBankDeposit:
                if let cash = getValueFromActions(action) {
                    if checkMaxAccountDeposit(withdraw: cash) {
                        getCashFromDeposit(cash: cash)
                    } else {
                        showError(error: TextErrors.insufficientFunds)
                    }
                }
            // кладем деньги на депозит
            case UserActions.replenishmentBankDepositInCash:
                if let cash = getValueFromActions(action) {
                    if checkMaxUserCash(cash: cash) {
                        putCashDeposit(topUp: cash)
                    } else {
                        showError(error: TextErrors.wrongCashLimit)
                    }
                }
            // пополняем баланс телефона
            case UserActions.toUpBalancePhone:
                if let cash = getValueFromActions(action) {
                    if checkUserPhone(phone: userPhoneNumber) {
                        toUpBalancePhone(payment: payment, cash: cash)
                    } else {
                        showError(error: TextErrors.wrongPhoneNumber)
                    }
                }
        }
    }
    // функция для пополнения баланса телефона, вынесена отдельно для читаемости
    private func toUpBalancePhone(payment: PaymentMethod?, cash: Float) {
        if let payment = payment {
            switch payment {
                case PaymentMethod.inCash:
                    if checkMaxUserCash(cash: cash) {
                        topUpPhoneBalanceCash(pay: cash)
                    } else {
                        showError(error: TextErrors.wrongCashLimit)
                    }
                case PaymentMethod.bankDeposit:
                    if checkMaxAccountDeposit(withdraw: cash) {
                        topUpPhoneBalanceDeposit(pay: cash)
                    } else {
                        showError(error: TextErrors.insufficientFunds)
                    }
                }
        } else {
            showError(error: TextErrors.wrongPaymentMethod)
        }
    }
    
    private func sayHello() {
        print("Добрый день, \(user.userName)!")
    }
}

// Банкомат, с которым мы работаем, имеет общедоступный интерфейс sendUserDataToBank
class ATM {
    private let userCardId: String
    private let userCardPin: Int
    private var someBank: BankApi
    private let action: UserActions
    private let paymentMethod: PaymentMethod?
    private let userPhoneNumber: String
 
    init(userCardId: String, userCardPin: Int, someBank: BankApi, action: UserActions, userPhoneNumber: String, paymentMethod: PaymentMethod? = nil) {
        self.userCardId = userCardId
        self.userCardPin = userCardPin
        self.userPhoneNumber = userPhoneNumber
        self.someBank = someBank
        self.action = action
        self.paymentMethod = paymentMethod

        sendUserDataToBank(userCardId: userCardId, userCardPin: userCardPin, actions: action, userPhoneNumber: userPhoneNumber, payment: paymentMethod)
    }
 
 
    public final func sendUserDataToBank(userCardId: String, userCardPin: Int, actions: UserActions, userPhoneNumber: String, payment: PaymentMethod?) {
        someBank.doAction(userCardId: userCardId, userCardPin: userCardPin, actions: actions, userPhoneNumber: userPhoneNumber, payment: payment)
    }
}

// создаем пользователя
let someUser: UserData = User(
    userName: "Стив Джобс",
    userCardId: "4000-1234-5673-9010",
    userCardPin: 3404,
    userCash: 290.45,
    userBankDeposit: 2567.20,
    userPhone: "+7(998)876-34-21",
    userPhoneBalance: 15.22
)

// создаем банк пользователя
let bankClient = BankServer(user: someUser)

// отправляем действие через банк
let someAtm = ATM(
    userCardId: "4000-1234-5673-9010",
    userCardPin: 3404,
    someBank: bankClient,
    action: UserActions.toUpBalancePhone(toUp: 100),
    userPhoneNumber: "+7(998)876-34-21",
    paymentMethod: PaymentMethod.bankDeposit
)


