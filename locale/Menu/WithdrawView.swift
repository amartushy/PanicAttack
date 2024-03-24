//
//  WithdrawSheet.swift
//  locale
//
//  Created by Adrian Martushev on 3/16/24.
//

import SwiftUI


struct WithdrawView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @EnvironmentObject var onboardingVM : StripeOnboardingViewModel
    
    @State var amountString = "0.00"
    @State var method = ""
    @State var showLoading = false
    
    var fee : Double {
        let value = (Double(amountString) ?? 0.0) * 0.0175 + 0.25
        return value
    }
    
    var total : Double {
        let amount = Double(amountString) ?? 0.0
        let value = method == "instant" ? amount - fee : amount
        return max(0.0, value)
    }
    
    
    @State var showWithdrawalMethods = false
    @Binding var showWithdrawal : Bool
    
    var body: some View {
        
        ZStack {
            VStack {
                //Header
                ZStack {
                    HStack {
                        Button(action: {
                            showWithdrawal = false
                            generateHapticFeedback()

                        }) {
                            Image(systemName: "xmark")
                                .font(Font.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("text-bold"))
                                .opacity(0.7)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color("background-element"))
                                )
                                .outerShadow()
                        }
                        .padding(.leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Text("Withdraw Balance")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(Color("text-bold"))
                        Spacer()
                    }
                }
                .padding([.top, .bottom])
                .navigationTitle("")
                .navigationBarHidden(true)
                
                Divider()
                
                
                WithdrawalTextField(withdrawalAmount: $amountString , withdrawalMethod: $method)
            
                
                HStack(spacing : 10) {
                    Button(action: {
                        self.method = "instant"
                        generateHapticFeedback()

                    }) {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("background-withdrawal")
                                    .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                                    .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                                )
                                .frame( height: 150)
                                .cornerRadius(15)
                            
                            VStack(spacing : 0) {
                                Image(systemName : "bolt.fill")
                                    .resizable()
                                    .frame(width : 25, height : 25)
                                    .foregroundColor(method == "instant" ? .white : Color("placeholder"))
                                    .background {
                                        Circle()
                                            .foregroundColor(method == "instant" ? Color("toggleOn") : .white.opacity(0.2))
                                            .frame(width : 60, height : 60)
                                    }
                                    .frame(width : 60, height : 60)

                                HStack {
                                    Spacer()
                                }
                                Text("Instant")
                                    .font(Font.system(size: 16, weight: .semibold))
                                    .foregroundColor(method == "instant" ? Color("text-bold") : Color("placeholder"))
                                    .padding(.vertical, 5)
                                
                                Text("In a few minutes")
                                    .font(Font.system(size: 14, weight: .regular))
                                    .foregroundColor(method == "instant" ? Color("placeholder") : .clear)
                            }
                            .frame( height: 150)
                            .background(method == "instant" ? .clear : Color("background-element"))
                            .cornerRadius(15)
                            .outerShadow(applyShadow: !(method == "instant"))
                        }

                    }

                    Button(action: {
                        self.method = "standard"
                        generateHapticFeedback()
                    }) {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color("background-withdrawal")
                                    .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                                    .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                                )
                                .frame( height: 150)
                                .cornerRadius(15)
                            
                            VStack(spacing : 0) {
                                Image(systemName : "building.columns.fill")
                                    .resizable()
                                    .frame(width : 25, height : 25)
                                    .foregroundColor(method == "standard" ? .white : Color("placeholder"))
                                    .background {
                                        Circle()
                                            .foregroundColor(method == "standard" ? Color("toggleOn") : .white.opacity(0.2))
                                            .frame(width : 60, height : 60)
                                    }
                                    .frame(width : 60, height : 60)

                                
                                HStack {
                                    Spacer()
                                }
                                
                                Text("Standard")
                                    .font(Font.system(size: 16, weight: .semibold))
                                    .foregroundColor(method == "standard" ? Color("text-bold") : Color("placeholder"))
                                    .padding(.vertical, 5)

                                Text("1-3 business days")
                                    .font(Font.system(size: 14, weight: .regular))
                                    .foregroundColor(method == "standard" ? Color("placeholder") : .clear)
                            }
                            .frame(height: 150)
                            .background(method == "standard" ? .clear : Color("background-element"))
                            .cornerRadius(15)
                            .outerShadow(applyShadow: !(method == "standard"))
                        }

                    }
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                
                
                VStack {
                         
                    
                    VStack {
                        if method == "instant" {
                            Divider()

                            HStack {
                                Text("Fee")
                                    .font(Font.system(size: 14, weight: .semibold))

                                Spacer()
                                
                                Text("$\( String(format : "%.2f", fee) )")
                                    .font(Font.system(size: 12, weight: .regular))
                            }
                            .frame(height : 30)
                        }

                    }
                    .frame(height : 40)

                    Divider()
                    
                    
                    HStack(alignment : .center) {
                        Text("Transfer to")
                            .font(Font.system(size: 14, weight: .semibold))

                        Spacer()
                        
                        Button {
                            showWithdrawalMethods = true
                        } label: {
                            
                            WithdrawalOptionPreview()

                        }
                        .sheet(isPresented: $showWithdrawalMethods, content: {
                            WithdrawalMethodsSheet()
                        })

                    }
                    .frame(height : 30)
                    
                    Divider()
                }
                .padding(.horizontal, 30)
                .foregroundColor(Color("text-bold"))



                
                let isDisabled = Double(amountString) ?? 0.0 > 0 && method != ""
                
                Button {
                    showLoading = true
                    let withdrawalMethod = onboardingVM.selectedWithdrawalMethod
                    
                    let withdrawalMethodData: [String: Any] = {
                        switch withdrawalMethod {
                        case .bankAccount(let account):
                            return ["type": "bankAccount", "bank_name": account.bank_name, "last4": account.last4]
                        case .debitCard(let card):
                            return ["type": "debitCard", "brand": card.brand, "last4": card.last4]
                        case .none:
                            return ["type": "none"]
                        }
                    }()
                    
                    let withdrawalData: [String: Any] = [
                        "userID": currentUser.currentUserID,
                        "dateWithdrawn": Date(),
                        "amount": Double(amountString) ?? 0.0,
                        "fee" : fee,
                        "total" : total,
                        "withdrawalMethod": withdrawalMethodData,
                        "status" : "unpaid",
                        "stripeAccountID"  : currentUser.stripeAccountID
                    ]
                    
                    currentUser.submitWithdrawal(withdrawalData: withdrawalData) { success, message in
                        if success {
                            // Handle successful withdrawal, such as dismissing the view
                            self.presentationMode.wrappedValue.dismiss()
                            showWithdrawal = false

                        } else {
                            // Handle failure, such as showing an error message
                            print(message)
                        }
                    }

                } label: {
                    
                    HStack {
                        Spacer()
                        Text("Withdraw $\(String(format : "%.2f", total))")
                            .font(.system(size: 16, weight : .bold))
                            .foregroundColor(isDisabled ? .white : Color("text-withdrawal"))
                        Spacer()

                    }
                    .padding()
                    .frame(height : 50)
                    .background { isDisabled ? Color("toggleOn") : Color("background-element") }
                    .cornerRadius(10)
                    .outerShadow(applyShadow: isDisabled)

                }
                .padding(.vertical, 30)
                .padding(.horizontal, 30)
                .disabled(!isDisabled)
                
            }
            .background(Color("background"))
            .onTapGesture {
                hideKeyboard()
            }
            .overlay(
                Color.black.opacity(showLoading ? 0.5 : 0)
                    .edgesIgnoringSafeArea(.all)

            )
            
            
            if showLoading {
                ProgressView("Submitting withdrawal..")
            }
        }
        
    }
}


struct WithdrawalTextField : View {
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    @Binding var withdrawalAmount : String
    @Binding var withdrawalMethod : String

    @State var isEditing = false
    
    @State private var textWidth: CGFloat = 0
    
    func calculateTextWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
    
    var body: some View {
        //Body
        VStack(alignment: .center) {
            Spacer()

            HStack(alignment: .top) {
                
                Spacer()
                
                Text("$")
                    .font(Font.system(size: 18, weight: .bold))
                    .foregroundColor(Color("text-bold"))
                    .opacity(0.7)
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("background-textfield")
                            .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                            .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                        )
                        .frame(width: max(100, textWidth), height: 60)
                        .cornerRadius(15)

                    
                    if withdrawalAmount == "" && !isEditing {
                    
                        Text("0.00")
                            .font(Font.system(size: 36, weight: .bold))
                            .foregroundColor(Double(self.withdrawalAmount) ?? 0.0 <= currentUser.user.balance ? Color("placeholder") : Color(.red))
                            .multilineTextAlignment(.center) // Ensure text is centered
                            .frame(width: max(100, textWidth), height: 60)

                    }
                    
                    TextField("", text: $withdrawalAmount)
                        .onChange(of: withdrawalAmount) { oldValue, newValue in
                            textWidth = self.calculateTextWidth(text: newValue, font: .systemFont(ofSize: 40, weight: .bold))
                        }
                        .font(Font.system(size: 36, weight: .bold))
                        .foregroundColor(Double(self.withdrawalAmount) ?? 0.0 <= currentUser.user.balance ? Color("text-bold") : Color(.red))
                        .opacity(0.9)
                        .multilineTextAlignment(.center) // Ensure text is centered
                        .frame(width: max(100, textWidth), height: 40)
                        .keyboardType(.decimalPad)
                        .onAppear {
                            // Initial calculation
                            textWidth = self.calculateTextWidth(text: withdrawalAmount, font: .systemFont(ofSize: 40, weight: .bold))
                        }
                        .onTapGesture {
                            isEditing = true
                        }
                }
                
                
                if Double(self.withdrawalAmount) ?? 0.0 > 0.0 {
                    Button {
                        self.withdrawalAmount = ""
                    } label: {
                        Image(systemName: "xmark")
                            .font(Font.system(size: 14, weight: .bold))
                            .foregroundColor(Color("text-bold"))
                    }
                } else {
                    Text("")
                        .frame(width : 10)
                }
                
                Spacer()
            }
            
            Text("Withdraw up to $\(String(format: "%.2f", currentUser.user.balance))")
                .font(Font.system(size: 12, weight: .semibold))
                .foregroundColor(Color("text-bold"))
                .opacity(0.7)
            
            Spacer()
                                
        }
        .padding([.leading, .top, .trailing])
    }
}



struct WithdrawalMethodsSheet : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var onboardingVM : StripeOnboardingViewModel
    
    var body: some View {
        VStack {
            VStack {
                //Header
                ZStack {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                            generateHapticFeedback()

                        }) {
                            Image(systemName: "xmark")
                                .font(Font.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("text-bold"))
                                .opacity(0.7)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color("background-element"))
                                )
                                .outerShadow()
                        }
                        .padding(.leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Text("Select Bank or Debit Card")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(Color("text-bold"))
                        Spacer()
                    }
                }
                .padding([.top, .bottom])
                .navigationTitle("")
                .navigationBarHidden(true)
                
                Divider()
                
                VStack {
                    ForEach(onboardingVM.withdrawalMethods?.bank_accounts ?? [], id: \.last4) { account in
                        Button(action: {
                            onboardingVM.selectedWithdrawalMethod = .bankAccount(account)
                        }, label: {
                            WithdrawalOption(account: account)
                        })
                    }

                    ForEach(onboardingVM.withdrawalMethods?.debit_cards ?? [], id: \.last4) { card in
                        Button(action: {
                            onboardingVM.selectedWithdrawalMethod = .debitCard(card)
                        }, label: {
                            WithdrawalOption(card: card)
                        })
                    }
                }
                .padding()
                

                
            }
            Spacer()
            
            
        }
        .background(Color("background"))

    }
}



func getBankImage(bankName : String) -> String {
    switch bankName {
    case "STRIPE TEST BANK":
        return "default" // Example; replace with your actual image asset name
    // Add more cases as needed for different banks
        
    case "WELLS FARGO BANK NA" :
        return "wells_fargo_icon"
    default:
        return "default" // A default icon if the bank name doesn't match
    }
}


struct WithdrawalOption : View {
    @EnvironmentObject var onboardingVM : StripeOnboardingViewModel
    
    var account: BankAccount? = nil
    var card: DebitCard? = nil
    
    
    var body: some View {
        // Determine the type and if it's selected
        if let account = account {
            VStack {
                HStack {
                    if getBankImage(bankName: account.bank_name) == "default" {
                        Image(systemName: "building.columns")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.4))
                            .frame(width: 50, height: 30)
                            .background(Color.white)
                            .cornerRadius(5)
                    } else {
                        Image(getBankImage(bankName: account.bank_name)) // Direct use in Image initializer
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 30)
                    }

                    
                    VStack( alignment : .leading ) {
                        Text("\(account.bank_name)")
                            .font(.system(size: 16, weight : .regular))
                            .foregroundColor(Color("text-bold"))
                        
                        Text("••\(account.last4)")
                            .font(.system(size: 14, weight : .regular))
                            .foregroundColor(Color("text-bold"))
                        
                    }
                    
                    Spacer()
                    
                    if onboardingVM.selectedWithdrawalMethod == .bankAccount(account) {
                        Image(systemName : "checkmark")
                            .foregroundColor(Color("text-bold"))
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
            }
        } else if let card = card {
            VStack {
                HStack {
                    if getBankImage(bankName: card.brand) == "default" {
                        Image(systemName: "building.columns")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.4))
                            .frame(width: 50, height: 30)
                            .background(Color.white)
                            .cornerRadius(5)
                    } else {
                        Image(getBankImage(bankName: card.brand))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 30)
                    }

                    
                    VStack( alignment : .leading ) {
                        Text("\(card.brand)")
                            .font(.system(size: 16, weight : .regular))
                            .foregroundColor(Color("text-bold"))
                        
                        Text("••\(card.last4)")
                            .font(.system(size: 14, weight : .regular))
                            .foregroundColor(Color("text-bold"))
                        
                    }
                    
                    Spacer()
                    
                    if onboardingVM.selectedWithdrawalMethod == .debitCard(card) {
                        Image(systemName : "checkmark")
                            .foregroundColor(Color("text-bold"))
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
            }
        } else {
            fatalError("WithdrawalOption must be provided with either a bank account or debit card")
        }
    }
}


struct WithdrawalOptionPreview: View {
    @EnvironmentObject var onboardingVM: StripeOnboardingViewModel
    

    // Helper function to extract and display information based on the selected method
    @ViewBuilder
    private func selectedMethodView() -> some View {
        switch onboardingVM.selectedWithdrawalMethod {
        case .bankAccount(let account):
            methodView(name: account.bank_name, last4: account.last4, bankName: account.bank_name)
        case .debitCard(let card):
            methodView(name: card.brand, last4: card.last4, bankName: card.brand)
        case .none:
            Text("No method selected")
                .font(Font.system(size: 12, weight: .regular))
                .foregroundColor(Color("text-bold"))
        }
    }
    
    // Common view for displaying method information
    @ViewBuilder

    private func methodView(name: String, last4: String, bankName: String) -> some View {
        HStack {
            Spacer()

            
            if getBankImage(bankName: bankName) == "default" {
                Image(systemName: "building.columns")
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.4))
                    .frame(width: 30, height: 20)
                    .background(Color.white)
                    .cornerRadius(5)
            } else {
                Image(getBankImage(bankName: bankName))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 20)
            }

            Text("\(name) ••\(last4)")
                .font(Font.system(size: 12, weight: .regular))
                .foregroundColor(Color("text-bold"))


            Image(systemName: "chevron.right")
        }

    }
    
    var body: some View {
        VStack {
            selectedMethodView()
        }
    }
}

//#Preview {
//    WithdrawalMethodsSheet()
//        .environmentObject(StripeOnboardingViewModel())
//}
