import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'second_screen.dart';

//const String host = 'http://192.168.254.104:5000';
//const String host = 'https://test-heroku-3154.herokuapp.com';
//const String host = 'https://phonebook-app-09120912.herokuapp.com';
const String host = 'https://phonebook-abellar-api.herokuapp.com';

void main() => runApp(const PbApp());

class ContactLocal {
  final String lastName;
  final String firstName;
  final List<String> phoneNumbers;

  ContactLocal(this.lastName, this.firstName, this.phoneNumbers);
}

class PbApp extends StatelessWidget {
  const PbApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.light,
      title: 'Phonebook App',
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add Contacts'),
      ),
      body: const InputContactForm(),
    );
  }
}

class InputContactForm extends StatefulWidget {
  const InputContactForm({Key? key}) : super(key: key);

  @override
  _InputContactFormState createState() => _InputContactFormState();
}

class _InputContactFormState extends State<InputContactForm> {
  List<ContactLocal> namesTodo = <ContactLocal>[];

  int nPhoneNumber = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //pokeApi();
    loginPhonebook();
  }

  void saveContact() {
    if (_formKey.currentState!.validate()) {
      List<String> pnums = <String>[];
      for (int i = 0; i < nPhoneNumber; i++) {
        pnums.add(pnumCtrlrs[i].text);
      }
      namesTodo.insert(0, ContactLocal(lnameCtrlr.text, fnameCtrlr.text, pnums));
      createSecureContacts(lnameCtrlr.text, fnameCtrlr.text, pnums);

      const snackBar = SnackBar(
        content: Text('Successfully Submitted Contacts'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void gotoNextScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SecondScreen(todo: namesTodo)));
  }

  void addPhoneNumber() {
    setState(() {
      nPhoneNumber++;
      pnumCtrlrs.insert(0, TextEditingController());
    });
  }

  void subPhoneNumber() {
    setState(() {
      if (nPhoneNumber != 0) {
        nPhoneNumber--;
        pnumCtrlrs.removeAt(0);
      }
    });
  }

  final lnameCtrlr = TextEditingController();
  final fnameCtrlr = TextEditingController();
  List<TextEditingController> pnumCtrlrs = <TextEditingController>[
    TextEditingController()
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.account_circle_rounded,
                    size: 100.0,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if ((val == null || val.isEmpty) && lnameCtrlr.text.isEmpty) return 'At least one of the name is required';
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'First Name'),
                        controller: fnameCtrlr,
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if ((val == null || val.isEmpty) && fnameCtrlr.text.isEmpty) return 'At least one of the name is required';
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Last Name'),
                        controller: lnameCtrlr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: 0.0,
                    maxHeight: MediaQuery.of(context).size.height - 350),
                child: ListView.builder(
                  controller: ScrollController(initialScrollOffset: 0),
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: TextFormField(
                        decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: 'Phone Number #${i + 1}'),
                        controller: pnumCtrlrs[i],
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          MaskedInputFormatter('###-#####', anyCharMatcher: RegExp('[0-9]')),
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Phone number is required';
                          if (val.length != 9) return 'Incomplete phone number';
                          return null;
                        },
                      ),
                    );
                  },
                  itemCount: nPhoneNumber,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: addPhoneNumber,
                  child: const Icon(Icons.add),
                  style: OutlinedButton.styleFrom(shape: const CircleBorder()),
                ),
                OutlinedButton(
                  onPressed: subPhoneNumber,
                  child: const Icon(Icons.remove),
                  style: OutlinedButton.styleFrom(shape: const CircleBorder()),
                ),
              ],
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: ElevatedButton(
                          onPressed: saveContact,
                          child: const Text('Submit'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: ElevatedButton(
                          onPressed: gotoNextScreen,
                          style: ElevatedButton.styleFrom(primary: Colors.grey),
                          child: const Text('View'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

createContacts(
    String lastName, String firstName, List<dynamic> phoneNumbers) async {
  await http.post(Uri.parse('$host/contacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'last_name': lastName,
        'first_name': firstName,
        'phone_numbers': phoneNumbers
      }));
}

createSecureContacts(String lastName, String firstName, List<dynamic> phoneNumbers) async {
  final res1 = await http.post(Uri.parse('$host/users/login'), headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(<dynamic, dynamic> {
    'email': "guest",
    'password': "guest"
  }));
  final String token = jsonDecode(res1.body)['token'];

  await http.post(Uri.parse('$host/users/contacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: jsonEncode(<dynamic, dynamic>{
        'last_name': lastName,
        'first_name': firstName,
        'phone_numbers': phoneNumbers
      }));
}

Future<Contacts> fetchContacts(int index) async {
  final res = await http.get(Uri.parse('$host/contacts'));

  if (res.statusCode == 200) {
    return Contacts.fromJson(jsonDecode(res.body)[index]);
  } else {
    throw Exception('Failed to load contacts');
  }
}

Future<Contacts> fetchSecureContacts(int index) async {
  final res1 = await http.post(Uri.parse('$host/users/login'), headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(<dynamic, dynamic> {
      'email': "guest",
      'password': "guest"
    }));
  final String token = jsonDecode(res1.body)['token'];


  final res = await http.get(Uri.parse('$host/users/contacts'),
  headers: { HttpHeaders.authorizationHeader: 'Bearer $token' });

  if (res.statusCode == 200) {
    return Contacts.fromJson(jsonDecode(res.body)['contacts'][index]);
  } else {
    throw Exception('Failed to load contacts');
  }
}


Future<Contacts> getContactById(String id) async {
  final res = await http.get(Uri.parse('$host/contacts/$id'));

  if (res.statusCode == 200) {
    return Contacts.fromJson(jsonDecode(res.body));
  } else {
    throw Exception('Failed to get contact');
  }
}

Future<Contacts> getSecureContactById(String id) async {
  final res1 = await http.post(Uri.parse('$host/users/login'), headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(<dynamic, dynamic> {
    'email': "guest",
    'password': "guest"
  }));
  final String token = jsonDecode(res1.body)['token'];


  final res = await http.get(Uri.parse('$host/users/contacts/$id'), headers: { HttpHeaders.authorizationHeader: 'Bearer $token' });

  if (res.statusCode == 200) {
    return Contacts.fromJson(jsonDecode(res.body)['contact']);
  } else {
    throw Exception('Failed to get contact');
  }
}

deleteContact(String id) async {
  await http.delete(Uri.parse('$host/contacts/$id'));
}

deleteSecureContact(String id) async {
  final res1 = await http.post(Uri.parse('$host/users/login'), headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(<dynamic, dynamic> {
    'email': "guest",
    'password': "guest"
  }));
  final String token = jsonDecode(res1.body)['token'];

  await http.delete(Uri.parse('$host/users/contacts/$id'), headers: { HttpHeaders.authorizationHeader: 'Bearer $token' });
}

// pokeApi() async {
//   final res = await http.get(Uri.parse('$host/user/profile'),
//       headers: {
//         HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7Il9pZCI6IjYwZjAyM2ZjMTg2ZjdjMjI4MGMzYTdkMiIsImVtYWlsIjoiZXhhbXBsZUBleGFtcGxlLmNvbSJ9LCJpYXQiOjE2MjYzNTc1MjN9.S3dewCxm4jgyzksKQiv1z8tthzLxTB-n3IGp4L7f24I',
//       });
//
//   final resJson = jsonDecode(res.body);
//   print(resJson);
// }

loginPhonebook() async {
  final res = await http.post(Uri.parse('$host/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'email': "guest",
        'password': "guest"
      }));
  //token = jsonDecode(res.body);
}

class Contacts {
  final dynamic id;
  final String lastName;
  final String firstName;
  final List<dynamic> phoneNumbers;

  Contacts({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.phoneNumbers,
  });

  factory Contacts.fromJson(Map<String, dynamic> json) {
    return Contacts(
      id: json['_id'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      phoneNumbers: json['phone_numbers'],
    );
  }
}
