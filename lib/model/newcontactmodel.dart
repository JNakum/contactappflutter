import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'vcard.dart';

class Newcontactmodel {
  String name;
  String phone;
  String image;
  // String type;

  Newcontactmodel({
    required this.name,
    required this.phone,
    required this.image,
    // required this.type
  });

  // Method to generate vCard
  String generateVCard() {
    return createVCard(name, phone, image);
  }

  // fromVCard method to parse vCard and create Newcontactmodel object
  static Newcontactmodel fromVCard(String vCardData) {
    final nameRegEx = RegExp(r'FN:(.*)');
    final phoneRegEx = RegExp(r'TEL:(.*)');
    final imageRegEx = RegExp(r'PHOTO;ENCODING=BASE64:(.*)');

    final name = nameRegEx.firstMatch(vCardData)?.group(1) ?? '';
    final phone = phoneRegEx.firstMatch(vCardData)?.group(1) ?? '';
    final image = imageRegEx.firstMatch(vCardData)?.group(1) ?? '';

    return Newcontactmodel(
      name: name, phone: phone, image: image,
      //  type: 'com.example.contactapp'
    );
  }

  Future<Uint8List?> _getImageFile(String imagePath) async {
    if (imagePath.isEmpty) return null;
    final File imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    return Uint8List.fromList(imageBytes);
  }

  Future<void> addContact() async {
    String vCardData = generateVCard();
    log("VCardData =>  $vCardData");
    if (await FlutterContacts.requestPermission()) {
      Contact newContact = Contact()
        ..name.first = name
        ..accounts = [
          Account('1', 'com.example.contactapp', 'EKIKA APP',
              ['application/vnd.contact.cmsg'])
        ]
        ..phones = [Phone(phone)];

      if (image.isNotEmpty) {
        newContact.photo = await _getImageFile(image);
      }

      await FlutterContacts.insertContact(newContact);
    }
  }
}
