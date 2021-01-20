import Foundation

class Log {
    static let custom = Log()
    
    var logList: [String] = []
    let dateFormatter = DateFormatter()
    
    private init(){
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
 
    public func push(title: String, message: Any){
        let date = Date()
        let customLog: String = "\(dateFormatter.string(from: date)) [\(title.uppercased())] \(message)"
        Swift.print(customLog)
        logList.append(customLog)
    }
    
    public func clear(){
        self.logList = []
    }
}
