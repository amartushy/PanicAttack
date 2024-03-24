//
//  ConfirmVideoUploadView.swift
//  locale
//
//  Created by Adrian Martushev on 3/9/24.
//

import SwiftUI
import AVFoundation
import CoreLocation


struct ConfirmVideoUploadView: View {
    @EnvironmentObject var videoVM : VideoUploadViewModel
    @EnvironmentObject var locationVM : LocationViewModel

    @Binding var showSheet: Bool

    
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
                    
                    Text("Upload Footage")
                        .font(Font.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)

                    Spacer()
                }
            }
            .padding([.top, .bottom])
            
            VStack(spacing : 20) {
                Text("Upload your footage. You will earn $11.50 for this uploading this video")
                    .font(Font.system(size: 14))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Include video preview if the URL exists
                HStack {
                    Spacer()
                    if let videoURL = videoVM.videoURL {
                        let player = AVPlayer(url: videoURL)

                        VideoPlayerView(url: videoURL, player : player)
                            .frame(height: 200) // Set a fixed height for the video player
                    }
                    Spacer()
                }
                .cornerRadius(12)
                .frame(height: 200)
                .background(.black)

            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button {
                let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)

                Task {
                    await videoVM.uploadVideoToFirebase(with: locationVM.userLocation ?? defaultLocation)
                }
                showSheet.toggle()

            } label: {
                
                HStack {
                    Spacer()

                    Image(systemName: "icloud.and.arrow.up.fill")
                        .foregroundColor(.white)
                    Text("Upload")
                        .font(.system(size: 18, weight : .bold))
                        .foregroundColor(.white)
                    Spacer()

                }
                .padding()
                .frame(height : 50)
                .background {Color.blue}
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


extension VideoUploadViewModel {
    func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        // Set the maximum size to ensure the thumbnail is not too large. If you don't need to resize, you can remove this line.
        assetImgGenerate.maximumSize = CGSize(width: 600, height: 600)
        
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}


struct VideoPlayerView: UIViewRepresentable {
    var url: URL
    var player : AVPlayer

     func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        // Setup the player
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)

        // Adjust the playerLayer to match the UIView size
        context.coordinator.adjustPlayerLayer(playerLayer: playerLayer, view: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            // Ensure the player layer is correctly resized and positioned
            if let layer = uiView.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer {
                layer.frame = uiView.bounds
            }
            // Optionally, start or control playback here
//            self.player.play()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: VideoPlayerView

        init(_ parent: VideoPlayerView) {
            self.parent = parent
        }

        func adjustPlayerLayer(playerLayer: AVPlayerLayer, view: UIView) {
            playerLayer.frame = view.bounds
        }
    }
}

