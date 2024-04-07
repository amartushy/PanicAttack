//
//  LocationAlertInfoView.swift
//  locale
//
//  Created by Adrian Martushev on 4/6/24.
//

import SwiftUI
import CoreLocation
import MapKit


let test_alert = LocationAlert(id: "1", lat: 123, lng: 123, userID: "123", userName: "John Doe", profilePhoto: "https://firebasestorage.googleapis.com:443/v0/b/locale-e7a62.appspot.com/o/profileImages%2FNx99faXdhZUEjOAOmhcV9KXWEcl2.jpg?alt=media&token=c70b28cc-7105-41f2-8075-6e8c4e6bfdab", dateSent: Date())

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d" // Month and day
    let dayFormatter = DateFormatter()
    dayFormatter.dateFormat = "d" // Day for ordinal calculation
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "h:mma" // Hours and minutes
    
    let day = Int(dayFormatter.string(from: date)) ?? 0
    let daySuffix = ordinalSuffix(for: day)
    
    let dateString = dateFormatter.string(from: date)
    let timeString = timeFormatter.string(from: date).lowercased() // Convert to lowercase for "am/pm"
    
    // Splitting the dateString to insert the ordinal suffix
    let dateComponents = dateString.split(separator: " ", maxSplits: 1).map(String.init)
    let formattedDate = "\(dateComponents[0]) \(day)\(daySuffix), \(timeString)"
    
    return formattedDate
}

func ordinalSuffix(for day: Int) -> String {
    switch day {
    case 1, 21, 31: return "st"
    case 2, 22: return "nd"
    case 3, 23: return "rd"
    default: return "th"
    }
}

struct LocationAlertInfoView: View {
    @Binding var showAlertInfo : Bool
    
    var locationAlert : LocationAlert
    
    func openInMapsApp() {
        // Use locationAlert's latitude and longitude
        let destinationCoordinate = CLLocationCoordinate2D(latitude: locationAlert.lat, longitude: locationAlert.lng)
        
        let placemark = MKPlacemark(coordinate: destinationCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationAlert.userName // Use the alert's userName as the destination name
        
        // Launching the Maps app with directions
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    
    var body: some View {
        VStack{
            ZStack {
                // Header
                HStack(alignment: .top) {
                    VStack {
                        Button(action: {
                            showAlertInfo.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .font(Font.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.white)
                                .frame(width: 40, height: 40)
                                .background(Color("background"))

                                .cornerRadius(15.0)
                                .outerShadow()
                        }
                        .padding(.leading)
                        Spacer()
                    }

                    
                    Spacer()
                }
                
                VStack(spacing : 20) {
                    Spacer()
                    
                    ProfilePhotoOrInitial(profilePhoto: locationAlert.profilePhoto, fullName: locationAlert.userName, radius: 100, fontSize: 40)
                    
                    if locationAlert.userName != "" {
                        Text("\(locationAlert.userName) sent an alert!")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(Color.white)
                    } else {
                        Text("A user sent an alert to this location.")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(Color.white)
                    }

                    
                    Text("\(formatDate(locationAlert.dateSent))")
                        .font(Font.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)

                    Spacer()

                }
                .padding(.horizontal, 30)
            
            }
            .padding([.top])
            

            
            Spacer()
            
            Button {
                openInMapsApp()
            } label: {
                
                HStack {
                    Spacer()

                    Image(systemName: "car.fill")
                        .foregroundColor(.white)
                    Text("Get Directions")
                        .font(.system(size: 18, weight : .bold))
                        .foregroundColor(.white)
                    Spacer()

                }
                .padding()
                .frame(height : 50)
                .background {
                    Color.blue
                }
                .cornerRadius(10)
                .outerShadow()

            }
            .padding(.bottom, 50)
            .padding(.horizontal, 30)

        }
        .background(Color("background"))
        .frame(height: 350)
        .edgesIgnoringSafeArea(.bottom)

    }
}

struct AlertAnnotation : View {
    var profilePhoto : String
    var fullName : String
    
    var body: some View {
        VStack(spacing : 0) {
            
            ZStack {

                ProfilePhotoOrInitial(profilePhoto : profilePhoto, fullName: fullName, radius: 40, fontSize: 20)
                
                Image("panic_attack_clear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .offset(x: 15, y: -15)
            }
            .padding(10)
            .background(Color(.red))
            .cornerRadius(10)
            .zIndex(10)
            
            Triangle()
                .fill(.red)
                .frame(width: 20, height: 20)
                .offset(y:-5)
        }
        .outerShadow()
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // Draw line to top right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Draw line to bottom center
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        // Close the path back to top left
        path.closeSubpath()

        return path
    }
}

#Preview {
    LocationAlertInfoView(showAlertInfo : .constant(false), locationAlert: test_alert)
}
