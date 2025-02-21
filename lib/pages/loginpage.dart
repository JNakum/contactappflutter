import 'package:contactapp/pages/partnercontactlist.dart';
import 'package:contactapp/provider/loginprovider.dart';
import 'package:contactapp/utils/shareprefrence.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // ✅ Pehle se token hai to auto-login karega
  void _checkLoginStatus() async {
    String? token = await SharePreferenceHelper.getToken();
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PartnerContactList()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Login.."),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "UserName"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: false,
            ),
            SizedBox(
              height: 10,
            ),
            if (loginProvider.errorMessage != null)
              Text(
                loginProvider.errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(
              height: 20,
            ),
            loginProvider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      bool success = await loginProvider.login(
                          _usernameController.text.trim(),
                          _passwordController.text.trim());
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login Successfull!")));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PartnerContactList()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login Failed!")));
                      }
                    },
                    child: Text("Login"))
          ],
        ),
      ),
    );
  }
}
