import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  final List<Contact> allContacts;

  const SearchPage(this.allContacts, {super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Contact> filteredContacts = []; // Initially, the list is empty
  TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(FocusNode());
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  // void _filterContacts() {
  //   setState(() {
  //     // If the search text is empty, clear the filteredContacts list
  //     if (searchController.text.isEmpty) {
  //       filteredContacts = [];
  //     } else {
  //       // Filter contacts as per the search query
  //       filteredContacts = widget.allContacts
  //           .where((contact) => contact.displayName
  //               .toLowerCase()
  //               .contains(searchController.text.toLowerCase()) || contact.phones.any((phone) => phone.value.conta))
  //           .toList();
  //     }
  //   });
  // }

  void _filterContacts() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredContacts = [];
      } else {
        filteredContacts = widget.allContacts.where((contact) {
          // Search by name or phone number
          return contact.displayName
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              contact.phones
                  .any((phone) => phone.number.contains(searchController.text));
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: Text(
          "Search Contacts",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              focusNode: _focusNode,
              controller: searchController,
              onChanged: (query) {
                // Call _filterContacts when text changes
                _filterContacts();
              },
              decoration: InputDecoration(
                hintText: "Search Contacts...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          _filterContacts(); // List update karne ke liye
                          setState(() {}); // UI update karne ke liye
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty && searchController.text.isNotEmpty
                ? Center(child: Text("No contacts found."))
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = filteredContacts[index];
                      String phoneNumber = contact.phones.isNotEmpty
                          ? contact.phones.first.number
                          : "No Number Of This Contact..!";
                      return Card(
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: contact.photo != null
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(contact.photo!))
                              : const Icon(Icons.person,
                                  size: 30, color: Colors.blueAccent),
                          title: Text(
                            contact.displayName,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            phoneNumber,
                            style: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(
                            Icons.call,
                            size: 30,
                            color: Colors.lightGreen,
                          ),
                          onTap: () async {
                            if (contact.phones.isNotEmpty) {
                              final Uri callUri = Uri.parse(
                                  'tel:${contact.phones.first.number}');
                              if (await canLaunchUrl(callUri)) {
                                await launchUrl(callUri);
                              } else {
                                print("Could not launch call");
                              }
                            } else {
                              print("No phone number available");
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
