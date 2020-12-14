PayME SDK là bộ thư viện để các app có thể tương tác với PayME Platform. PayME SDK bao gồm các chức năng chính như sau:

- Hệ thống đăng nhập, eKYC thông qua tài khoản ví PayME 
- Hỗ trợ app lấy thông tin số dư ví PayME
- Chức năng nạp rút từ ví PayME.

**Một số thuật ngữ**

|      | Name    | Giải thích                                                   |
| :--- | :------ | ------------------------------------------------------------ |
| 1    | app     | Là app mobile iOS/Android hoặc web sẽ tích hợp SDK vào để thực hiện chức năng thanh toán ví PayME. |
| 2    | SDK     | Là bộ công cụ hỗ trợ tích hợp ví PayME vào hệ thống app.     |
| 3    | backend | Là hệ thống tích hợp hỗ trợ cho app, server hoặc api hỗ trợ  |
| 4    | AES     | Hàm mã hóa dữ liệu AES256 PKCS5 . [Tham khảo](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) |
| 5    | RSA     | Thuật toán mã hóa dữ liệu RSA.                               |
| 6    | IPN     | Instant Payment Notification , dùng để thông báo giữa hệ thống backend của app và backend của PayME |

## Cách cài đặt:

PayMESDK đang được lưu trữ trên nền tảng CocoaPods. Để cài đặt, đơn giản thêm dòng sau vào Podfile của bạn:

```json
pod 'PayMESDK'
```

## Cách sử dụng SDK:

Hệ thống PayME sẽ cung cấp cho app tích hợp các thông tin sau:

- **PublicKey** : Dùng để mã hóa dữ liệu, app tích hợp cần truyền cho SDK để mã hóa.
- **AppToken** : AppId cấp riêng định danh cho mỗi app, cần truyền cho SDK để mã hóa
- **SecretKey** : Dùng đã mã hóa và xác thực dữ liệu ở hệ thống backend cho app tích hợp.

Bên App sẽ cung cấp cho hệ thống PayME các thông tin sau:

- **AppPublicKey** : Sẽ gửi qua hệ thống backend của PayME dùng để mã hóa.
- **AppPrivateKey**: Sẽ truyền vào PayME SDK để thực hiện việc giải mã.

Chuẩn mã hóa: RSA-512bit.

### Khởi tạo PayME SDK:

Trước khi sử dụng PayME SDK cần gọi phương thức khởi tạo một lần duy nhất để khởi tạo SDK.

```swift
let payme = PayME( appId : "AppToken", publicKey: "PublicKey", connectToken : "ConnectToken",                    appPrivateKey : "AppPrivateKey", configColor : ["#07A922"] )
```

configColor : là tham số màu để có thể thay đổi màu sắc giao dịch ví PayME, kiểu dữ liệu là chuỗi với định dạng #rrggbb. Nếu như truyền 2 màu thì giao diện PayME sẽ gradient theo 2 màu truyền vào.

![image](https://developers.payme.vn/public/configcolor.png)

Cách tạo **connectToken**:

connectToken cần để truyền gọi api từ tới PayME và sẽ được tạo từ hệ thống backend của app tích hợp. Cấu trúc như sau:

```swift
connectToken = AES256("{ timestamp: 34343242342, userId : "ABC", phone : "0909998877" }" + secretKey )
```

| **Tham số**   | **Bắt buộc** | **Giải thích**                                               |
| :------------ | :----------- | :----------------------------------------------------------- |
| **timestamp** | Yes          | Thời gian tạo ra connectToken theo định danh Unix time, Dùng để xác định thời gian timeout cùa connectToken. xem https://en.wikipedia.org/wiki/Unix_time |
| ***userId***  | Yes          | là giá trị cố định duy nhất tương ứng với mỗi tài khoản khách hàng ở dịch vụ, thường giá trị này do server hệ thống được tích hợp cấp cho PayME SDK |
| ***phone***   | No           | Số điện thoại của hệ thống tích hợp, nếu hệ thống không dùng số điện thoại thì có thể không cần truyền lên hoặc truyền null |

Trong đó ***AES*** là hàm mã hóa theo thuật toán AES. Tùy vào ngôn ngữ ở server mà bên hệ thống dùng thư viện tương ứng. Xem thêm tại đây https://en.wikipedia.org/wiki/Advanced_Encryption_Standard

### Các c**hức năng của PayME SDK**

### isConnected()

App có thể dùng thuộc tính này sau khi khởi tạo SDK để biết được trạng thái liên kết tới ví PayME.

```swift
public func isConnected() -> Bool
```

**openWallet() - Mở UI chức năng PayME tổng hợp**

```swift
public func openWallet(    currentVC : UIViewController,    action: String,    amount: Action,   description : String?,   extraData : String?   onSuccess: (Dictionary<String,AnyObject>) -> (),    onError: (Dictionary<Int, Any>) -> () ) -> ()
```

**trong đó enum Action bao gồm:**

```swift
enum Action: String {      case OPEN = "OPEN"      case DEPOSIT = "DEPOSIT"      case WITHDRAW = "WITHDRAW"  }
```

Hàm này được gọi khi từ app tích hợp khi muốn gọi 1 chức năng PayME bằng cách truyền vào tham số Action như trên.

#### Tham số

| **Tham số**                                                  | **Bắt buộc** | **Giải thích**                                               |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [currentVC](https://www.notion.so/context-3dc20c6bc7d148f18d9004d0b7681866) | Yes          | ViewController để PayME SDK dựa vào đó tự mở giao diện của PayME lên. |
| [action](https://www.notion.so/action-473fad14180341b58515f2c3373d3b1c) | Yes          | OPEN : Dùng để mở giao diện ví PayME WebView và không thực hiện hành động nào đặc biệt.  DEPOSIT: Dùng để mở giao diện ví PayME và thực hiện chức năng nạp tiền PayME sẽ xử lý và có thông báo thành công thất bại trên UI của PayME. Ngoài ra sẽ trả về cho app tích hợp kết quả nếu muốn tự hiển thị và xử lý trên app. WITHDRAW: Dùng để mở giao diện ví PayME và thực hiện chức năng rút tiền PayME sẽ xử lý và có thông báo thành công thất bại trên UI của PayME. Ngoài ra sẽ trả về cho app tích hợp kết quả nếu muốn tự hiển thị và xử lý trên app. |
| [amount](https://www.notion.so/amount-34eb8b97a9d04453867a7e4d87482980) | No           | Dùng trong trường hợp action là Deposit/Withdraw thì truyền vào số tiền |
| [description](https://www.notion.so/description-59034b8b0afe4f90a9118da3a478e7c0) | No           | Truyền mô tả của giao dịch nếu có                            |
| [extraData](https://www.notion.so/extraData-60ec44734315404685d82f9ab1d2886a) | No           | Khi thực hiện Deposit hoặc Withdraw thì app tích hợp cần truyền thêm các dữ liệu khác nếu muốn để hệ thông backend PayME có thể IBN lại hệ thống backend app tích hợp đối chiều. Ví dụ : transactionID của giao dịch hay bất kỳ dữ liệu nào cần thiết đối với hệ thống app tích hợp. |
| [onSuccess](https://www.notion.so/onSuccess-6e24a547a1ad46499c9d6413b5c02e81) | Yes          | Dùng để bắt callback khi thực hiện giao dịch thành công từ PayME SDK |
| [onError](https://www.notion.so/onError-25f94cb5a141484b8a70b9f1a2d7f33f) | Yes          | Dùng để bắt callback khi có lỗi xảy ra trong quá trình gọi PayME SDK |

Ví dụ :

```swift
import PayMESDK 
class ViewController: UIViewController {    
  let payme : PayME;   
  @IBAction func click(_ sender: Any) { 
    payme.openLinkWallet(currentVC: self,        
                         action: Action.OPEN,  amount: nil,  description : nil, extraData: nil,);    }        	override func viewDidLoad() {        
    super.viewDidLoad()        
    payme = PayME( appId : "xxxx", publicKey: "zxczczx" , connectToken : "090909094720394", appPrivateKey : "000000000")    
  } 
}
```

### deposit() - Nạp tiền

```swift
public func deposit(currentVC : UIViewController,     amount: Int?,     description: String?,     extraData: String?,    onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),    onError: @escaping (String) -> ()) 
```

Hàm này có ý nghĩa giống như khi gọi openWallet với action **Action.Deposit.**

### withdraw() - Rút tiền

```swift
public func withdraw(currentVC : UIViewController,     amount: Int?,     description: String?,     extraData: String?,    onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),    onError: @escaping (String) -> ())
```

Hàm này có ý nghĩa giống như gọi openWallet với action là **Action.Withdraw**.

### pay() - Thanh toán

Hàm này được dùng khi app cần thanh toán 1 khoản tiền từ ví PayME đã được kích hoạt.

```swift
public func pay(currentVC : UIViewController,     amount: Int,     description: String?,    extraData: String?)
```

| Tham số                                                      | **Bắt buộc** | **Giải thích**                                               |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [currentVC](https://www.notion.so/context-3dc20c6bc7d148f18d9004d0b7681866) | Yes          | ViewController để PayME SDK dựa vào đó tự mở giao diện của PayME lên. |
| [amount](https://www.notion.so/amount-f0a6c8422a11417a96bc898ad4ccffae) | Yes          | Số tiền cần thanh toán bên app truyền qua cho SDK            |
| [description](https://www.notion.so/description-f1f792f387f046bfb9432e4b94b76618) | No           | Mô tả nếu có                                                 |
| [extraData](https://www.notion.so/extraData-1aaad5976cca478d80f47b3c2f8bb804) | Yes          | Khi thực hiện thanh toans thì app cần truyền thêm các dữ liệu khác nếu muốn để hệ thông backend PayME có thể IBN lại hệ thống backend tích hợp đối chiều. Ví dụ : transactionID của giao dịch hay bất kỳ dữ liệu nào cần thiết. |

Trong trường hợp app tích hợp cần lấy số dư để tự hiển thị lên UI trên app thì có thể dùng hàm, hàm này không hiển thị UI của PayME SDK

### getWalletInfo() - **Lấy các thông tin của ví**

```swift
public func getWalletInfo(        onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),        onError: @escaping ([Int:Any]) -> ()    ) {
```

- Trong trường hợp lỗi thì hàm sẽ trả về message mỗi tại hàm onError , khi đó app có thể hiển thị balance là 0.

- Trong trường hợp thành công SDK trả về thông tin như sau:

```swift
{  "walletBalance": {    "balance": 111,    "detail": {      "cash": 1,      "lockCash": 2    }  } }
```

***balance*** : App tích hợp có thể sử dụng giá trị trong key balance để hiển thị, các field khác hiện tại chưa dùng.

***detail.cash :*** Tiền có thể dùng

***detail.lockCash:*** tiền bị lock
