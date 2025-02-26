import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:image/image.dart' as img;
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
  bool _isSave = false;

  void _savePartner() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSave = true;
      });
      final partnerProvider =
          Provider.of<PartnerProvider>(context, listen: false);
      final partner = partnerProvider.selectedPartner;

      if (partner == null) {
        await partnerProvider.addNewContactPartner(
            name: _nameController.text,
            phone: _phoneController.text,
            email: _emailController.text,
            image: _imageController.text);
      } else {
        await partnerProvider.updateContactPartner(
            partner.id,
            _nameController.text,
            _phoneController.text,
            _emailController.text,
            _imageController.text);
      }

      setState(() {
        _isSave = false;
      });

      if (!mounted) {
        return;
      }
      await partnerProvider.fetchPartners();
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();

      // Decode image
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 300);

        final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
        log("compressed imge bytes => $compressedBytes");

        setState(() {
          _image = imageFile;
          _imageController.text = base64Encode(compressedBytes);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final partnerProvider =
        Provider.of<PartnerProvider>(context, listen: false);
    final partner = partnerProvider.selectedPartner;
    if (partner != null) {
      _nameController.text = partner.name;
      _phoneController.text = partner.phone;
      _emailController.text = partner.email;
      _imageController.text = partner.image ?? "";
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
              _isSave
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        _savePartner();
                      },
                      child: Text(Provider.of<PartnerProvider>(context)
                                  .selectedPartner ==
                              null
                          ? "Save"
                          : "Update")),
            ],
          ),
        ),
      ),
    );
  }
}
