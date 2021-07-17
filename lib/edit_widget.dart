import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'second_screen.dart';
import 'main.dart';
import 'contacts_db.dart';

updateContact(String lName, String fName, List<dynamic> pNumbers,
    String id) async {
  await http.put(Uri.parse('$host/contacts/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<dynamic, dynamic>{
        'last_name': lName,
        'first_name': fName,
        'phone_numbers': pNumbers
      }));
}

updateSecureContact(String lName, String fName, List<dynamic> pNumbers, String id) async {
  final res1 = await http.post(Uri.parse('$host/login'), headers: <String, String> {
    'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(<dynamic, dynamic> {
    'email': "guest",
    'password': "guest"
  }));
  final String token = jsonDecode(res1.body)['token'];

  await http.put(Uri.parse('$host/user/contacts/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: jsonEncode(<dynamic, dynamic>{
        'last_name': lName,
        'first_name': fName,
        'phone_numbers': pNumbers
      }));
}


class EditContactWidget extends StatefulWidget {
  final bool visibility;
  final FutureBuilder<Contacts> toBeEdit;

  const EditContactWidget(
      {Key? key, required this.visibility, required this.toBeEdit,})
      : super(key: key);

  @override
  _EditContactWidgetState createState() => _EditContactWidgetState();

  static _EditContactWidgetState? of(BuildContext context) => context.findAncestorStateOfType<_EditContactWidgetState>();
}

class _EditContactWidgetState extends State<EditContactWidget> {

  @override
  Widget build(BuildContext context) {
    bool visibility = widget.visibility;
    return Visibility(
      visible: visibility,
      child: Stack(children: [
        InkWell(
          onTap: () {
            setState(() {
              SecondScreen.of(context)!.editVisibilityOfWidget = false;
            });
          },
          child: Container(
            color: Colors.black.withOpacity(0.75),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.only(top: 75, left: 10, right: 10, bottom: 75),
          child: Center(
            child: FittedBox(
              fit: BoxFit.none,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350,),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.account_circle_rounded,
                            size: 50,
                          ),
                        ),
                        widget.toBeEdit,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}