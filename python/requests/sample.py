#!/usr/bin/env python3

"""Example of using API4AI car image background removal."""

import base64
import os
import sys

import requests


# Use 'demo' mode just to try api4ai for free. ⚠️ Free demo is rate limited and must not be used in real projects.
#
# Use 'normal' mode if you have an API Key from the API4AI Developer Portal. This is the method that users should normally prefer.
#
# Use 'rapidapi' if you want to try api4ai via RapidAPI marketplace.
# For more details visit:
#   https://rapidapi.com/api4ai-api4ai-default/api/cars-image-background-removal/details
MODE = 'demo'

# Your API4AI key. Fill this variable with the proper value if you have one.
API4AI_KEY = ''

# Your RapidAPI key. Fill this variable with the proper value if you want
# to try api4ai via RapidAPI marketplace.
RAPIDAPI_KEY = ''

# Processing mode influences returned result. Supported values are:
# * fg-image-shadow - Foreground image with shadow added.
# * fg-image - Foreground image.
# * fg-mask - Mask image.
RESULT_MODE = 'fg-image-shadow'

OPTIONS = {
    'demo': {
        'url': f'https://demo.api4ai.cloud/img-bg-removal/v1/cars/results?mode={RESULT_MODE}'
    },
    'normal': {
        'url': f'https://api4ai.cloud/img-bg-removal/v1/cars/results?mode={RESULT_MODE}',
        'headers': {'X-API-KEY': API4AI_KEY}
    },
    'rapidapi': {
        'url': f'https://cars-image-background-removal.p.rapidapi.com/v1/results?mode={RESULT_MODE}',  # noqa
        'headers': {'X-RapidAPI-Key': RAPIDAPI_KEY}
    }
}


if __name__ == '__main__':
    # Parse args.
    image = sys.argv[1] if len(sys.argv) > 1 else 'https://static.api4.ai/samples/img-bg-removal-cars-1.jpg'

    if '://' in image:
        # POST image via URL.
        response = requests.post(
            OPTIONS[MODE]['url'],
            headers=OPTIONS[MODE].get('headers'),
            data={'url': image})
    else:
        # POST image as file.
        with open(image, 'rb') as image_file:
            response = requests.post(
                OPTIONS[MODE]['url'],
                headers=OPTIONS[MODE].get('headers'),
                files={'image': (os.path.basename(image), image_file)}
            )

    img_b64 = response.json()['results'][0]['entities'][0]['image'].encode('utf8')

    path_to_image = os.path.join('result.png')
    with open(path_to_image, 'wb') as img:
        img.write(base64.decodebytes(img_b64))

    print('💬 The "result.png" image is saved to the current directory.')
