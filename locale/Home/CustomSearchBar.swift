//
//  CustomSearchBar.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI


struct CustomSearchBar : View {
    
    @State var searchText : String = ""
    @State var isEditing : Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color("background-textfield")
                        .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                        .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                    )
                    .frame(height : 40)
                    .cornerRadius(100)

                
                HStack {
                    
                    Image(systemName: "mic.fill")
                        .foregroundColor(Color("placeholder"))
                        .padding(.trailing, 5 )
                        .padding(.leading)
                    
                    
                    if searchText == "" && !isEditing {
                    
                        Text("Search")
                            .font(.custom("SF Pro", size: 16))
                            .foregroundColor(Color("placeholder"))
                            .fontWeight(.bold)
                    }
                
                    
                    Spacer()
                }
                
                TextField("", text: $searchText)
                    .frame(height : 40)
                    .foregroundColor(Color("text-bold"))
                    .padding(.leading, 50)
                    .onTapGesture {
                        isEditing = true
                    }
            }
            
            Spacer()

        }
    }
}

#Preview {
    CustomSearchBar()
}
