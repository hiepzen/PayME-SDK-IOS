import Foundation

public class EnvironmentSettings {
    static let standard = EnvironmentSettings()
    
    var enviroment: String, appToken: String, secretKey: String, publicKey: String, privateKey: String
    
    private init(){
        enviroment = ""
        appToken = ""
        secretKey = ""
        publicKey = ""
        privateKey = ""
    }
    
    
    func changeEnvironment(env: String!) {
        self.enviroment = env
        getStorage()
        
    }
    
    func getStorage() {
        let storedObj = UserDefaults.standard.dictionary(forKey: self.enviroment)
        if (storedObj != nil){
            self.appToken = storedObj!["appToken"] as! String
            self.secretKey = storedObj!["secretKey"] as! String
            self.publicKey = storedObj!["publicKey"] as! String
            self.privateKey = storedObj!["privateKey"] as! String
        } else  {
            restoreDefault()
        }
        
    }
    
    func restoreDefault() {
        switch (self.enviroment) {
        case "dev":
            self.appToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MTIsImlhdCI6MTYyMDg4MjQ2NH0.DJfi52Dc66IETflV2dQ8G_q4oUAVw_eG4TzrqkL0jLU"
            self.secretKey = "34cfcd29432cdd5feaecb87519046e2d"
            self.publicKey =
                    """
                    -----BEGIN PUBLIC KEY-----
                    MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAJi70XBS5+LtaCrNsrnWlVG6xec+J9M1
                    DzzvsmDfqRgTIw7RQ94SnEBBcTXhaIAZ8IW7OIWkVU0OXcybQEoLsdUCAwEAAQ==
                    -----END PUBLIC KEY-----
                    """
            self.privateKey =
                    """
                    -----BEGIN RSA PRIVATE KEY-----
                    MIIBOgIBAAJBAIA7GmDWkjuOQsx99tACXhOlJ4atsBN0YMPEmKhi9Ewk6bNBPvaX
                    pRMWjn7c8GfWrFUIVqlrvSlMYxmW/XaATjcCAwEAAQJAKZ6FPj8GcWwIBEUyEWtj
                    S28EODMxfe785S1u+uA7OGcerljPNOTme6iTuhooO5pB9Q5N7nB2KzoWOADwPOS+
                    uQIhAN2S5dxxadDL0wllNGeux7ltES0z2UfW9+RViByX/fAbAiEAlCd86Hy6otfd
                    k9K2YeylsdDwZfmkKq7p27ZcNqVUlBUCIQCxzEfRHdzoZDZjKqfjrzerTp7i4+Eu
                    KYzf19aSA1ENEwIgAnyXMB/H0ivlYDHNNd+O+GkVX+DMzJqa+kEZUyF7RfECICtK
                    rkcDyRzI6EtUFG+ALQOUliRRh7aiGXXZYb2KnlKy
                    -----END RSA PRIVATE KEY-----
                    """
            setStorage()
        case "sandbox":
            self.appToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MTIsImlhdCI6MTYxMzk5MDU5Nn0.donBYzgUyZ2qJwg2TVu43qCQBmYRkbPCsJwdbmLulQ8"
            self.secretKey = "ecd336c200e96265e00e312c6ca28d22"
            self.publicKey =
                """
                -----BEGIN PUBLIC KEY-----
                MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIXbBm3mTT7Ovlo9LNJK7noshpk8g+zm
                ueFTyrU7muUuXKboD7cg1h/K9zMW4qHFG+3LTo4Cc8fjoqbUm4UILgMCAwEAAQ==
                -----END PUBLIC KEY-----
                """
            self.privateKey =
                """
                -----BEGIN RSA PRIVATE KEY-----
                MIIBOQIBAAJAZCKupmrF4laDA7mzlQoxSYlQApMzY7EtyAvSZhJs1NeW5dyoc0XL
                yM+/Uxuh1bAWgcMLh3/0Tl1J7udJGTWdkQIDAQABAkAjzvM9t7kD84PudR3vEjIF
                5gCiqxkZcWa5vuCCd9xLUEkdxyvcaLWZEqAjCmF0V3tygvg8EVgZvdD0apgngmAB
                AiEAvTF57hIp2hkf7WJnueuZNY4zhxn7QNi3CQlGwrjOqRECIQCHfqO53A5rvxCA
                ILzx7yXHzk6wnMcGnkNu4b5GH8usgQIhAKwv4WbZRRnoD/S+wOSnFfN2DlOBQ/jK
                xBsHRE1oYT3hAiBSfLx8OAXnfogzGLsupqLfgy/QwYFA/DSdWn0V/+FlAQIgEUXd
                A8pNN3/HewlpwTGfoNE8zCupzYQrYZ3ld8XPGeQ=
                -----END RSA PRIVATE KEY-----
                """
            setStorage()
        case "production":
            self.appToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6NSwiaWF0IjoxNjEyNDMzNDI0fQ.rNl0i-yAEk4MOjcT5OAk7gxnxyAzPQVx9dHCiiH86rM"
            self.secretKey = "27d616faf57ae6db2f052f561de80e83"
            self.publicKey =
                """
                -----BEGIN PUBLIC KEY-----
                MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIwGH/c+jndwseq5JCU9SuRSbrT8IMiZ
                DFyA26aX6xkz42keW2sLRkHo4miAHvc+q91omHJEQXIfcAj2cA1AC6MCAwEAAQ==
                -----END PUBLIC KEY-----
                """
            self.privateKey =
                """
                -----BEGIN RSA PRIVATE KEY-----
                MIIBOQIBAAJAZCKupmrF4laDA7mzlQoxSYlQApMzY7EtyAvSZhJs1NeW5dyoc0XL
                yM+/Uxuh1bAWgcMLh3/0Tl1J7udJGTWdkQIDAQABAkAjzvM9t7kD84PudR3vEjIF
                5gCiqxkZcWa5vuCCd9xLUEkdxyvcaLWZEqAjCmF0V3tygvg8EVgZvdD0apgngmAB
                AiEAvTF57hIp2hkf7WJnueuZNY4zhxn7QNi3CQlGwrjOqRECIQCHfqO53A5rvxCA
                ILzx7yXHzk6wnMcGnkNu4b5GH8usgQIhAKwv4WbZRRnoD/S+wOSnFfN2DlOBQ/jK
                xBsHRE1oYT3hAiBSfLx8OAXnfogzGLsupqLfgy/QwYFA/DSdWn0V/+FlAQIgEUXd
                A8pNN3/HewlpwTGfoNE8zCupzYQrYZ3ld8XPGeQ=
                -----END RSA PRIVATE KEY-----
                """
            setStorage()
        default:
            Log.custom.push(title: "Restore default settings", message: "Không có environment!")
            
        }
    }
    
    func changeSettings(newAppToken: String!, newPrivateKey: String!, newPublicKey: String!, newSecretKey: String!){
        self.appToken = newAppToken
        self.privateKey = newPrivateKey
        self.publicKey = newPublicKey
        self.secretKey = newSecretKey
        setStorage()
    }
    
    func setStorage(){
        let newStoredData = ["appToken": self.appToken, "secretKey": self.secretKey, "publicKey": self.publicKey, "privateKey": self.privateKey]
        UserDefaults.standard.set(newStoredData, forKey: self.enviroment)
    }
    
}
