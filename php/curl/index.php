#!/usr/bin/env php

<?php
// Example of using API4AI car image background removal.

// Use 'demo' mode just to try api4ai for free. Free demo is rate limited.
// For more details visit:
//   https://api4.ai

// Use 'rapidapi' if you want to try api4ai via RapidAPI marketplace.
// For more details visit:
//   https://rapidapi.com/api4ai-api4ai-default/api/cars-image-background-removal/details
$MODE = 'demo';

// Your RapidAPI key. Fill this variable with the proper value if you want
// to try api4ai via RapidAPI marketplace.
$RAPIDAPI_KEY = null;

// Processing mode influences returned result. Supported values are:
// * fg-image-shadow - Foreground image with shadow added.
// * fg-image - Foreground image.
// * fg-mask - Mask image.
$RESULT_MODE = 'fg-image-shadow';

$OPTIONS = [
    'demo' => [
        'url' => "https://demo.api4ai.cloud/img-bg-removal/v1/cars/results?mode={$RESULT_MODE}",
        'headers' => ['A4A-CLIENT-APP-ID: sample']
    ],
    'rapidapi' => [
        'url' => "https://cars-image-background-removal.p.rapidapi.com/v1/results?mode={$RESULT_MODE}",
        'headers' => ["X-RapidAPI-Key: {$RAPIDAPI_KEY}"]
    ]
];

// Initialize request session.
$request = curl_init();

// Check if path to local image provided.
$data = ['url' => 'https://storage.googleapis.com/api4ai-static/samples/img-bg-removal-cars-1.jpg'];
if (array_key_exists(1, $argv)) {
    if (strpos($argv[1], '://')) {
        $data = ['url' => $argv[1]];
    } else {
        $filename = pathinfo($argv[1])['filename'];
        $data = ['image' => new CURLFile($argv[1], null, $filename)];
    }
}

// Set request options.
curl_setopt($request, CURLOPT_URL, $OPTIONS[$MODE]['url']);
curl_setopt($request, CURLOPT_HTTPHEADER, $OPTIONS[$MODE]['headers']);
curl_setopt($request, CURLOPT_POST, true);
curl_setopt($request, CURLOPT_POSTFIELDS, $data);
curl_setopt($request, CURLOPT_RETURNTRANSFER, true);

// Execute request.
$result = curl_exec($request);

// Decode response.
$raw_response = json_decode($result, true);

// Get image data from response.
$img_base_64_str = $raw_response['results'][0]['entities'][0]['image'];

// Write image data to the file.
file_put_contents('result.png', base64_decode($img_base_64_str));

echo "\n", '💬 The "result.png" image is saved to the current directory.', "\n";
?>
