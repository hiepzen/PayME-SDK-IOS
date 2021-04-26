import Foundation

public class LinkedInformation: Codable {
    internal var swiftCode: String!
    internal var linkedId: Int!
    
    public init(swiftCode : String, linkedId: Int) {
        self.swiftCode = swiftCode
        self.linkedId = linkedId
    }
}
