//
//  CreateNewLocationView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//
import SwiftUI
import MapKit




extension CLLocationCoordinate2D {
  static let towerBridge = CLLocationCoordinate2D(latitude: 51.5055, longitude: -0.075406)
  static let boe = CLLocationCoordinate2D(latitude: 51.5142, longitude: -0.0885)
  static let hydepark = CLLocationCoordinate2D(latitude: 51.508611, longitude: -0.163611)
  static let kingsCross = CLLocationCoordinate2D(latitude: 51.5309, longitude: -0.1233)
}


struct CreateNewLocationView: View {
    @Binding var showSheet: Bool
    
    @EnvironmentObject var locationVM : LocationViewModel
    @EnvironmentObject var currentUser : CurrentUserViewModel

    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 1000, longitudinalMeters: 1000)
        
    private func updateRegion(with location: CLLocation?) {
        guard let location = location else { return }
        let coordinate = location.coordinate
        region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                // Header
                HStack {
                    Button(action: {
                        showSheet.toggle()
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
                
                HStack {
                    Spacer()
                    
                    Text("New Location Alert")
                        .font(Font.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)

                    Spacer()
                }
            }
            .padding([.top, .bottom])
            
            VStack(spacing : 20) {
                Text("Send an alert to your location. Anyone within 10 miles will be notified and be able to see your location on the map.")
                    .font(Font.system(size: 14))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                
                
                
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .none)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .onChange(of: locationVM.userLocation) { _, newLocation in
                        updateRegion(with: newLocation)
                    }

            

            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button {
                locationVM.sendLocationAlert()
                showSheet.toggle()

            } label: {
                
                HStack {
                    Spacer()

                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                    Text("PANIC")
                        .font(.system(size: 18, weight : .bold))
                        .foregroundColor(.white)
                    Spacer()

                }
                .padding()
                .frame(height : 50)
                .background {
                    Color.red
                }
                .cornerRadius(10)
                .outerShadow()

            }
            .padding(.bottom, 50)
            .padding(.horizontal, 30)

        }
        .background(Color("background"))
        .frame(height: 500)

    }
}






// Custom Slider Wrapper
struct CustomSlider: UIViewRepresentable {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    
    // UIKit UISlider configuration
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
        
        // Customizing the slider appearance
        slider.minimumTrackTintColor = .darkGray // Left (or bottom) track color
        slider.maximumTrackTintColor = .lightGray // Right (or top) track color
        slider.thumbTintColor = .white // Thumb color
        
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(value)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value, step: step)
    }
    
    // Coordinator for handling value changes
    class Coordinator: NSObject {
        var value: Binding<Double>
        var step: Double
        
        init(value: Binding<Double>, step: Double) {
            self.value = value
            self.step = step
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            let steppedValue = round(Double(sender.value) / step) * step
            self.value.wrappedValue = steppedValue
        }
    }
}

// Usage in a SwiftUI view
struct ContentView: View {
    @State private var sliderValue: Double = 20
    
    var body: some View {
        VStack {
            CustomSlider(value: $sliderValue, range: 1...40, step: 1)
                .padding()
            
            Text("Value: \(sliderValue)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




#Preview {
    CreateNewLocationView(showSheet : .constant(true))
        .environmentObject(LocationViewModel())
        .environmentObject(CurrentUserViewModel())
}
