String createVCard(String name, String phone, String image) {
  return '''
BEGIN:VCARD
VERSION:3.0
FN:$name
TEL:$phone
PHOTO;ENCODING=BASE64:$image
END:VCARD
''';
}
