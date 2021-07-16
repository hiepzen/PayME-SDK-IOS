//
//  GraphQuery.swift
//  PayMESDK
//
//  Created by Minh Khoa on 5/6/21.
//

import Foundation

class GraphQuery {
    static let getServiceQuery = """
                                 query getServiceQuery($configsAppId: String) {
                                   Setting {
                                     configs(appId: $configsAppId) {
                                       key
                                       value
                                       tags
                                     }
                                   }
                                 }
                                 """
    static let getAccountInfoQuery = """
                                     query getAccountInfoQuery($accountPhone: String) {
                                       Account(phone: $accountPhone) {
                                         accountId
                                         fullname
                                         alias
                                         phone
                                         avatar
                                         email
                                         gender
                                         isVerifiedEmail
                                         isWaitingEmailVerification
                                         birthday
                                         address {
                                           street
                                           city {
                                             title
                                             identifyCode
                                           }
                                           district {
                                             title
                                             identifyCode
                                           }
                                           ward {
                                             title
                                             identifyCode
                                           }
                                         }
                                         kyc {
                                           kycId
                                           state
                                           reason
                                           identifyNumber
                                           details {
                                             identifyNumber
                                             issuedAt
                                           }
                                         }
                                       }
                                     }
                                     """
    static let getSettingQuery = """
                                 query getSettingQuery($configsKeys: [String]) {
                                   Setting {
                                     configs(keys: $configsKeys) {
                                       key
                                       value
                                       tags
                                     }
                                   }
                                 }
                                 """
    static let getWalletInfoQuery = """
                                    query getWalletInfoQuery {
                                      Wallet {
                                        balance
                                        cash
                                        credit
                                        lockCash
                                        creditLimit
                                      }
                                    }
                                    """
    static let transferATMQuery = """
                                  mutation transferATMQuery($payInput: OpenEWalletPaymentPayInput!) {
                                    OpenEWallet {
                                      Payment {
                                        Pay(input: $payInput) {
                                          succeeded
                                          message
                                          history {
                                            payment {
                                              transaction
                                              method
                                              description
                                            }
                                            createdAt
                                          }
                                          payment {
                                            ... on PaymentBankCardResponsed {
                                              state
                                              message
                                              html
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  """
    static let createSecurityCodeQuery = """
                                         mutation createSecurityCodeQuery($createCodeByPasswordInput: CreateSecurityCodeByPassword!) {
                                           Account {
                                             SecurityCode {
                                               CreateCodeByPassword(input: $createCodeByPasswordInput) {
                                                 securityCode
                                                 succeeded
                                                 message
                                                 code
                                               }
                                             }
                                           }
                                         }
                                         """
    static let transferByLinkedBankQuery = """
                                           mutation transferByLinkedBankQuery($payInput: OpenEWalletPaymentPayInput!) {
                                             OpenEWallet {
                                               Payment {
                                                 Pay(input: $payInput) {
                                                   succeeded
                                                   message
                                                   history {
                                                     payment {
                                                       transaction
                                                       method
                                                       description
                                                     }
                                                     createdAt
                                                   }
                                                   payment {
                                                     ... on PaymentLinkedResponsed {
                                                       state
                                                       message
                                                       linkedId
                                                       transaction
                                                       html
                                                     }
                                                   }
                                                 }
                                               }
                                             }
                                           }
                                           """
    static let readQRContentQuery = """
                                    mutation readQRContentQuery($detectInput: OpenEWalletPaymentDetectInput!) {
                                      OpenEWallet {
                                        Payment {
                                          Detect(input: $detectInput) {
                                            action
                                            succeeded
                                            message
                                            type
                                            storeId
                                            amount
                                            note
                                            orderId
                                          }
                                        }
                                      }
                                    }
                                    """
    static let checkFlowLinkedBankQuery = """
                                          mutation checkFlowLinkedBankQuery($payInput: OpenEWalletPaymentPayInput!) {
                                            OpenEWallet {
                                              Payment {
                                                Pay(input: $payInput) {
                                                  succeeded
                                                  message
                                                  history {
                                                    payment {
                                                      transaction
                                                      method
                                                      description
                                                    }
                                                    createdAt
                                                  }
                                                  payment {
                                                    ... on PaymentLinkedResponsed {
                                                      state
                                                      message
                                                      linkedId
                                                      transaction
                                                      html
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                          """
    static let mutationAuthenCredit = """
                                      mutation AuthCreditCardMutation($authCreditCardInput: CreditCardAuthInput) {
                                        CreditCardLink {
                                          AuthCreditCard(input: $authCreditCardInput) {
                                            succeeded
                                            message
                                            referenceId
                                            html
                                            isAuth
                                          }
                                        }
                                      }
                                      """
    static let transferWalletQuery = """
                                     mutation transferWalletQuery($payInput: OpenEWalletPaymentPayInput!) {
                                       OpenEWallet {
                                         Payment {
                                           Pay(input: $payInput) {
                                             succeeded
                                             message
                                             history {
                                               payment {
                                                 transaction
                                                 method
                                                 description
                                               }
                                               createdAt
                                             }
                                           }
                                         }
                                       }
                                     }
                                     """
    static let getTranferMethodsQuery = """
                                        mutation getTranferMethodsQuery($getPaymentMethodInput: PaymentMethodInput) {
                                          Utility {
                                            GetPaymentMethod(input: $getPaymentMethodInput) {
                                              succeeded
                                              message
                                              methods {
                                                methodId
                                                type
                                                title
                                                label
                                                fee
                                                minFee
                                                feeDescription
                                                data {
                                                  ... on LinkedMethodInfo {
                                                    swiftCode
                                                    linkedId
                                                    issuer
                                                  }
                                                  ... on WalletMethodInfo {
                                                    accountId
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                        """
    static let verifyKYCQuery = """
                                mutation verifyKYCQuery($kycInput: KYCInput!) {
                                  Account {
                                    KYC(input: $kycInput) {
                                      succeeded
                                      message
                                    }
                                  }
                                }
                                """
    static let getBankNameQuery = """
                                  mutation getBankNameQuery($getBankNameInput: AccountBankInfoInput) {
                                    Utility {
                                      GetBankName(input: $getBankNameInput) {
                                        succeeded
                                        message
                                        accountName
                                      }
                                    }
                                  }
                                  """
    static let getBankListQuery = """
                                  query getBankListQuery {
                                    Setting {
                                      banks {
                                        id
                                        viName
                                        enName
                                        shortName
                                        swiftCode
                                        cardNumberLength
                                        cardPrefix
                                        depositable
                                        vietQRAccepted
                                        requiredDate
                                      }
                                    }
                                  }
                                  """
    static let registerClientQuery = """
                                     mutation registerClientQuery($registerInput: ClientRegisterInput!) {
                                       Client {
                                         Register(input: $registerInput) {
                                           clientId
                                           succeeded
                                         }
                                       }
                                     }
                                     """
    static let initAccountQuery = """
                                  mutation initAccountQuery($initInput: CheckInitInput) {
                                    OpenEWallet {
                                      Init(input: $initInput) {
                                        succeeded
                                        message
                                        handShake
                                        accessToken
                                        kyc {
                                          kycId
                                          state
                                          identifyNumber
                                          reason
                                          sentAt
                                        }
                                        appEnv    
                                        phone
                                        isExistInMainWallet
                                        updateToken
                                        storeName
                                        storeImage
                                      }
                                    }
                                  }
                                  """
    static let getWalletGraphQLQuery = """
                                       query getWalletGraphQLQuery {
                                         Wallet {
                                           balance
                                           cash
                                           credit
                                           lockCash
                                           creditLimit
                                         }
                                       }
                                       """
    static let getFeeGraphQLQuery: String = """
                                            mutation GetFeeMutation($getFeeInput: GetFeeInput) {
                                              Utility {
                                                GetFee(input: $getFeeInput) {
                                                  succeeded
                                                  state
                                                  message
                                                  fee {
                                                    ... on GeneralFee {
                                                      fee
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                            """
    static let creditPaymentSubscription = """
                                           subscription CreditCardPaymentStatus {
                                             CreditCard {
                                               ... on PaymentStatusSubscription {
                                                 state
                                                 serviceCode
                                                 transaction
                                                 amount
                                                 total
                                                 fee
                                               }
                                             }
                                           }
                                           """
    static let getTransactionInfo = """
                                   mutation SucceededMutation($getTransactionInfoInput: GetTransactionInfoInput!) {
                                      OpenEWallet {
                                        Payment {
                                          GetTransactionInfo(input: $getTransactionInfoInput) {
                                            succeeded
                                            message
                                            transaction
                                            state
                                            fee
                                            description
                                          }
                                        }
                                      }
                                    }
                                   """
    static let getListBankManual = """
                                     mutation paymentBankTransfer($payInput: OpenEWalletPaymentPayInput!) {
                                             OpenEWallet {
                                               Payment {
                                                 Pay(input: $payInput) {
                                                   succeeded
                                                   message
                                                   history {
                                                     payment {
                                                       transaction
                                                       method
                                                       description
                                                     }
                                                     createdAt
                                                   }
                                                   payment {
                                                     ... on PaymentBankTransferResponsed {
                                                       bankTranferState: state
                                                       message
                                                       bankList {
                                                         bankName
                                                         bankCity
                                                         bankBranch
                                                         bankAccountName
                                                         bankAccountNumber
                                                         content
                                                         swiftCode
                                                         qrContent
                                                       }
                                                     }
                                                   }
                                                 }
                                               }
                                             }
                                           }
                                   """
    static let paymentBankTransfer = """
                                           mutation paymentBankTransfer($payInput: OpenEWalletPaymentPayInput!) {
                                             OpenEWallet {
                                               Payment {
                                                 Pay(input: $payInput) {
                                                   succeeded
                                                   message
                                                   history {
                                                     payment {
                                                       transaction
                                                       method
                                                       description
                                                     }
                                                     createdAt
                                                   }
                                                   payment {
                                                     ... on PaymentBankTransferResponsed {
                                                       bankTranferState: state
                                                       message
                                                       bankList {
                                                         bankName
                                                         bankCity
                                                         bankBranch
                                                         bankAccountName
                                                         bankAccountNumber
                                                         content
                                                         swiftCode
                                                       }
                                                     }
                                                   }
                                                 }
                                               }
                                             }
                                           }
                                           """
    static let transferCreditCardQuery = """
                                  mutation transferATMQuery($payInput: OpenEWalletPaymentPayInput!) {
                                    OpenEWallet {
                                      Payment {
                                        Pay(input: $payInput) {
                                          succeeded
                                          message
                                          history {
                                            payment {
                                              transaction
                                              method
                                              description
                                            }
                                            createdAt
                                          }
                                          payment {
                                            ... on PaymentCreditCardResponsed {
                                              state
                                              message
                                              transaction
                                              html
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                  """
    static let getMerchantInformation = """
                                     mutation getMerchantInformation($infoInput: OpenEWalletGetInfoMerchantInput!) {
                                       OpenEWallet {
                                         GetInfoMerchant(input: $infoInput) {
                                           succeeded
                                           message
                                           merchantName
                                           brandName
                                           backgroundColor
                                           storeImage
                                           storeName
                                           isVisibleHeader
                                         }
                                       }
                                     }
                                     """
}