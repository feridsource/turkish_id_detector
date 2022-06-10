# TrDetector - Turkish Identity Card Detector Library for Flutter

TrDetector detects identity cards and fetches information from the image of the card.


## Usage

**Sample Code**
```dart
TrDetector trDetector = TrDetector();
trDetector.readAnyCard(imagePath); // Detect the type of the card and read content
trDetector.readLicense(imagePath); // Read driving license front face
trDetector.readMrz(imagePath); // Fetch information from MRZ of identity card
trDetector.readBarcode(imagePath); // Scan barcode or QR code of driving license
```

## Additional information

If you know the type of the card, you can specifically choose to readLicense, readMrz or readBarcode. If the type of the card is to be detected too, then use readAnyCard. It will not only detect the type but also read the content of the card.

# Licence

Copyright (C) 2022 Ferid Cafer

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.