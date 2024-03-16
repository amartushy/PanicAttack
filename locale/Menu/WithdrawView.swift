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
    
    @Binding var showWithdrawal : Bool
        
    @State var withdrawalAmount: String = "0.00"
    @State var withdrawalMethod = ""

    @State var showLoading = false
    
    
    var body: some View {
        
        ZStack {
            VStack {
                //Header
                ZStack {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
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
                
                
                WithdrawalTextField(withdrawalAmount: $withdrawalAmount, withdrawalMethod: $withdrawalMethod)
            
                
                HStack {
                    Button(action: {
                        self.withdrawalMethod = "paypal"
                    }) {
                        
                        VStack {
                            Image("paypal")
                                .resizable()
                                .frame(width : 80, height : 80)
                                .foregroundColor(withdrawalMethod == "paypal" ? .white : Color("placeholder"))

                        }
                        .frame(width: 150, height: 150)
                        .background(withdrawalMethod == "paypal" ? .white : Color("background-element"))
                        .cornerRadius(15)
                        .outerShadow(applyShadow: !(withdrawalMethod == "paypal"))
                    }

                    Button(action: {
                        self.withdrawalMethod = "bank"

                    }) {
                        
                        VStack {
                            Image(systemName : "building.columns.fill")
                                .resizable()
                                .frame(width : 40, height : 40)
                                .foregroundColor(withdrawalMethod == "bank" ? .blue : Color("placeholder"))
                            
                            Text("Bank")
                                .font(Font.system(size: 18, weight: .bold))
                                .foregroundColor(withdrawalMethod == "bank" ? .blue : Color("placeholder"))
                        }
                        .frame(width: 150, height: 150)
                        .background(withdrawalMethod == "bank" ? .white : Color("background-element"))
                        .cornerRadius(15)
                        .outerShadow(applyShadow: !(withdrawalMethod == "bank"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                
                let isDisabled = Double(withdrawalAmount) ?? 0.0 > 0 && withdrawalMethod != ""
                
                Button {
                    showLoading = true
                    let withdrawalData: [String: Any] = [
                        "userID": currentUser.currentUserID,
                        "dateWithdrawn": Date(),
                        "amount": Double(withdrawalAmount) ?? 0.0,
                        "type": withdrawalMethod,
                        "status" : "unpaid"
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

                        Text("Withdraw $\(withdrawalAmount)")
                            .font(.system(size: 16, weight : .bold))
                            .foregroundColor(isDisabled ? .white : .white.opacity(0.4))
                        Spacer()

                    }
                    .padding()
                    .frame(height : 50)
                    .background { isDisabled ? Color.blue : Color("background-element") }
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
        .onAppear {
            showLoading = false
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
                        .foregroundColor(Double(self.withdrawalAmount) ?? 0.0 < currentUser.user.balance ? Color("text-bold") : Color(.red))
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
//#Preview {
//    WithdrawView(showWithdrawal: .constant(true) )
//}
