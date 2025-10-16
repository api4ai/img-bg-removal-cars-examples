#!/usr/bin/env node

// Example of using API4AI car image background removal.
const fs = require('fs')
const path = require('path')
const axios = require('axios').default
const FormData = require('form-data')

// Use 'demo' mode just to try api4ai for free. ⚠️ Free demo is rate limited and must not be used in real projects.
//
// Use 'normal' mode if you have an API Key from the API4AI Developer Portal. This is the method that users should normally prefer.
//
// Use 'rapidapi' if you want to try api4ai via RapidAPI marketplace.
// For more details visit:
//   https://rapidapi.com/api4ai-api4ai-default/api/cars-image-background-removal/details
const MODE = 'demo'

// Your API4AI key. Fill this variable with the proper value if you have one.
const API4AI_KEY = ''

// Your RapidAPI key. Fill this variable with the proper value if you want
// to try api4ai via RapidAPI marketplace.
const RAPIDAPI_KEY = ''

// Processing mode influences returned result. Supported values are:
// * fg-image-shadow - Foreground image with shadow added.
// * fg-image - Foreground image.
// * fg-mask - Mask image.
const RESULT_MODE = 'fg-image-shadow'

const OPTIONS = {
  demo: {
    url: `https://demo.api4ai.cloud/img-bg-removal/v1/cars/results?mode=${RESULT_MODE}`,
    headers: {}
  },
  normal: {
    url: `https://api4ai.cloud/img-bg-removal/v1/cars/results?mode=${RESULT_MODE}`,
    headers: { 'X-API-KEY': API4AI_KEY }
  },
  rapidapi: {
    url: `https://cars-image-background-removal.p.rapidapi.com/v1/results?mode=${RESULT_MODE}`,
    headers: { 'X-RapidAPI-Key': RAPIDAPI_KEY }
  }
}

// Parse args: path or URL to image.
const image = process.argv[2] || 'https://static.api4.ai/samples/img-bg-removal-cars-1.jpg'

// Preapare request: form.
const form = new FormData()
if (image.includes('://')) {
  // Data from image URL.
  form.append('url', image)
} else {
  // Data from local image file.
  const fileName = path.basename(image)
  form.append('image', fs.readFileSync(image), fileName)
}

// Preapare request: headers.
const headers = {
  ...OPTIONS[MODE].headers,
  ...form.getHeaders(),
  'Content-Length': form.getLengthSync()
}

// Make request.
axios.post(OPTIONS[MODE].url, form, { headers })
  .then(function (response) {
    const imgBase64 = Buffer
      .from(response.data.results[0].entities[0].image, 'base64')

    fs.writeFile('result.png', imgBase64, () => {
      console.log('💬 The "result.png" image is saved to the current directory.')
    })
  })
