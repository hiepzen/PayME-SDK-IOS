PayME SDK is a set of libraries for apps to interact with PayME Platform. PayME SDK includes the following main functions:

- Login system, eKYC via PayME wallet account
- Support app to get PayME wallet balance information
- Deposit and withdraw from PayME wallet

**Some terms**

| | Name | Explanation |
| :--- | :----- | ------------------------------------------------------------- |
| 1 | app | Is an iOS/Android mobile app or web that will integrate the SDK to perform the PayME wallet payment function. |
| 2 | SDK | Is a toolkit to support the integration of PayME wallet into the app system. |
| 3 | backend | An integrated system that supports an app, server or api. |
| 4 | AES | AES data encryption function. [Reference](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) |
| 5 | RSA | RSA data encryption algorithm. |
| 6 | IPN | Instant Payment Notification , used to notify between the app's backend and PayME's backend |

## How to install:

PayMESDK is being hosted on CocoaPods platform. To install, simply add the following to your Podfile:

```json
pod 'PayMESDK'
```

Then run the pod install command to complete the installation

**Info.plist**

Update Info.plist file with the following keys (values of string ​​may change, here are the messages displayed when asking the user for the corresponding permission):

```swift
<key>NSCameraUsageDescription</key>
<string>Need to access your camera to capture a photo add and update profile picture.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Need to access your library to add a photo or videoo off kyc video</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Need to access your photo library to select a photo add and update profile picture</string>
<key>NSContactsUsageDescription</key>
<string>Need to access your contact</string>
```

**If you don't use the contacts feature, add it at the end of the podfile**

```ruby
post_install do |installer|
   installer.pods_project.targets.each do |target|
       if target.name == 'PayMESDK'
           target.build_configurations.each do |config|
             config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] ||= '$(inherited)'
             config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] << 'IGNORE_CONTACT'
           end
       end
   end
end
```

## How to use the SDK:

The PayME system will provide the integrated app with the following information:

- **PublicKey** : Used to encrypt data, the integrated app needs to transmit to the SDK for encryption.
- **AppToken** : AppId provides a unique identifier for each app, needs to be transmit to the SDK for encryption.
- **SecretKey** : Used to encrypt and authenticate data in the backend system for the integrated app.

The App side will provide the PayME system with the following information:

- **AppPublicKey** : It will be sent through PayME's backend system for encryption. (do not transmit to this SDK)
- **AppPrivateKey**: It will transmit to PayME SDK to perform the decryption.

Encryption standard: RSA-512bit. The following tool can be used to generate [here](https://travistidwell.com/jsencrypt/demo/)

### Create PayME SDK:

Necessary to call the initialization method only 1 time to initialize the SDK before using PayME SDK.

```swift
let payme = PayME(appToken : "AppToken", 
                  publicKey: "PublicKey", 
                  connectToken : "ConnectToken",
                  appPrivateKey : "AppPrivateKey", 
                  language: PayME.Language.VIETNAMESE,
                  configColor : ["#07A922"],
                  env: PayME.Env.SANDBOX
)
```

In which the parameters have the form:

- appPrivateKey: is the private key self-generate from the app as above.

- publicKey: is the public key provided by PayME for each separate app.

- configColor: The color parameter can change color of PayME wallet transactions. The data type is string with the format #rrggbb. If 2 colors are transmitted, the PayME interface will gradient according to the 2 input colors.


![image](../master/assets/configColor.png?raw=true)

How to create **connectToken**:

connectToken is needed to transmit the api to PayME, and it will create from backend system of the integrated app. The structure is following below:

```swift
connectToken = AES256("{ timestamp: "2021-01-20T06:53:07.621Z", 
                         userId : "ABC", 
                         phone : "0909998877" }" 
                      + secretKey )
```

**Parameters** | **Required** | **Explanation** |
| :----------- | :---------- | :------------------------------------------------- ---------- |
| **timestamp** | Yes | Time of creating connectToken in the format iSO 8601. Used to determine the timeout of connectToken. Example 2021-01-20T06:53:07,621Z |
| ***userId*** | Yes | Is a unique fixed value corresponding to each customer account in the service, usually this value is provided by the integrated system server for the PayME SDK |
| ***phone*** | Yes | Phone number of the integrated system. If the system does not use the phone number, it may not be necessary to transmit up or transmit null |

In which ***AES*** is the encryption function according to the AES algorithm. Depending on the language on the server, the system side uses the corresponding library. See more: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard

How to create **connectToken including KYC information** (For partners with their own KYC system):

```swift
// example 

connectToken = AES256("{
    userId: "ABC",
    phone: "0909998877",
    timestamp: "2021-01-20T06:53:07.621Z",
    kycInfo: {
        {
            fullname: "Nguyen Van A",
            gender: "MALE",
            birthday: "1995-01-20T06:53:07.621Z",
            address: "1 Nguyen Co Thach",
            identifyType: "CMND",
            identifyNumber: "123456789",
            issuedAt: "2012-01-20T06:53:07.621Z",
            placeOfIssue: "Hai Duong",
            video: "https://..../202/Co-29vnK6.mp4",
            face: "https://.../photo/2015/04/_480.jpg",
            image: {
              front: "https://.../photo/2015/04/_480.jpg",
              back: "https://.../photo/2015/04/_480.jpg",
            }}
        }
}" + secretKey )
```

kycInfo parameter

| **Parameters** | **Required** | **Explanation** |
| -------------- | ------------ | ------------------------------------------------------------- |
| fullname | Yes | Full name |
| gender | Yes | Gender ( MALE/FEMALE) |
| address | Yes | Address |
| identifyType | Yes | Type of document (ID/CCCD) |
| identifyNumber | Yes | Number of papers |
| issuedAt | Yes | Registration date |
| placeOfIssue | Yes | Place of issue |
| video | No | Video link |
| face | No | Link to face photo |
| front | No | link to a photo of the front of the document |
| back | No | link to photo of the back of the document |

## PayME SDK Error Code

**Constant** | **Error Code** | **Explanation** |
| :----------- | :---------- |:-------------------------------------------------------------|
| EXPIRED | 401 | ***token*** expired |
| NETWORK | -1 | Network connection problem |
| SYSTEM | -2 | System Error |
| LIMIT | -3 | Error of insufficient balance to make a transaction |
| ACCOUNT_NOT_ACTIVATED | -4 | Account not activated error |
| ACCOUNT_NOT_KYC | -5 | Unknown account error |
| PAYMENT_ERROR | -6 | Payment failed |
| ERROR_KEY_ENCODE | -7 | Data encryption/decryption error |
| USER_CANCELLED | -8 | User cancels |
| ACCOUNT_NOT_LOGIN | -9 | Error not logged in account |
| PAYMENT_PENDING | -11 | Payment Pending |
| <code>ACCOUNT_ERROR</code>   | <code>-12</code>           | Account locked error |

## Functions of PayME SDK

### login()

There are 2 cases
- Used to login for the first time right after create PayME.
- Used when the accessToken expires, when calling the SDK function that returns the ResponseCode.EXPIRED error code, the app needs to re-call login to get the accessToken for other functions.

After calling login() successfully, then call other functions of the SDK (openWallet, pay ...)

```swift
public func login(
  onSuccess: (Dictionary<String, AnyObject>) -> (),
  onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

When login successfully will be returned to 1 enum KYCState contains information as follows:
```swift
public enum KYCState {
        case NOT_ACTIVATED
        case NOT_KYC
        case KYC_APPROVED
}
```
Features such as deposit, withdrawal, and pay are only available when the wallet is activated and the identified was successful. That is, when login will be returned enum KYCState with the case KYC_APPROVED.

### logout()

```swift
public func logout()
```

Used to log out of the session on the SDK

### close() - Close SDK

This function is used to let the integrated app close the SDK UI while <code>pay()</code> or <code>openWallet()</code>

```swift
public func close() -> ()
```

### openWallet() - Open UI for PayME general function

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

**in which, enum Action includes:**

```swift
  enum Action: String {
      case OPEN = "OPEN"
      case DEPOSIT = "DEPOSIT"
      case WITHDRAW = "WITHDRAW"
      case TRANSFER = "TRANSFER"
  }
```
This function is called when from the built-in app when you want to call a PayME function by transmit the Action parameter as above.

#### Parameter

| **Parameters** | **Required** | **Explanation** |
| :----------------------------------------------------------- | :---------- | :----------------------------------------------------------- |
| currentVC | Yes | ViewController to rely on PayME SDK to open up PayME's interface. |
| action | Yes | OPEN: Used to open the PayME WebView wallet interface and do not perform any special action. DEPOSIT: Used to open the PayME wallet interface and perform the deposit function PayME will process and have a message of success and failure on the UI by PayME. In addition, the results will be returned to the integrated app if you want to display and process it yourself on the app. WITHDRAW: Used to open the PayME wallet interface and perform the withdrawal function PayME will process and have a message of success and failure on PayME UI. In addition, it will return to the integrated app if you want to display and process it yourself on the app. |
| amount | No | Used in case the action is Deposit/Withdraw, then transmit the amount |
| description | No | Transmit the transaction description if available. |
| extraData | No | When performing Deposit or Withdraw, the integrated app needs to transmit other data if desired so that the PayME backend system can IBN back to the opposite integrated backend app system. For example: the transactionID of the transaction or any other data needed by the integrated app system. |
| onSuccess | Yes | Used to catch callback when making a successful transaction from PayME SDK |
| onError | Yes | Used to catch callback when an error occurs during calling PayME SDK |

Eg :
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

### deposit() - Deposit

```swift
public func deposit(
    currentVC : UIViewController, 
    amount: Int?, 
    description: String?, 
    extraData: String?,
    closeWhenDone: Bool = false,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> () 
```

This function has the same meaning as calling <code>openWallet</code> với action <code>Action.DEPOSIT</code>

| **Parameters** | **Default** | **Explanation** |
| :----------------------------------------------------------- | :---------- | :----------------------------------------------------------- |
| closeWhenDone | false | true: Close SDK when transaction completed |

### withdraw() - Withdraw money
```swift
public func withdraw(
    currentVC : UIViewController, 
    amount: Int?, 
    description: String?, 
    extraData: String?,
    closeWhenDone: Bool = false,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

This function has the same meaning as calling <code>openWallet</code> với action là <code>Action.WITHDRAW</code>

| **Parameters** | **Default** | **Explanation** |
| :----------------------------------------------------------- | :---------- | :----------------------------------------------------------- |
| closeWhenDone | false | true: Close SDK when transaction completed |

### transfer() - Transfer money

```swift
public func transfer(
    currentVC : UIViewController, 
    amount: Int?, 
    description: String?, 
    extraData: String?,
    closeWhenDone: Bool = false,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

This function has the same meaning as calling <code>openWallet</code> với action là <code>Action.TRANSFER</code>

| **Parameters** | **Default** | **Explanation** |
|:---------------| :---------- | :----------------------------------------------------------- |
| closeWhenDone  | false | true: Close SDK when transaction completed |

### openHistory() - Open transaction history


```swift
public func openHistory(
    currentVC : UIViewController,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```
This function has the same meaning as calling openWallet with the action Action.OPEN_HISTORY

### pay() - Payment

This function is used when the app needs to pay an amount from the activated PayME wallet.

⚠️ version 0.1.65 or earlier:
```swift
public func pay(
    currentVC : UIViewController,
    storeId: Int,
    orderId: Int,
    amount: Int,
    note: String?,
    paymentMethodID: Int?,
    extraData: String?,
    isShowResultUI: Bool = true,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```
| **Parameter**  | **Required** | **Explanation** |
|:---------------| :---------- | :----------------------------------------------------------- |
| currentVC      | Yes | ViewController in order to PayME SDK can open PayME's interface automatically. |
| amount         | Yes | The amount to be paid in the app is transmitted to SDK |
| extraData      | Yes | When making a payment, the app needs to transmit other data if it wants, so that the PayME backend system can IPN back to the reverse integrated backend system. For example the transactionID of the transaction or any other data needed. |
| storeId        | Yes | ID of the payment gateway that made the payment |
| orderId        | Yes | Partner's transaction code, need to be unique on each transaction (maximum 22 characters) |
| note           | No | Description of the transaction from the partner |
| isShowResultUI | No | Already have a default value of true, with the meaning that when there is a payment result, the success and failure screen will be displayed. When passing the value false, there will be no success or failure screens. |
| onSuccess      | Yes | Callback returns results on success |
| onError        | Yes | Callback returns result on failure |

In case the built-in app needs to get the balance to display itself on the UI on the app, you can use the getWalletInfo()
function, this function doesn't display the UI of the PayME SDK

- When paying with PayME wallet, it required the activated account, identifier and balance in the wallet must be greater than the payment amount.
- Account information is obtained through the getAccountInfo() function
- Balance information is obtained through the getWalletInfo() function

:warning: version 0.1.66 onwards:

```swift
public func pay(
    currentVC : UIViewController,
    storeId: Int?,
    userName: String?,
    orderId: Int,
    amount: Int,
    note: String?,
    payCode: String,
    extraData: String?,
    isShowResultUI: Bool = true,
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```
|**Parameter** | **Required** | **Value** |
| :----------------------------------------------------------- | :---------- |:-------------------------------------------------------------|
| payCode | Yes | PAYME ATM CREDIT MANUAL_BANK |
| userName | No | Account Name |
| storeId | No | ID of the payment gateway that made the payment |

Note: Only userName or storeId, if using userName, let storeId = nil and vice versa

### scanQR() - Open QR code scanning for payment
```swift
public func scanQR(
            currentVC: UIViewController,
	    payCode: String,
            onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
            onError: @escaping (Dictionary<String, AnyObject>) -> ()
) -> ()

```
QR format :
```swift
let qrString =  "{$type}|${storeId?}|${action}|${amount}|${note}|${orderId}|${userName?}"
```
Example:
```swift
let qrString = "OPENEWALLET|54938607|PAYMENT|20000|Chuyentien|2445562323|DEMO)"
```
- action: Transaction type ( 'PAYMENT' => payment)
- amount: Payment amount
- note: Description of transaction from partner side
- orderId: Partner's transaction code, which needs to be unique on each transaction
- storeId: The ID of the payment gateway where the payment is being made
- type: <code>OPENEWALLET</code>

### payQRCode() - QR code payment
```swift
public func payQRCode(
	currentVC: UIViewController, 
	qr: String,
	payCode: String,
	isShowResultUI: Bool,
    	onSuccess: @escaping (Dictionary<String, AnyObject>) -> (),
	onError: @escaping (Dictionary<String, AnyObject>) -> ()
) -> ()
```
- qr: QR code for payment (QR format like scanQR() function)
- isShowResultUI: Do you want to display the transaction result UI

### openKYC() - Open the account identifier modal

This function is called when from the built-in app when you want to open the account identifier modal (requires the account to be unidentified)
```swift
public func openKYC(
	currentVC: UIViewController,
        onSuccess: ([Dictionary<String, AnyObject>]) -> (),
        onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```
### getWalletInfo() - **Get wallet information**
```swift
public func getWalletInfo(
        onSuccess: (Dictionary<String, AnyObject>) -> (),
        onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

- In case of error, the function will return an error message at the onError function, then the app can display the balance as 0.

- In the successful case, the SDK returns the following information:

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
***balance*** : The built-in app can use the value in the balance key to display, other fields are currently unused.

***detail.cash :*** Money can be used.

***detail.lockCash:*** Money is locked.

### getAccountInfo()

App can use this function after create SDK to know the connection status to PayME wallet.

```swift
public func getAccountInfo(
    onSuccess: (Dictionary<String, AnyObject>) -> (),
    onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

### getSupportedServices()

Used to identify services that can be paid by the SDK (electricity, water, tuition...).

```swift
public func getSupportedServices(
            onSuccess: ([ServiceConfig]) -> (),
            onError: (Dictionary<String, AnyObject>) -> ()
) -> ()
```

```swift
class ServiceConfig {
	...
	public func getCode() -> String
	
   	public func getDescription() -> String
	...
}
```

### openService()

Open WebSDK to pay for services. (Feature under development)

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

### setLanguage()

Switch language of sdk

```swift
public func setLanguage(language: PayME.Language) -> ()
```

## Notes

### Working with use_framework!

- react-native-permission: https://github.com/zoontek/react-native-permissions#workaround-for-use_frameworks-issues
- Google Map iOS Util: https://github.com/googlemaps/google-maps-ios-utils/blob/b721e95a500d0c9a4fd93738e83fc86c2a57ac89/Swift.md
