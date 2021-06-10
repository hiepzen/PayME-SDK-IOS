import Foundation

class LinkedInformation: Codable {
    var swiftCode: String?
    var linkedId: Int!
    var cardNumber: String = ""
    var issuer: String
    
    public init(swiftCode: String?, linkedId: Int, cardNumber: String = "", issuer: String = "") {
        self.swiftCode = swiftCode
        self.linkedId = linkedId
        self.cardNumber = cardNumber
        self.issuer = issuer
    }
}
