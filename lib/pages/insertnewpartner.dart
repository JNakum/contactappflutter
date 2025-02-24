import 'dart:developer';
import 'dart:io';

import 'package:contactapp/provider/partnerprovider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class InsertNewPartner extends StatefulWidget {
  const InsertNewPartner({super.key});

  @override
  State<InsertNewPartner> createState() => _InsertNewPartnerState();
}

class _InsertNewPartnerState extends State<InsertNewPartner> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  void _savePartner() async {
    if (_formKey.currentState!.validate()) {
      log("Name: ${_nameController.text}");
      log("Phone: ${_phoneController.text}");
      log("Email: ${_emailController.text}");
      log("Image: ${_imageController.text}");

      final partnerProvider =
          Provider.of<PartnerProvider>(context, listen: false);

      await partnerProvider.addNewContactPartner(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          image: _imageController.text);

      if (!mounted) {
        return;
      }
      // await partnerProvider.fetchPartners();
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Partner.."),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please Enter Name" : null,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _phoneController,
                maxLength: 10,
                decoration: InputDecoration(labelText: "Phone"),
                validator: (value) =>
                    value!.isEmpty ? "Please Enter Phone" : null,
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.isEmpty ? "Please Enter Email" : null,
              ),
              SizedBox(
                height: 5,
              ),
              // Image Upload Field
              _image != null
                  ? Image.file(_image!,
                      height: 100, width: 100, fit: BoxFit.cover)
                  : const Text("No Image Selected"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Pick Image"),
              ),
              SizedBox(
                height: 5,
              ),
              ElevatedButton(
                  onPressed: () {
                    _savePartner();
                  },
                  child: Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
