import 'card_type.dart';
import 'citizenship.dart';
import 'gender.dart';

/// Turkish citizen
class TrCitizen {
  CardType cardType = CardType.unknown;
  Citizenship citizenship = Citizenship.otherCitizen;
  String? documentNo;
  String? identityNo;
  String? licenseNo;
  String? eligibleVehicle;
  String? birthDate;
  String? expiryDate;
  String? name;
  String? middleName;
  String? surname;
  Gender? gender;
}