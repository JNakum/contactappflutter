import 'dart:convert';
import 'dart:typed_data';

import 'package:contactapp/pages/insertnewpartner.dart';
import 'package:contactapp/pages/loginpage.dart';
import 'package:contactapp/provider/loginprovider.dart';
import 'package:contactapp/provider/partnerprovider.dart';
import 'package:contactapp/utils/callhelper.dart';
import 'package:contactapp/utils/shareprefrence.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartnerContactList extends StatefulWidget {
  const PartnerContactList({super.key});

  @override
  State<PartnerContactList> createState() => _PartnerContactListState();
}

class _PartnerContactListState extends State<PartnerContactList> {
  int? selectedIndex;
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

  directCall(String phoneNumber) {
    CallHelper.makeDirectCall(phoneNumber);
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
                  final provider =
                      Provider.of<PartnerProvider>(context, listen: false);
                  provider.setSelectedPartner(null);
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
                    final isExpanded = selectedIndex == index;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: getImageAvatar(partner.image),
                            onTap: () {
                              setState(() {
                                selectedIndex =
                                    selectedIndex == index ? null : index;
                              });
                            },
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  partner.phone,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  partner.email,
                                  style: TextStyle(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),

                          // ListTile(
                          //   leading: getImageAvatar(partner.image),
                          //   title: Text(partner.name),
                          //   subtitle: Text(partner.phone),
                          //   trailing: Text(partner.email),
                          //   onTap: () {
                          //     setState(() {
                          //       selectedIndex =
                          //           selectedIndex == index ? null : index;
                          //     });
                          //   },
                          // ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        final provider =
                                            Provider.of<PartnerProvider>(
                                                context,
                                                listen: false);
                                        try {
                                          await provider
                                              .deleteContactPartner(partner.id);
                                          setState(
                                              () {}); // UI update for deleted item
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Failed to delete contact: $e")),
                                            );
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      )),
                                  IconButton(
                                      onPressed: () async {
                                        final provider =
                                            Provider.of<PartnerProvider>(
                                                context,
                                                listen: false);
                                        provider.setSelectedPartner(partner);
                                        bool? isUpdated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InsertNewPartner()));
                                        if (isUpdated == true) {
                                          provider.fetchPartners();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      )),
                                  IconButton(
                                      onPressed: () async {
                                        directCall(partner.phone);
                                      },
                                      icon: Icon(
                                        Icons.call,
                                        color: Colors.green,
                                      ))
                                ],
                              ),
                            )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
