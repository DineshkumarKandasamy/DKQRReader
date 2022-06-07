//
//  DKQRReaderManager.swift
//  DKQRReader
//
//  Created by Dineshkumar Kandasamy on 07/06/22.
//

import Foundation
import Vision
import AVKit
import UIKit

///DKQRReaderManager handle the Vision framework

public class DKQRReaderManager {
    
    static public let shared = DKQRReaderManager()
    
    /// CGImage will  be processed and image results will decode the payload

    public func scanImage(cgImage: CGImage) {
        
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { request, error in
            self.getResults(results: request.results)
        })
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [.properties : ""])
        
        guard let _ = try? handler.perform([barcodeRequest]) else {
            return print("Could not perform barcode-request!")
        }
        
    }
    
    /// Based on scan image results will be available
    
    private func getResults(results: [Any]?) {
        
        guard let results = results else {
            return print("No results found.")
        }
        
        for result in results {
            
            if let barcode = result as? VNBarcodeObservation {
                
                /// Payload string value can be retrived from the result
                
                if let payload = barcode.payloadStringValue {
                    print("Payload: \(payload)")
                }
                
                if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
                    print("Symbology: \(barcode.symbology.rawValue)")
                    print("Symbol-Version: \(desc.symbolVersion)")
                }
            }
        }
        
    }
    
    
}

