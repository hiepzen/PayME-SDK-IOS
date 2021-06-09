import Foundation

class LinkedInformation: Codable {
    internal var swiftCode: String?
    internal var linkedId: Int!
    internal var cardNumber: String = ""
    
    public init(swiftCode : String?, linkedId: Int, cardNumber: String = "") {
        self.swiftCode = swiftCode
        self.linkedId = linkedId
        self.cardNumber = cardNumber
    }
}
