import Foundation

class WalletInformation {
    var accountId : Int!
    var balance: Int?

    
    init(accountId: Int, balance: Int?) {
        self.accountId = accountId
        self.balance = balance
    }
}
