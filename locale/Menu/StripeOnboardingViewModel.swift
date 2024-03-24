//
//  StripeOnboardingViewModel.swift
//  locale
//
//  Created by Adrian Martushev on 3/23/24.
//

import Foundation



struct WithdrawalMethod: Codable {
    var bank_accounts: [BankAccount]
    var debit_cards: [DebitCard]
}

struct BankAccount: Codable {
    var last4: String
    var bank_name: String
    var country: String
    var currency: String
}

struct DebitCard: Codable {
    var last4: String
    var brand: String
    var country: String
    var currency: String
}

enum WithdrawalMethodType  {
    case bankAccount(BankAccount)
    case debitCard(DebitCard)
}

extension BankAccount: Equatable {
    static func == (lhs: BankAccount, rhs: BankAccount) -> Bool {
        return lhs.last4 == rhs.last4 && lhs.bank_name == rhs.bank_name
        // Add any other properties you consider necessary for equality
    }
}

extension DebitCard: Equatable {
    static func == (lhs: DebitCard, rhs: DebitCard) -> Bool {
        return lhs.last4 == rhs.last4 && lhs.brand == rhs.brand
        // Add any other properties you consider necessary for equality
    }
}

extension WithdrawalMethodType: Equatable {
    static func == (lhs: WithdrawalMethodType, rhs: WithdrawalMethodType) -> Bool {
        switch (lhs, rhs) {
        case let (.bankAccount(lhsAccount), .bankAccount(rhsAccount)):
            return lhsAccount == rhsAccount
        case let (.debitCard(lhsCard), .debitCard(rhsCard)):
            return lhsCard == rhsCard
        default:
            return false
        }
    }
}


class StripeOnboardingViewModel: ObservableObject {
    // Include necessary imports and properties here

    @Published var stripeURL: URL? = nil
    @Published var withdrawalMethods: WithdrawalMethod?

    @Published var selectedWithdrawalMethod: WithdrawalMethodType?

    
    let baseURL = "https://locale-ios-d4e8c531cbbe.herokuapp.com"
    
    
    
    func checkOnboardingStatus(userId: String, completion: @escaping (Bool?, Error?) -> Void) {
        
        let correctedURLString = "\(baseURL)/check_stripe_onboarding"
        guard let url = URL(string: correctedURLString) else {
            completion(nil, NSError(domain: "InvalidURL", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            

            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "DataError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                }
                return
            }
            print("Checking onboarding status: ", data)


            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let onboardingCompleted = json["onboarding_completed"] as? Bool {
                    DispatchQueue.main.async {
                        completion(onboardingCompleted, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "JSONError", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }

    

    func createStripeExpressAccount(email: String, userID: String, completion: @escaping (URL?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/create_express_account") else {
            completion(nil, NSError(domain: "URLCreationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL"]))
            return
        }

        let requestData = [
            "email": email,
            "user_id": userID,
            "country": "US"
        ]
        print("Stripe account creation data: \(requestData)")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
            completion(nil, NSError(domain: "SerializationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request data to JSON"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let urlString = jsonData["url"] as? String, let link = URL(string: urlString) {
                        DispatchQueue.main.async {
                            completion(link, nil) // Pass the URL back through the completion handler
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure or URL"]))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "ResponseError", code: 500, userInfo: [NSLocalizedDescriptionKey: "HTTP request failed"]))
                }
            }
        }.resume()
    }
    
    
    func fetchWithdrawalMethods(stripeAccountID: String) {
        guard let url = URL(string: "\(baseURL)/get_withdrawal_methods") else {
            print("Invalid URL")
            return
        }

        let requestData = ["stripeAccountID": stripeAccountID]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
            print("Failed to serialize request data to JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error during network request:", error?.localizedDescription ?? "Unknown error")
                return
            }

            // Print the raw data as a string for debugging
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("Raw response data as string:\n\(rawJSON)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(WithdrawalMethod.self, from: data)
                DispatchQueue.main.async {
                    self?.withdrawalMethods = decodedResponse
                    
                    // Set the selectedWithdrawalMethod to the first found method
                    if let firstBankAccount = decodedResponse.bank_accounts.first {
                        self?.selectedWithdrawalMethod = .bankAccount(firstBankAccount)
                    } else if let firstDebitCard = decodedResponse.debit_cards.first {
                        self?.selectedWithdrawalMethod = .debitCard(firstDebitCard)
                    }
                    
                }
            } catch {
                print("Failed to decode JSON response:", error.localizedDescription)
            }
        }.resume()
    }

}
