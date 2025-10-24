//
//  main.swift
//  sample
//
//  Created by API4AI Team on 05/05/2022.
//

import Foundation
extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}


// Use "demo" mode just to try api4ai for free. Free demo is rate limited.
// For more details visit:
//   https://api4.ai
//
// Use "rapidapi" if you want to try api4ai via RapidAPI marketplace.
// For more details visit:
//   https://rapidapi.com/api4ai-api4ai-default/api/cars-image-background-removal/details
let MODE = "demo"


// Your RapidAPI key. Fill this variable with the proper value if you want
// to try api4ai via RapidAPI marketplace.
let RAPIDAPI_KEY = ""


// Processing mode influences returned result. Supported values are:
// * fg-image-shadow - Foreground image with shadow added.
// * fg-image - Foreground image.
// * fg-mask - Mask image.
let RESULT_MODE = "fg-image-shadow"


let OPTIONS = [
    "demo": [
        "url": "https://demo.api4ai.cloud/img-bg-removal/v1/cars/results?mode=\(RESULT_MODE)",
        "headers": [
            "A4A-CLIENT-APP-ID": "sample"
        ] as NSMutableDictionary
    ],
    "rapidapi": [
        "url": "https://cars-image-background-removal.p.rapidapi.com/v1/results?mode=\(RESULT_MODE)",
        "headers": [
            "X-RapidAPI-Key": RAPIDAPI_KEY
        ] as NSMutableDictionary
    ]
]


// Prepare http body with image or url.
let image = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "https://static.api4.ai/samples/img-bg-removal-cars-1.jpg"
var httpBody: Data;
if (image.contains("://")) {
    // POST image via URL.
    httpBody = NSData(data: "url=\(image)".data(using: String.Encoding.utf8)!) as Data
}
else {
    // POST image as file.
    let boundary = (UUID().uuidString) // multipart boundary
    let fileLocalURL = URL(fileURLWithPath: image) // path to image file as URL object
    let mutableData = NSMutableData()
    mutableData.appendString("--\(boundary)\r\n")
    mutableData.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileLocalURL.lastPathComponent)\"\r\n\r\n")
    mutableData.append(try! Data(contentsOf: fileLocalURL))
    mutableData.appendString("\r\n")
    mutableData.appendString("--\(boundary)--")
    (OPTIONS[MODE]!["headers"] as! NSMutableDictionary)["Content-Type"] = "multipart/form-data; boundary=\(boundary)"  // add content type with boundary to headers
    httpBody = mutableData as Data
}

// Prepare request.
var request = URLRequest(url: URL(string: OPTIONS[MODE]!["url"] as! String)!)
request.httpMethod = "POST"
request.allHTTPHeaderFields = OPTIONS[MODE]!["headers"] as? [String:String]
request.httpBody = httpBody

// Semaphore to wait until request is done.
let sem = DispatchSemaphore(value: 0)

// Perform request.
let session = URLSession.shared
let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
    if (error != nil) {
        print(error!)
    } else {
        do {
            // Try to parse result from response data as JSON.
            let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
            let result = (json["results"] as! [[String:Any]])[0]

            // Parse and pring status.
            let status = result["status"] as! [String:String]
            if (status["code"] == "ok") {
                // Parse data.
                let entity = (result["entities"] as! [[String:Any]])[0]
                let imageAsBase64 = entity["image"] as! String
                let imageAsData = NSData(base64Encoded: imageAsBase64)!

                // Store data to file in current directory.
                imageAsData.write(toFile: "result.png", atomically: true)
                
                // Print message.
                print("💬 The \"result.png\" image is saved to the '\(FileManager().currentDirectoryPath)' directory.")
            }
        } catch {
            print(error)
        }
    }
    sem.signal()
})
dataTask.resume()

// Wait for request is done.
sem.wait()
