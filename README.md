# 🔲 iOS13 DKQRReader Example
A quick example showing how to use the `Vision` system-framework in iOS 13 and Swift 5.

## Prerequisites
* Xcode 13 and later

## Getting Started
First, import the `Vision` framework.
```swift
import Vision
```
Next, create a barcode-request that will call the completion-handler asynchronously when it detects a code:
```swift
// Create a barcode detection-request
let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { request, error in

    guard let results = request.results else { return }

    // Loop through the found results
    for result in results {
        
        // Cast the result to a barcode-observation
        if let barcode = result as? VNBarcodeObservation {
            
            // Print barcode-values
            print("Symbology: \(barcode.symbology.rawValue)")
            
            if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {                
                print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
                print("Symbol-Version: \(desc.symbolVersion)")
            }
        }
    }
})
```
Finally, call the image-request-handler with the previously create barcode-request:
```swift
// Create an image handler and use the CGImage your UIImage instance.
guard let image = myImage.cgImage else { return }
let handler = VNImageRequestHandler(cgImage: image, options: [:])

// Perform the barcode-request. This will call the completion-handler of the barcode-request.
guard let _ = try? handler.perform([barcodeRequest]) else {
    return print("Could not perform barcode-request!")
}
```
That's it! Run the app on the simulator / device and detect QR-codes.

## Author
Dineshkumar Kandasamy
