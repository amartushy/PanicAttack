//
//  ErrorMessageModal.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI


struct ErrorMessageModal : View {
    @Binding var showErrorMessageModal : Bool
    
    var title : String
    var message : String
    

    var body: some View {
        VStack(spacing : 0) {
            HStack {
                Button {
                    showErrorMessageModal = false

                } label: {
                    Image(systemName : "xmark")
                        .foregroundColor(Color("text-bold"))
                        .opacity(0.7)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("background-element"))
                        )
                        .outerShadow()
                }
                Spacer()
                
                Text(title)
                    .font(.system(size: 18, weight : .bold))
                    .foregroundColor(Color("text-bold"))
                    .offset(x : -10)


                Spacer()

            }
            .padding()
            
            Text(verbatim: message)
                .font(.system(size: 14, weight : .medium))
                .foregroundColor(Color("text-bold"))
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            

            
            HStack(spacing : 15) {
                
                
                Button {
                    withAnimation {
                        showErrorMessageModal = false
                    }
                } label: {
                    HStack(spacing : 0) {
                        
                        Text("Ok")
                            .font(.system(size : 16, weight : .bold))
                            .foregroundColor(.white)
                    }
                    .frame( width : 200, height : 40)
                    .background(.blue)
                    .cornerRadius(10)
                    .shadow(color: Color("shadow-black"), radius: 3, x: 2, y: 2)
                }

            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
        

        }
        .frame(width : 350)
        .background(Color("background"))
        .cornerRadius(15)
        .outerShadow()
    }
}

#Preview {
    ErrorMessageModal(showErrorMessageModal: .constant(true), title: "Something went wrong", message: "There seems to be an issue. Please try again or contact support if the problem continues \n\n www.tutortree.com/support")
}

//#Preview {
//    ErrorMessageModal()
//}
