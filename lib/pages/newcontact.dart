import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../model/newcontactmodel.dart';

class Newcontact extends StatefulWidget {
  const Newcontact({super.key});

  @override
  State<Newcontact> createState() => _NewcontactState();
}

class _NewcontactState extends State<Newcontact> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String imagePath = '';

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  // Function to save contact
  void saveContact() async {
    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
      Newcontactmodel newContact = Newcontactmodel(
        name: nameController.text,
        phone: phoneController.text,
        image: imagePath,
        // type: 'com.example.contactapp'
      );
      await newContact.addContact();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Contact'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2, // Border width
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrangeAccent,
                      Colors.orange,
                      Colors.yellow,
                      Colors.red,
                      Colors.blue,
                      Colors.lightGreen
                    ], // Multiple gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imagePath.isNotEmpty
                      ? FileImage(File(imagePath))
                      : AssetImage('assets/default_image.png') as ImageProvider,
                ),
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Enter Name'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(labelText: 'Enter Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveContact,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white),
              child: Text('Save Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
