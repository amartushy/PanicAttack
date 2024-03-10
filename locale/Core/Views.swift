//
//  Views.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import SwiftUI




struct ProfilePhotoOrInitial : View {
    
    let profilePhoto : String
    let fullName : String
    var radius : CGFloat = 40
    var fontSize : CGFloat = 20
    
    
    func getInitials(fullName : String) -> String {
        let names = fullName.split(separator: " ")

        switch names.count {
        case 0:
            return ""
        case 1:
            // Only one name provided
            return String(names.first!.prefix(1))
        default:
            // Two or more names provided, get the first and last name initials
            let firstInitial = names.first!.prefix(1)
            return "\(firstInitial)"
        }
    }

    
    var body: some View {
        
        if ( profilePhoto == "") {
            
            if fullName != "" {
                Text(getInitials(fullName: fullName))
                    .font(.system(size: fontSize))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("16171D"))
                    .frame(width: radius, height: radius)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(100)
                    .outerShadow()

                
            } else {
                Image(systemName: "person.fill")
                    .font(Font.custom("Avenir Next", size: 40))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("placeholder"))
                    .frame(width: radius, height: radius)
                    .background(Color("background-element"))
                    .cornerRadius(100)
                    .outerShadow()
            }
            
        } else {
            CachedAsyncImageView(urlString: profilePhoto)
                .scaledToFill()
                .frame(width: radius, height: radius)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(.white, lineWidth: 1)
                }
                .outerShadow()

        }
    }
}



