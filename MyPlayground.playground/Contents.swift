
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
  func doAction(userCardId: String, userCardPin: Int, actions: UserActions, payment: PaymentMethod?)
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
    case withdrawingCashFromBankDeposit //снятие наличных с банковского депозита
    case replenishmentBankDepositInCash //пополнение банковского депозита наличными
    case phoneBalanceInCash //пополнение баланса телефона наличными
    case phoneBalanceFromBankDeposit //пополнение баланса телефона с банковского депозита
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
    private let user: UserData
    
    func showUserBalance() {
        print("Вы выбрали операцию '\(DescriptionTypesAvailableOperations.balanceOnBankDeposit.rawValue)', ваш баланс: \(user.userBankDeposit) рублей")
    }
    func showUserToppedUpMobilePhoneCash(cash: Float){}
    func showUserToppedUpMobilePhoneDeposite(deposit: Float){}
    func showWithdrawalDeposit(cash: Float){}
    func showTopUpAccount(cash: Float){}
    func showError(error: TextErrors){
        print(error.rawValue)
    }

    func checkUserPhone(phone: String) -> Bool{
        return self.user.userPhone == phone
    }
    func checkMaxUserCash(cash: Float) -> Bool{
        return self.user.userCash <= cash
    }
    func checkMaxAccountDeposit(withdraw: Float) -> Bool{
        return self.user.userBankDeposit <= withdraw
    }
    func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool{
        return self.user.userCardId == userCardId && self.user.userCardPin == userCardPin
    }

    func topUpPhoneBalanceCash(pay: Float){}
    func topUpPhoneBalanceDeposit(pay: Float){}
    func getCashFromDeposit(cash: Float){}
    func putCashDeposit(topUp: Float){}
    
    init(user: UserData) {
        self.user = user
    }
}

extension BankServer {
    func doAction(userCardId: String, userCardPin: Int, actions: UserActions, payment: PaymentMethod?) {
        if checkCurrentUser(userCardId: userCardId, userCardPin: userCardPin) {
            sayHello()
            switch actions {
                case UserActions.balanceOnBankDeposit:
                    showUserBalance()
                default:
                    showUserBalance()
            }
        } else {
            showError(error: TextErrors.wrongPinOrCard)
        }
    }
    
    private func sayHello() {
        print("Добрый день, \(user.userName)")
    }
}

// Банкомат, с которым мы работаем, имеет общедоступный интерфейс sendUserDataToBank
class ATM {
  private let userCardId: String
  private let userCardPin: Int
  private var someBank: BankApi
  private let action: UserActions
  private let paymentMethod: PaymentMethod?
 
  init(userCardId: String, userCardPin: Int, someBank: BankApi, action: UserActions, paymentMethod: PaymentMethod? = nil) {
    self.userCardId = userCardId
    self.userCardPin = userCardPin
    self.someBank = someBank
    self.action = action
    self.paymentMethod = paymentMethod

    sendUserDataToBank(userCardId: userCardId, userCardPin: userCardPin, actions: action, payment: paymentMethod )
  }
 
 
  public final func sendUserDataToBank(userCardId: String, userCardPin: Int, actions: UserActions, payment: PaymentMethod?) {
    someBank.doAction(userCardId: userCardId, userCardPin: userCardPin, actions: actions, payment: payment)
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
let someAtm = ATM(userCardId: "4000-1234-5673-9010", userCardPin: 3404, someBank: bankClient, action: UserActions.balanceOnBankDeposit)


