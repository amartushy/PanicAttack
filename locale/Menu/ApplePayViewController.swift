//
//  ApplePayViewController.swift
//  locale
//
//  Created by Adrian Martushev on 3/30/24.
//

import Foundation
import StripeApplePay
import PassKit
import SwiftUI
import StripePaymentSheet


class CheckoutViewModel : ObservableObject {
    
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    
    func preparePaymentSheet() {
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        let url = URL(string: "https://locale-ios-d4e8c531cbbe.herokuapp.com/payment-sheet")!
        let amountInCents = 999
        let requestBody = ["amount": amountInCents]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let customerId = json["customer"] as? String,
                      let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                      let paymentIntentClientSecret = json["paymentIntent"] as? String,
                      let publishableKey = json["publishableKey"] as? String,
                      let self = self else {
                        // Handle error
                        return
                    }

                DispatchQueue.main.async {
                    self.paymentIntentID = paymentIntentClientSecret
                }
                STPAPIClient.shared.publishableKey = publishableKey
                
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Panic Attack, LLC."
                configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
                configuration.allowsDelayedPaymentMethods = true

                DispatchQueue.main.async {
                    self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
                }
            }
            
            task.resume()
        } catch {
            print("Failed to serialize request body: \(error)")
        }
    }
    
    @Published var paymentIntentID = ""

    func onPaymentCompletion(result: PaymentSheetResult) {
        DispatchQueue.main.async {
            self.paymentResult = result
        }
    }
}

class CheckoutControllerManager {
    static var shared: CheckoutControllerManager!
    let checkoutController: CheckoutViewController
    var navigateToError: Binding<Bool>
    var navigateToSuccess: Binding<Bool>


    init(checkout: CheckoutViewModel, currentUser: CurrentUserViewModel, navigateToError: Binding<Bool>, navigateToSuccess : Binding<Bool>) {
        let checkoutController = CheckoutViewController(checkout: checkout, currentUser: currentUser)
        checkoutController.checkout = checkout
        checkoutController.currentUser = currentUser
        self.checkoutController = checkoutController
        self.navigateToError = navigateToError
        self.navigateToSuccess = navigateToSuccess

        CheckoutControllerManager.shared = self
        
    }
}



class CheckoutViewController: UIViewController, ApplePayContextDelegate {
    var checkout : CheckoutViewModel
    var currentUser : CurrentUserViewModel
    var clientSecret : String = ""
    var paymentIntentID: String?

    
    init(checkout: CheckoutViewModel, currentUser: CurrentUserViewModel) {
        self.checkout = checkout
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showApplePaySheet() {
        handleApplePayButtonTapped()
    }
    
    
    
    let applePayButton: PKPaymentButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Only offer Apple Pay if the customer can pay with it
        print( "is Supported: ", StripeAPI.deviceSupportsApplePay() )
        applePayButton.isHidden = !StripeAPI.deviceSupportsApplePay()
        applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
        
        // Set up Auto Layout
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(applePayButton)

        // Set constraints
        NSLayoutConstraint.activate([
            applePayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            applePayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            applePayButton.heightAnchor.constraint(equalToConstant: 50),
            applePayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    

    @objc dynamic func handleApplePayButtonTapped() {
        
        let merchantIdentifier = "merchant.sandbox.stripe"
        let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "US", currency: "USD")

        // Configure the line items on the payment request
        // Ensure values are rounded to the nearest cent
        
        let total = PKPaymentSummaryItem(label: "Panic Attack, INC", amount: NSDecimalNumber(value: 9.99), type: .final)
        
        paymentRequest.paymentSummaryItems = [total]

        // Initialize an STPApplePayContext instance
        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
            // Present Apple Pay payment sheet
            applePayContext.presentApplePay()
        } else {
            // There is a problem with your Apple Pay configuration
            print("There is a problem with your Apple Pay configuration")
        }
    }
    
    func getFirstPart(input: String) -> String {
        let components = input.components(separatedBy: "_secret_")
        if let firstPart = components.first {
            return firstPart
        } else {
            return ""
        }
    }
}



extension CheckoutViewController {
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: StripeAPI.PaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        // Call the completion block with the client secret or an error
        let url = URL(string: "https://locale-ios-d4e8c531cbbe.herokuapp.com/create-payment-intent")!

        let roundedAmount = 999
        print("Rounded int amount: \(roundedAmount)")

        let shoppingCartContent: [String: Any] = [
            "amount" : roundedAmount,
            "userID" : currentUser.currentUserID,
            "customerID" : currentUser.stripeAccountID,
            "description" : "Monthly Subscription"
        ]
        
        print(shoppingCartContent)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: shoppingCartContent)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { [ self] (data, response, error) in
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let clientSecret = json["clientSecret"] as? String
                    
            else {
                let message = error?.localizedDescription ?? "Failed to decode response from server."
                completion("Error", error)
                
                return
            }

            print("Created PaymentIntent \(clientSecret)")
            self.clientSecret = clientSecret
            
            if let range = clientSecret.range(of: "_secret_") {
                self.paymentIntentID = String(clientSecret.prefix(upTo: range.lowerBound))
            }
            
            completion(clientSecret, error)
        })

        task.resume()
    }

    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPApplePayContext.PaymentStatus, error: Error?) {
        switch status {
        case .success:
            // Payment succeeded, book session
            if let paymentIntentID = self.paymentIntentID {
                CheckoutControllerManager.shared.navigateToSuccess.wrappedValue = true
                currentUser.updateUser(data: ["isUserSubscribed" : true])
            }
            
            print("Payment complete!")
            
            break
        case .error:
            // Payment failed, show the error
            print("Payment error: \(String(describing: error?.localizedDescription))")
            CheckoutControllerManager.shared.navigateToError.wrappedValue = true
            
            break
        case .userCancellation:
            // User canceled the payment
            print("Payment cancelled")
            break
        }
    }
}
