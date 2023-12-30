//
//  QRScannerDelegate.swift
//  CameraScanner
//
//  Created by Guo Jing Wu on 12/30/23.
//

import AVKit
import SwiftUI

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else {return}
            guard let scannedCode = readableObject.stringValue else {return}
            print(scannedCode)
        }
    }
}
