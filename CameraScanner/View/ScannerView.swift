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
    
    @State private var errorMEssage: String = ""
    @State private var showError = false
    @Environment(\.openURL) private var openURL
    
    @StateObject private var qrDelegate = QRScannerDelegate()
    
    let scanAnimation = Animation.easeInOut(duration: 0.85).repeatForever(autoreverses: true)
    
    var body: some View {
        VStack (spacing: 8) {
            
            Text("Place the QR code inside the area")
                .font(.title3)
                .padding(.top, 20)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            Text("Scanning with start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            
            Spacer(minLength: 0)
            
            GeometryReader {
                let size = $0.size
                CameraView(frameSize: CGSize(width: size.width, height: size.width), session: $session)
                    .scaleEffect(0.97)
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
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.8), radius: 8, x:0, y:isScanning ? 15 : -15)
                        .offset(y: isScanning ? size.width : 0)
                    
                }
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
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let seettingsURL = URL(string: settingsString){
                        openURL(seettingsURL)
                    }
                }
                
                Button("Cancel", role: .cancel){}
            }
        }
    }
    
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                setupCamera()
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    cameraPermission = .denied
                    presentError("Please provide access to camera for scanning codes")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please provide access to camera for scanning codes")
            default: break
            }
        }
    }
    
    func presentError(_ message: String) {
        errorMEssage = message
        showError.toggle()
    }
    
    func setupCamera(){
        do {
            guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: .back).devices.first
            else {
                presentError("unknown error")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            let qrOutput = AVCaptureMetadataOutput()

            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("Unknown Error")
                return
            }
            
            session.beginConfiguration()
            session.addInput(input)
            
            session.addOutput(qrOutput)
            qrOutput.metadataObjectTypes = qrOutput.availableMetadataObjectTypes
            
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
        } catch {
            presentError(error.localizedDescription)
        }
    }
}

#Preview {
    ScannerView()
}
