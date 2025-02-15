import 'package:contactapp/pages/newcontact.dart';
import 'package:contactapp/pages/searchpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class Contactlist extends StatefulWidget {
  const Contactlist({super.key});

  @override
  State<Contactlist> createState() => _ContactlistState();
}

class _ContactlistState extends State<Contactlist> {
  List<Contact> usersdetail = [];
  bool isLoading = true;

  void _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch call");
    }
  }

  Future<void> getYourContact() async {
    if (!await FlutterContacts.requestPermission()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<Contact> phoneContact = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
      withAccounts: true,
    );

    setState(() {
      usersdetail = phoneContact;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getYourContact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: Text("Contact", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: getYourContact,
              icon: Icon(Icons.sync, color: Colors.white),
            ),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                searchcontact(context),
                Expanded(child: contactLit()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Newcontact()),
          );
          getYourContact();
        },
        backgroundColor: Colors.deepOrangeAccent,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget contactLit() {
    if (usersdetail.isEmpty) {
      return Center(
        child: Text(
          "No Contact Found...!",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red),
        ),
      );
    }

    return ListView.builder(
      itemCount: usersdetail.length,
      itemBuilder: (context, index) {
        Contact contact = usersdetail[index];

        return GestureDetector(
          onTap: () {},
          child: Card(
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: contact.photo != null
                  ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                  : Icon(Icons.person, size: 30, color: Colors.blueAccent),
              title: Text(
                contact.displayName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: contactIdAndNumber(contact),
              trailing: call(contact),
            ),
          ),
        );
      },
    );
  }

  Widget searchcontact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        readOnly: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage(usersdetail)),
          );
        },
        decoration: InputDecoration(
          hintText: "Search Contacts....!",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget call(Contact contact) {
    return IconButton(
      onPressed: () async {
        if (contact.phones.isNotEmpty) {
          _makePhoneCall(contact.phones.first.number);
        } else {
          print("No phone number available");
        }
      },
      icon: Icon(
        Icons.call,
        size: 30,
        color: Colors.lightGreen,
      ),
    );
  }

  Widget contactIdAndNumber(Contact contact) {
    String phoneNumber = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : "No Number Of This Contact..!";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ID: ${contact.id}",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text(
          phoneNumber,
          style: TextStyle(
            color: Colors.deepOrangeAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
