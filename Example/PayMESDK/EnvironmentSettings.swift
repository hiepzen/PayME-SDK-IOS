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
            self.appToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6Njg2OH0.JyIdhQEX_Lx9CXRH4iHM8DqamLrMQJk5rhbslNW4GzY"
            self.secretKey = "zfQpwE6iHbOeAfgX"
            self.publicKey =
                """
                -----BEGIN PUBLIC KEY-----
                MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi
                wIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQ==
                -----END PUBLIC KEY-----
                """
            self.privateKey =
                """
                -----BEGIN RSA PRIVATE KEY-----
                MIIBOwIBAAJBAOkNeYrZOhKTS6OcPEmbdRGDRgMHIpSpepulZJGwfg1IuRM+ZFBm
                F6NgzicQDNXLtaO5DNjVw1o29BFoK0I6+sMCAwEAAQJAVCsGq2vaulyyI6vIZjkb
                5bBId8164r/2xQHNuYRJchgSJahHGk46ukgBdUKX9IEM6dAQcEUgQH+45ARSSDor
                mQIhAPt81zvT4oK1txaWEg7LRymY2YzB6PihjLPsQUo1DLf3AiEA7Tv005jvNbNC
                pRyXcfFIy70IHzVgUiwPORXQDqJhWJUCIQDeDiZR6k4n0eGe7NV3AKCOJyt4cMOP
                vb1qJOKlbmATkwIhALKSJfi8rpraY3kLa4fuGmCZ2qo7MFTKK29J1wGdAu99AiAQ
                dx6DtFyY8hoo0nuEC/BXQYPUjqpqgNOx33R4ANzm9w==
                -----END RSA PRIVATE KEY-----
                """
            setStorage()
        case "sandbox":
            self.appToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6NH0.U60jaOwKcaQ6bUX-6O21RMOoFR_5ZkjpGgj6rus0r60"
            self.secretKey = "zfQpwE6iHbOeAfgX"
            self.publicKey =
                """
                -----BEGIN PUBLIC KEY-----
                MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMwvSFz/mOfxBSVkGeqfRv3oQaCsx9V2
                hqdL4Y0PK+r2P+8Jd9pOS61uehd1gsjU1/xMFHWFGKrH6lO8+TSLGukCAwEAAQ==
                -----END PUBLIC KEY-----
                """
            self.privateKey =
                """
                -----BEGIN RSA PRIVATE KEY-----
                MIIBOgIBAAJBAIpXByu/SQKImCFT5xTyqLe6zcqDAL/aapD4kYueJiSTFQYzobNx
                UA7wRqsljHGfouFXB0gguiPjtoRWgY9XMpMCAwEAAQJALQVFgCcwS3LIj5AOk/Kk
                laZlcpJPnCAoriU2uIkvQJdijzoz6baxQDY5xfxwBh7wExmKGvUWxR/qt7ULVf1a
                AQIhAMVtGD6vc0zVBuIoWFE2RDYt28WN37p5zC1NtpRebnzjAiEAs2I4WSyUQSzD
                P0yR0P+khUI/8oy/iZ/VSASAxzmjkpECIQCTRaZoXIkuL1tLKb14F3saz2q6G/Nh
                L6pXwTkJxMe28QIgTiPG7/FfU1SwaG5uRmBVxkapnHp7JPQe8BQmFKKjAkECIBM4
                Hel54r1RnKQVUtiLphlZgesayKzrtK2kAgssWKi1
                -----END RSA PRIVATE KEY-----
                """
            setStorage()
        case "production":
            self.appToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6NCwiaWF0IjoxNjExOTAzNjU3fQ.GfTRq6gvO0rU0XHx6JksJXIB1hireYyKaX92mTnMb64"
            self.secretKey = "240c70d60d85a4c1bef302ca7a38bd8c"
            self.publicKey =
                """
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmXR5qmL2lLfInmwGYsB2
                WIgoQobh6UQ0tJ3uhzhBSFkvIHqIdrwBAKURe/1S5ZqplZwb91H+hgEJVyVaBPhW
                H6TcOG01iBTQkodwUin/JT472G/bWkwbkoM8n9g5uDDG9udd9aB4YJeXQg3vOnxf
                7bipFW/Hd3155CWYcRZEFG7Q7GGHpuGj8UHV4nIzxhcOpAVhtAyeWI0+h9M9LH1Y
                RPWOOBcweNNbKjDJf1QhsWr1CtuRP4Zeh9Sg+nGVbuKcfjnZQt+ABD83a4cniSzq
                Qqe+r2lGubmumo+XQpsJPTg9R/ODmKrkd++6jrHWJbqeITD9xRpDzvgGiWUhhc9FKQIDAQAB
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
