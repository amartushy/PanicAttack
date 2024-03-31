import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var isUserSubscribed: Bool = false
    private var productID = "monthly_premium"
    private var premiumProduct: SKProduct?

    override init() {
        super.init()
        print("StoreManager initialized.")
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        print("Fetching products...")
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Check if the fetched products list is not empty
            if !response.products.isEmpty {
                // Iterate over all products in the response
                for product in response.products {
                    // Print details of each product
                    print("Product fetched:")
                    print("Product ID: \(product.productIdentifier)")
                    print("Product Name: \(product.localizedTitle)")
                    print("Product Price: \(product.price)")
                    print("Product Description: \(product.localizedDescription)")
                    // Check if this is the specific product we're interested in
                    if product.productIdentifier == self.productID {
                        self.premiumProduct = product
                    }
                }
            } else {
                print("No products found in App Store response.")
            }
            
            // Check for invalid product identifiers
            if !response.invalidProductIdentifiers.isEmpty {
                print("Invalid product identifiers found:")
                for invalidIdentifier in response.invalidProductIdentifiers {
                    print(invalidIdentifier)
                }
            }
        }
    }
    
    func startSubscriptionProcess(completion: @escaping (Bool, String?) -> Void) {
        guard let product = premiumProduct else {
            print("Attempted to start subscription process, but product is nil.")
            completion(false, "Product not found. Please try again later.")
            return
        }
        
        print("Starting subscription process for product: \(product.productIdentifier)")
        buyProduct(product)
    }
    
    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        print("Added payment for product: \(product.productIdentifier) to the payment queue.")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("Transaction state updated: \(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
            case .purchased, .restored:
                print("Transaction successful for product ID: \(String(describing: transaction.payment.productIdentifier)).")
                DispatchQueue.main.async {
                    self.isUserSubscribed = true
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                print("Transaction failed for product ID: \(String(describing: transaction.payment.productIdentifier)). Error: \(String(describing: transaction.error))")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print("Transaction in an unhandled state: \(transaction.transactionState.rawValue)")
            }
        }
    }
    
    @available(iOS 15.0, *)
    func checkActiveSubscription() async {
        print("Checking for active subscription...")
        do {
            for try await transaction in Transaction.currentEntitlements {
                guard case .verified(let verifiedTransaction) = transaction else {
                    print("Transaction not verified or in an unexpected state.")
                    continue
                }
                
                if verifiedTransaction.productID == productID,
                   verifiedTransaction.revocationDate == nil,
                   let expiryDate = verifiedTransaction.expirationDate, expiryDate > Date() {
                    print("Active subscription found.")
                    DispatchQueue.main.async {
                        self.isUserSubscribed = true
                    }
                    return
                }
            }
        } catch {
            print("Failed to check for active subscriptions: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isUserSubscribed = false
        }
        print("No active subscription found.")
    }
}
