//
//  ScannerView.swift
//  CameraScanner
//
//  Created by Guo Jing Wu on 12/30/23.
//

import AVKit
import SwiftUI

struct ScannerView: View {
    @State private var isScanning:Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permissions = .idle
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    
    @State private var errorMEssage: String = ""
    @State private var showError = false
    
    let scanAnimation = Animation.easeInOut(duration: 0.85).repeatForever(autoreverses: true)
    
    var body: some View {
        VStack (spacing: 8) {
            Text("Place the QR code inside the area")
                .font(.title3)
                .padding(.top, 20)
                .foregroundColor(.black.opacity(0.8))
            Text("Scanning with start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            Spacer(minLength: 15)
            GeometryReader {
                let size = $0.size
//                CameraView(frameSize: size, session: $session)
                ZStack {
                    ForEach(1...4, id: \.self){ index in
                        let rotation = Double(index*90)
                        RoundedRectangle(cornerRadius: 2, style: .circular)
                            .trim(from: 0.61, to: 0.64)
                            .stroke(Color(.blue), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .rotationEffect(.init(degrees: rotation))
                    }
                }
                .frame(width: size.width, height: size.width)
                .overlay(alignment: .top){
                    Rectangle()
                        .fill(Color(.blue))
                        .frame(height: 2.5)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.8), radius: 8, x:0, y:15)
                        .offset(y: isScanning ? size.width : 0)
                    
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                
            }
            .padding(.horizontal, 45)
            Spacer(minLength: 15)
            Button {
                //take picture
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
            }
            Spacer(minLength: 45)
        }
        .padding(15)
        .onAppear {
            withAnimation(scanAnimation){
                isScanning = true
            }
            checkCameraPermission()
        }
        .alert(errorMEssage, isPresented: $showError) {
            
        }
    }
    
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                } else {
                    cameraPermission = .denied
                }
            case .denied, .restricted:
                cameraPermission = .denied
            default: break
            }
        }
    }
}

#Preview {
    ScannerView()
}
