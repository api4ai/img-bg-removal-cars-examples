using System;
using System.Net.Http;
using System.Text.Json.Nodes;

using MimeTypes;
using RestSharp;


/*
 * Use "demo" mode just to try api4ai for free. Free demo is rate limited.
 * For more details visit:
 *   https://api4.ai
 *
 * Use 'rapidapi' if you want to try api4ai via RapidAPI marketplace.
 * For more details visit:
 *   https://rapidapi.com/api4ai-api4ai-default/api/cars-image-background-removal/details
 */

const String MODE = "demo";


/*
 * Your RapidAPI key. Fill this variable with the proper value if you want
 * to try api4ai via RapidAPI marketplace.
 */
const String RAPIDAPI_KEY = "";

/*
 * Processing mode influences returned result. Supported values are:
 * - fg-image-shadow - Foreground image with shadow added.
 * - fg-image - Foreground image.
 * - fg-mask - Mask image.
 */
const String RESULT_MODE = "fg-image-shadow";

String url;
Dictionary<String, String> headers = new Dictionary<String, String>();

switch (MODE) {
    case "demo":
        url = $"https://demo.api4ai.cloud/img-bg-removal/v1/cars/results?mode={RESULT_MODE}";
        headers.Add("A4A-CLIENT-APP-ID", "sample");
        break;
    case "rapidapi":
        url = $"https://cars-image-background-removal.p.rapidapi.com/v1/results?mode={RESULT_MODE}";
        headers.Add("X-RapidAPI-Key", RAPIDAPI_KEY);
        break;
    default:
        Console.WriteLine($"[e] Unsupported mode: {MODE}");
        return 1;
}

// Prepare request.
String image = args.Length > 0 ? args[0] : "https://storage.googleapis.com/api4ai-static/samples/img-bg-removal-cars-1.jpg";
var client = new RestClient(new RestClientOptions(url) { ThrowOnAnyError = true });
var request = new RestRequest();
if (image.Contains("://")) {
    request.AddParameter("url", image);
} else {
    request.AddFile("image", image, MimeTypeMap.GetMimeType(Path.GetExtension(image)));
}
request.AddHeaders(headers);

// Perform request.
var jsonResponse = (await client.ExecutePostAsync(request)).Content!;

// Parse response.
JsonNode docRoot = JsonNode.Parse(jsonResponse)!.Root;
String imgB64 = docRoot["results"]![0]!["entities"]![0]!["image"]!.GetValue<String>();

// Convert image from base64 to binary and save as png image file.
byte[] imgBytes = Convert.FromBase64String(imgB64);
using (FileStream fs = File.OpenWrite("result.png")) {
    fs.Write(imgBytes, 0, imgBytes.Length);
}
Console.WriteLine($"[i] The 'result.png' image is saved to the '{Directory.GetCurrentDirectory()}' directory.");

return 0;
