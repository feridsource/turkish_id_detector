library turkish_id_detector;

import 'package:google_ml_kit/google_ml_kit.dart';

import 'card_type.dart';
import 'citizenship.dart';
import 'gender.dart';
import 'tr_citizen.dart';

/// Detector of ID cards of Republic of Turkey citizens
class TrDetector {

  /// Detect the type of the card and read content
  static Future<TrCitizen> readAnyCard(String path) async {
    List<String> lines = await _fetchLines(path);

    CardType cardType = CardType.unknown;
    for (var line in lines) {
      if (line.contains("<<")) {
        cardType = CardType.identityCard;
        break;
      } else if (line.contains("DRIVING")) {
        cardType = CardType.drivingLicense;
        break;
      }
    }

    TrCitizen trCitizen = TrCitizen();

    if (cardType == CardType.identityCard) {
      // this is MRZ
      trCitizen = await readMrz(path);
    } else if (cardType == CardType.drivingLicense) {
      // this is Driving License
      trCitizen = await readLicense(path);
    } else {
      // it should be barcode
      trCitizen = await readBarcode(path);
    }

    return trCitizen;
  }

  /// Detect lines of the card
  static Future<List<String>> _fetchLines(String path) async {
    var recognizer = TextRecognizer();

    InputImage image = InputImage.fromFilePath(path);

    RecognizedText recognisedText = await recognizer.processImage(image);

    List<String> recognizedList = [];

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        recognizedList.add(line.text);
      }
    }

    return recognizedList;
  }

  /// Read driving license front face
  static Future<TrCitizen> readLicense(String path) async {
    List<String> lines = await _fetchLines(path);

    TrCitizen trCitizen = TrCitizen();

    for (var line in lines) {
      if (line.contains("TÜRKİYE")) {
        trCitizen.citizenship = Citizenship.turkishCitizen;
      } else if (line.contains("DRIVING")) {
        trCitizen.cardType = CardType.drivingLicense;
      }

      try {
        if (line.startsWith("1.")) {
          trCitizen.surname = line.substring(2).trim();
        } else if (line.startsWith("2.")) {
          trCitizen.name = line.substring(2).trim();
        } else if (line.startsWith("3.")) {
          trCitizen.birthDate = line.substring(2).trim();
        } else if (line.startsWith("4b.")) {
          trCitizen.expiryDate = line.substring(3).trim();
        } else if (line.startsWith("4d")) {
          trCitizen.identityNo = line.substring(3).trim();
        } else if (line.startsWith("5.")) {
          trCitizen.licenseNo = line.substring(2).trim();
        } else if (line.startsWith("9.")) {
          trCitizen.eligibleVehicle = line.substring(2).trim();
          break;
        }
      } catch (ex) {
        trCitizen.citizenship = Citizenship.otherCitizen;
      }
    }

    return trCitizen;
  }

  /// Fetch information from MRZ of identity card
  static Future<TrCitizen> readMrz(String path) async {
    List<String> lines = await _fetchLines(path);

    TrCitizen trCitizen = TrCitizen();

    List<String> mrzLines = [];

    for (var line in lines) {
      if (!line.contains("<<")) continue;

      String cleanText = line
          .replaceAll("«", "")
          .replaceAll(" ", "")
          .trim();

      mrzLines.add(cleanText);
    }

    if (mrzLines.length == 3) {
      try {
        List<String> line1Items = mrzLines[0].split("<");
        for (var item in line1Items) {
          if (item == "") continue;

          if (item.startsWith("I")) {
            trCitizen.cardType = CardType.identityCard;
          } else if (item.startsWith("TUR")) {
            trCitizen.citizenship = Citizenship.turkishCitizen;
            String documentNo = item.substring(3);
            trCitizen.documentNo = documentNo;
          } else {
            String identityNo = item;
            trCitizen.identityNo = identityNo;
          }
        }

        List<String> line2Items = mrzLines[1].split("<");
        if (line2Items.isNotEmpty) {
          var item = line2Items[0];

          String bYear = item.substring(0, 2);
          String bMonth = item.substring(2, 4);
          String bDay = item.substring(4, 6);
          String birthDate = "$bDay.$bMonth.$bYear";
          trCitizen.birthDate = birthDate;

          String gender = item.substring(7, 8);
          if (gender == "M") {
            trCitizen.gender = Gender.male;
          } else {
            trCitizen.gender = Gender.female;
          }

          String eYear = item.substring(8, 10);
          String eMonth = item.substring(10, 12);
          String eDay = item.substring(12, 14);
          String expiryDate = "$eDay.$eMonth.$eYear";
          trCitizen.expiryDate = expiryDate;
        }

        List<String> line3Items = mrzLines[2].split("<");
        if (line3Items.length > 2) {
          String name = line3Items[0].trim();
          String middleName = line3Items[1].trim();
          String surname = line3Items[2].trim();

          trCitizen.name = name;
          trCitizen.middleName = middleName;
          trCitizen.surname = surname;
        } else {
          String name = line3Items[0].trim();
          String surname = line3Items[1].trim();

          trCitizen.name = name;
          trCitizen.surname = surname;
        }
      } catch (ex) {
        trCitizen.citizenship = Citizenship.otherCitizen;
      }
    }

    return trCitizen;
  }

  /// Scan barcode or QR code of driving license
  static Future<TrCitizen> readBarcode(String path) async {
    var barcodeScanner = BarcodeScanner();

    InputImage image = InputImage.fromFilePath(path);

    List<Barcode> barcodeList = await barcodeScanner.processImage(image);

    TrCitizen trCitizen = TrCitizen();
    String? line;

    if (barcodeList.isNotEmpty) {
      line = barcodeList[0].rawValue;
    }

    if (line != null && line.contains(" ")) {
      List<String> lines = line.split(" ");
      if (lines.length > 1) {
        trCitizen.identityNo = lines[0];
        trCitizen.licenseNo = lines[1];
        trCitizen.cardType = CardType.drivingLicense;
        trCitizen.citizenship = Citizenship.turkishCitizen;
      }
    }

    return trCitizen;
  }
}