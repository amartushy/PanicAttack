//
//  Extensions.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import Foundation
import UIKit
import SwiftUI



extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func outerShadow(applyShadow: Bool = true) -> some View {
        Group {
            if applyShadow {
                self
                    .shadow(color: Color("shadow-white"), radius: 1, x: -1, y: -1)
                    .shadow(color: Color("shadow-black"), radius: 3, x: 2, y: 2)
            } else {
                self
            }
        }
    }
}



//Modals and Top/Bottom sheets

//Center growing modal for errors and other views
struct CenterGrowingModalModifier: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPresented ? 1 : 0.5)
            .opacity(isPresented ? 1 : 0)
            .animation(.easeInOut, value: isPresented)
    }
}

// Extension to use the modifier easily
extension View {
    func centerGrowingModal(isPresented: Bool) -> some View {
        self.modifier(CenterGrowingModalModifier(isPresented: isPresented))
    }
}



// Top down sheet, used for the calendar
struct TopDownSheetModifier: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .offset(y: isPresented ? 0 : -UIScreen.main.bounds.height)
            .animation(.easeInOut, value: isPresented)

    }
}

// Extension to use the modifier easily
extension View {
    func topDownSheet(isPresented: Bool) -> some View {
        self.modifier(TopDownSheetModifier(isPresented: isPresented))
    }
}


// Bottom up sheet, used for the calendar

struct BottomUpSheetModifier: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}



struct LeadingEdgeSheetModifier: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: isPresented ? 0 : -UIScreen.main.bounds.width)
            .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

// Extension to use the modifier easily
extension View {
    func leadingEdgeSheet(isPresented: Bool) -> some View {
        self.modifier(LeadingEdgeSheetModifier(isPresented: isPresented))
    }
}



// Extension to use the modifier easily
extension View {
    func bottomUpSheet(isPresented: Bool) -> some View {
        self.modifier(BottomUpSheetModifier(isPresented: isPresented))
    }
}
