import 'dart:convert';
import 'dart:typed_data';

import 'package:contactapp/pages/insertnewpartner.dart';
import 'package:contactapp/pages/loginpage.dart';
import 'package:contactapp/provider/loginprovider.dart';
import 'package:contactapp/provider/partnerprovider.dart';
import 'package:contactapp/utils/shareprefrence.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartnerContactList extends StatefulWidget {
  const PartnerContactList({super.key});

  @override
  State<PartnerContactList> createState() => _PartnerContactListState();
}

class _PartnerContactListState extends State<PartnerContactList> {
  getImageAvatar(image) {
    if (image != null && image != false) {
      Uint8List imageBytes = base64.decode(image);
      ImageProvider imageProvider = MemoryImage(imageBytes);
      return CircleAvatar(
        backgroundImage: imageProvider,
      );
    } else {
      return CircleAvatar(
        child: Icon(Icons.person),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PartnerProvider>(context, listen: false).fetchPartners());
  }

  @override
  Widget build(BuildContext context) {
    final partnerProvider = Provider.of<PartnerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact List"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
                onTap: () async {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => InsertNewPartner()));
                  bool? isAdded = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InsertNewPartner()),
                  );

                  if (isAdded == true) {
                    Provider.of<PartnerProvider>(context, listen: false)
                        .fetchPartners();
                  }
                },
                child: Icon(Icons.add)),
          ),
          IconButton(
              onPressed: () async {
                await SharePreferenceHelper.removeToken();
                if (!mounted) return;
                Provider.of<LoginProvider>(context, listen: false).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.logout_outlined)),
        ],
      ),
      body: partnerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : partnerProvider.errorMessage != null
              ? Center(child: Text(partnerProvider.errorMessage!))
              : ListView.builder(
                  itemCount: partnerProvider.contact.length,
                  itemBuilder: (context, index) {
                    final partner = partnerProvider.contact[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: getImageAvatar(partner.image),
                        title: Text(partner.name),
                        subtitle: Text(partner.phone),
                        trailing: Text(partner.email),
                      ),
                    );
                  },
                ),
    );
  }
}
