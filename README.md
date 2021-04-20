PayME SDK là bộ thư viện để các app có thể tương tác với PayME Platform. PayME SDK bao gồm các chức năng chính như sau:

- Hệ thống đăng nhập, eKYC thông qua tài khoản ví PayME 
- Hỗ trợ app lấy thông tin số dư ví PayME
- Chức năng nạp rút từ ví PayME.

**Một số thuật ngữ**

|      | Name    | Giải thích                                                   |
| :--- | :------ | ------------------------------------------------------------ |
| 1    | app     | Là app mobile iOS/Android hoặc web sẽ tích hợp SDK vào để thực hiện chức năng thanh toán ví PayME. |
| 2    | SDK     | Là bộ công cụ hỗ trợ tích hợp ví PayME vào hệ thống app.     |
| 3    | backend | Là hệ thống tích hợp hỗ trợ cho app, server hoặc api hỗ trợ  |
| 4    | AES     | Hàm mã hóa dữ liệu AES256 PKCS5 . [Tham khảo](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) |
| 5    | RSA     | Thuật toán mã hóa dữ liệu RSA.                               |
| 6    | IPN     | Instant Payment Notification , dùng để thông báo giữa hệ thống backend của app và backend của PayME |

## Cách cài đặt:

PayMESDK đang được lưu trữ trên nền tảng CocoaPods. Để cài đặt, đơn giản thêm dòng sau vào Podfile của bạn:

```json
pod 'PayMESDK'
```

Sau đó chạy lệnh <code>pod install</code> để hoàn tất cài dặt

## Cách sử dụng SDK:

Hệ thống PayME sẽ cung cấp cho app tích hợp các thông tin sau:

- **PublicKey** : Dùng để mã hóa dữ liệu, app tích hợp cần truyền cho SDK để mã hóa.
- **AppToken** : AppId cấp riêng định danh cho mỗi app, cần truyền cho SDK để mã hóa
- **SecretKey** : Dùng đã mã hóa và xác thực dữ liệu ở hệ thống backend cho app tích hợp.

Bên App sẽ cung cấp cho hệ thống PayME các thông tin sau:

- **AppPublicKey** : Sẽ gửi qua hệ thống backend của PayME dùng để mã hóa. (không truyền vào SDK này )
- **AppPrivateKey**: Sẽ truyền vào PayME SDK để thực hiện việc giải mã.

Chuẩn mã hóa: RSA-512bit. Có thể dùng tool sau để sinh ra [tại đây](https://travistidwell.com/jsencrypt/demo/)

### Khởi tạo PayME SDK:

Trước khi sử dụng PayME SDK cần gọi phương thức khởi tạo một lần duy nhất để khởi tạo SDK.

```swift
let payme = PayME(appId : "AppToken", 
                  publicKey: "PublicKey", 
                  connectToken : "ConnectToken",
                  appPrivateKey : "AppPrivateKey", 
                  language: PayME.Language.VIETNAM,
                  configColor : ["#07A922"],
                  env: PayME.Env.SANDBOX
)
```

Trong đó các thông số có dạng:

- appPrivateKey: là private key của app tự sinh ra như trên

```swift
private let PRIVATE_KEY: String =
  """
  -----BEGIN RSA PRIVATE KEY-----
  MIIBOwIBAAJBAOkNeYrZOhKTS6OcPEmbdRGDRgMHIpSpepulZJGwfg1IuRM+ZFBm
  F6NgzicQDNXLtaO5DNjVw1o29BFoK0I6+sMCAwEAAQJAVCsGq2vaulyyI6vIZjkb
  5bBId8164r/2xQHNuYRJchgSJahHGk46ukgBdUKX9IEM6dAQcEUgQH+45ARSSDor
  mQIhAPt81zvT4oK1txaWEg7LRymY2YzB6PihjLPsQUo1DLf3AiEA7Tv005jvNbNC
  pRyXcfFIy70IHzVgUiwPORXQDqJhWJUCIQDeDiZR6k4n0eGe7NV3AKCOJyt4cMOP
  vb1qJOKlbmATkwIhALKSJfi8rpraY3kLa4fuGmCZ2qo7MFTKK29J1wGdAu99AiAQ
  dx6DtFyY8hoo0nuEC/BXQYPUjqpqgNOx**********==
  -----END RSA PRIVATE KEY-----
  """
```

- publicKey: là public key được PayME cung cấp cho mỗi app riêng biệt.

 ```swift
 private let PUBLIC_KEY: String =
      """
      -----BEGIN PUBLIC KEY-----
      MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi
      wIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J**********
      -----END PUBLIC KEY-----
      """
    
 ```

-   configColor : là tham số màu để có thể thay đổi màu sắc giao dịch ví PayME, kiểu dữ liệu là chuỗi với định dạng #rrggbb. Nếu như truyền 2 màu thì giao diện PayME sẽ gradient theo 2 màu truyền vào.


![image](../master/assets/configColor.png?raw=true)

Cách tạo **connectToken**:

connectToken cần để truyền gọi api từ tới PayME và sẽ được tạo từ hệ thống backend của app tích hợp. Cấu trúc như sau:

```swift
connectToken = AES256("{ timestamp: "2021-01-20T06:53:07.621Z", 
                         userId : "ABC", 
                         phone : "0909998877" }" 
                      + secretKey )
```

| **Tham số**   | **Bắt buộc** | **Giải thích**                                               |
| :------------ | :----------- | :----------------------------------------------------------- |
| **timestamp** | Yes          | Thời gian tạo ra connectToken theo định dạng iSO 8601 , Dùng để xác định thời gian timeout cùa connectToken. Ví dụ 2021-01-20T06:53:07.621Z |
| ***userId***  | Yes          | là giá trị cố định duy nhất tương ứng với mỗi tài khoản khách hàng ở dịch vụ, thường giá trị này do server hệ thống được tích hợp cấp cho PayME SDK |
| ***phone***   | No           | Số điện thoại của hệ thống tích hợp, nếu hệ thống không dùng số điện thoại thì có thể không cần truyền lên hoặc truyền null |

Trong đó ***AES*** là hàm mã hóa theo thuật toán AES. Tùy vào ngôn ngữ ở server mà bên hệ thống dùng thư viện tương ứng. Xem thêm tại đây https://en.wikipedia.org/wiki/Advanced_Encryption_Standard

## Mã lỗi của PayME SDK

| **Hằng số**   | **Mã lỗi** | **Giải thích**                                               |
| :------------ | :----------- | :----------------------------------------------------------- |
| **EXPIRED** | 401          | ***token*** hết hạn sử dụng |
| ***NETWORK***  | -1          | Kết nối mạng bị sự cố |
| ***SYSTEM***   | -2           | Lỗi hệ thống |
| ***LIMIT***   | -3           | Lỗi số dư không đủ để thực hiện giao dịch |
| ***ACCOUNT_NOT_ACTIVETES***   | -4           | Lỗi tài khoản chưa kích hoạt |
| ***ACCOUNT_NOT_KYC***   | -5           | Lỗi tài khoản chưa định danh |
| ***PAYMENT_ERROR***   | -6           | Thanh toán thất bại |
| ***ERROR_KEY_ENCODE***   | -7           | Lỗi mã hóa/giải mã dữ liệu |
| ***USER_CANCELLED***   | -8           | Người dùng thao tác hủy |
| ***ACCOUNT_NOT_LOGIN***   | -9           | Lỗi chưa đăng nhập tài khoản |

## Các chức năng của PayME SDK

### login()

Có 2 trường hợp
- Dùng để login lần đầu tiên ngay sau khi khởi tạo PayME.
- Dùng khi accessToken hết hạn, khi gọi hàm của SDK mà trả về mã lỗi ERROR_CODE.EXPIRED, lúc này app cần gọi login lại để lấy accessToken dùng cho các chức năng khác.

Sau khi gọi login() thành công rồi thì mới gọi các chức năng khác của SDK ( openWallet, pay ... )

```swift
public func login(
  onSuccess: (Dictionary<String, AnyObject>) -> (),
  onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

Khi login thành công sẽ được trả về 1 enum KYCState chứa thông tin như sau: 

```swift
public enum KYCState {
        case NOT_ACTIVATED
        case NOT_KYC
        case KYC_APPROVED
}
```

Các tính năng như nạp tiền, rút tiền, pay chỉ thực hiện được khi đã kích hoạt ví và gửi định danh thành công. Tức là khi login sẽ được trả về enum <code>KYCState</code> với case là <code>KYC_APPROVED</code>.

### logout()

```swift
public func logout()
```

Dùng để đăng xuất ra khỏi phiên làm việc trên SDK

### openWallet() - Mở UI chức năng PayME tổng hợp

```swift
public func openWallet( 
   currentVC : UIViewController, 
   action : Action, 
   amount: Int?, 
   description: String?, 
   extraData: String?,
   onSuccess: (Dictionary<String, AnyObject>) -> (),
   onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

**trong đó enum Action bao gồm:**

```swift
  enum Action: String {
      case OPEN = "OPEN"
      case DEPOSIT = "DEPOSIT"
      case WITHDRAW = "WITHDRAW"
  }
```

Hàm này được gọi khi từ app tích hợp khi muốn gọi 1 chức năng PayME bằng cách truyền vào tham số Action như trên.

#### Tham số

| **Tham số**                                                  | **Bắt buộc** | **Giải thích**                                               |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [currentVC](https://www.notion.so/context-3dc20c6bc7d148f18d9004d0b7681866) | Yes          | ViewController để PayME SDK dựa vào đó tự mở giao diện của PayME lên. |
| [action](https://www.notion.so/action-473fad14180341b58515f2c3373d3b1c) | Yes          | <ul><li>OPEN : Dùng để mở giao diện ví PayME WebView và không thực hiện hành động nào đặc biệt.</li><li>DEPOSIT: Dùng để mở giao diện ví PayME và thực hiện chức năng nạp tiền PayME sẽ xử lý và có thông báo thành công thất bại trên UI của PayME. Ngoài ra sẽ trả về cho app tích hợp kết quả nếu muốn tự hiển thị và xử lý trên app.</li><li>WITHDRAW: Dùng để mở giao diện ví PayME và thực hiện chức năng rút tiền PayME sẽ xử lý và có thông báo thành công thất bại trên UI của PayME. Ngoài ra sẽ trả về cho app tích hợp kết quả nếu muốn tự hiển thị và xử lý trên app.</li></ul> |
| [amount](https://www.notion.so/amount-34eb8b97a9d04453867a7e4d87482980) | No           | Dùng trong trường hợp action là Deposit/Withdraw thì truyền vào số tiền |
| [description](https://www.notion.so/description-59034b8b0afe4f90a9118da3a478e7c0) | No           | Truyền mô tả của giao dịch nếu có                            |
| [extraData](https://www.notion.so/extraData-60ec44734315404685d82f9ab1d2886a) | No           | Khi thực hiện Deposit hoặc Withdraw thì app tích hợp cần truyền thêm các dữ liệu khác nếu muốn để hệ thông backend PayME có thể IBN lại hệ thống backend app tích hợp đối chiều. Ví dụ : transactionID của giao dịch hay bất kỳ dữ liệu nào cần thiết đối với hệ thống app tích hợp. |
| [onSuccess](https://www.notion.so/onSuccess-6e24a547a1ad46499c9d6413b5c02e81) | Yes          | Dùng để bắt callback khi thực hiện giao dịch thành công từ PayME SDK |
| [onError](https://www.notion.so/onError-25f94cb5a141484b8a70b9f1a2d7f33f) | Yes          | Dùng để bắt callback khi có lỗi xảy ra trong quá trình gọi PayME SDK |

Ví dụ :

```swift
import PayMESDK

class ViewController: UIViewController {
    let payME: PayME
    
    @IBAction func click(_ sender: Any) {
	payME.openWallet(
		currentVC: self,
		action: Action.OPEN, 
		amount: nil, 
		description : nil,
		extraData: nil
	)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        payME = PayME(  
		appID: appID, 
		publicKey: self.PUBLIC_KEY, 
		connectToken: self.connectToken, 
		appPrivateKey: self.PRIVATE_KEY, 
		env: currentEnv, 
		configColor: ["#75255b", "#a81308"]
	)
    }
}
```

### deposit() - Nạp tiền

```swift
public func deposit(
    currentVC : UIViewController, 
    amount: Int?, 
    description: String?, 
    extraData: String?,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> () 
```

Hàm này có ý nghĩa giống như khi gọi openWallet với action **Action.Deposit.**

### withdraw() - Rút tiền

```swift
public func withdraw(
    currentVC : UIViewController, 
    amount: Int?, 
    description: String?, 
    extraData: String?,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

Hàm này có ý nghĩa giống như gọi openWallet với action là **Action.WITHDRAW**.

### pay() - Thanh toán

Hàm này được dùng khi app cần thanh toán 1 khoản tiền từ ví PayME đã được kích hoạt.

```swift
public func pay(
    currentVC : UIViewController,
    storeId: Int,
    orderId: Int,
    amount: Int,
    note: String?,
    paymentMethodID: Int?,
    extraData: String?,
    isShowResultUI: Bool,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

| Tham số                                                      | **Bắt buộc** | **Giải thích**                                               |
| :----------------------------------------------------------- | :----------- | :----------------------------------------------------------- |
| [<code>currentVC</code>](https://www.notion.so/context-3dc20c6bc7d148f18d9004d0b7681866) | Yes          | ViewController để PayME SDK dựa vào đó tự mở giao diện của PayME lên. |
| [<code>amount</code>](https://www.notion.so/amount-f0a6c8422a11417a96bc898ad4ccffae) | Yes          | Số tiền cần thanh toán bên app truyền qua cho SDK            |
| [<code>description</code>](https://www.notion.so/description-f1f792f387f046bfb9432e4b94b76618) | No           | Mô tả nếu có                                                 |
| [<code>extraData</code>](https://www.notion.so/extraData-1aaad5976cca478d80f47b3c2f8bb804) | Yes          | Khi thực hiện thanh toans thì app cần truyền thêm các dữ liệu khác nếu muốn để hệ thông backend PayME có thể IBN lại hệ thống backend tích hợp đối chiều. Ví dụ : transactionID của giao dịch hay bất kỳ dữ liệu nào cần thiết. |
| <code>storeId</code> | Yes | ID của store phía công thanh toán thực hiên giao dịch thanh toán |
| <code>orderId</code> | Yes | Mã giao dịch của đối tác, cần duy nhất trên mỗi giao dịch |
| <code>note</code> | No | Mô tả giao dịch từ phía đối tác |
| <code>isShowResultUI</code> | No | Đã có giá trị default là true, với ý nghĩa là khi có kết quả thanh toán thì sẽ hiển thị màn hình thành công, thất bại. Khi truyền giá trị là false thì sẽ không có màn hình thành công, thất bại. |
| <code>onSuccess</code> | Yes | Callback trả kết quả khi thành công |
| <code>onError</code> | Yes | Callback trả kết quả khi thất bại |

Trong trường hợp app tích hợp cần lấy số dư để tự hiển thị lên UI trên app thì có thể dùng hàm, hàm này không hiển thị UI của PayME SDK

### getWalletInfo() - **Lấy các thông tin của ví**

```swift
public func getWalletInfo(
        onSuccess: (Dictionary<String, AnyObject>) -> (),
        onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

- Trong trường hợp lỗi thì hàm sẽ trả về message mỗi tại hàm onError , khi đó app có thể hiển thị balance là 0.

- Trong trường hợp thành công SDK trả về thông tin như sau:

```json
{
  "walletBalance": {
    "balance": 111,
    "detail": {
      "cash": 1,
      "lockCash": 2
    }
  }
}
```

***balance*** : App tích hợp có thể sử dụng giá trị trong key balance để hiển thị, các field khác hiện tại chưa dùng.

***detail.cash :*** Tiền có thể dùng

***detail.lockCash:*** tiền bị lock

### getAccountInfo()

App có thể dùng được tính này sau khi khởi tạo SDK để biết được trạng thái liên kết tới ví PayME.

```swift
public func getAccountInfo(
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

### getSupportedServices()

Dùng để xác định các dịch vụ có thể dùng SDK để thanh toán (điện, nước, học phí...).

```swift
public func getSupportedServices() -> Array<ServiceConfig>
```

### openService()

Mở WebSDK để thanh toán dịch vụ. ( Tính năng đang được xây dựng )

```swift
public func openService(
        currentVC : UIViewController,
        amount: Int?,
        description: String?,
        extraData: String?,
        service: ServiceConfig,
        onSuccess: (Dictionary<String, AnyObject>) -> (),
        onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

