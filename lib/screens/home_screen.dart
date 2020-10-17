import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:app1/utilities/constants.dart';
import 'package:app1/resources/home_card.dart';
import 'package:app1/utilities/prefs.dart';
import 'package:app1/utilities/OfficeLocation.dart';
import 'package:app1/utilities/loading_dialog.dart';
import 'package:app1/resources/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var officeLat;
  var officeLong;

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  getOfficeCoordinates() async {
    int fid = await getOfficeID();
    String path = '/office_location/$fid';
    var response = await http.get(kUrl + path);
    var json = jsonDecode(response.body);
    OfficeLocation officeLocation = OfficeLocation(
        address: json['address'],
        latitude: json['lat'],
        longitude: json['long']);

    return officeLocation;
  }

  getCurrentLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  checkVicinity(BuildContext context) async {
    var position = await getCurrentLocation();
    OfficeLocation officeLocation = await getOfficeCoordinates();
    officeLat = officeLocation.latitude;
    officeLong = officeLocation.longitude;

    bool flag = false;
    if (position.latitude >= officeLat && position.latitude <= officeLat + 1) {
      if (position.longitude >= officeLong &&
          position.longitude <= officeLong + 1) {
        flag = true;
      }
      flag = false;
    }

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

    if (!flag) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("You are in Vicinity!"),
            content: Text(
              "Proceed to Authentication to mark attendance",
            ),
            actions: <Widget>[
              MaterialButton(
                  elevation: 5.0,
                  child: Text(
                    "Authentication",
                    style: TextStyle(color: kOrangeColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed('/attendance');
                  })
            ],
            elevation: 24.0,
            // backgroundColor: kOrangeColor,
          );
        },
        barrierDismissible: false,
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "You are not in Vicinity!",
            ),
            content: Text(
              "Move closer to office location and try again",
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text(
                  "Exit",
                  style: TextStyle(color: Colors.red[900]),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            elevation: 24.0,
            // backgroundColor: kOrangeColor,
          );
        },
        barrierDismissible: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kOrangeColor,
      ),
      // drawer: MyDrawer(),
      body: Container(
        width: width,
        height: height,
        color: kBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/qr_scanner');
                  },
                  child: HomeCard(
                    title: 'Scan QR Code',
                    imageName: 'qr3.jpg',
                    // navigate: '/scan_qr',
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    checkVicinity(context);

                    // getOfficeCoordinates();
                  },
                  child: HomeCard(
                    title: 'Mark Attendance',
                    imageName: 'ccalander.jpg',
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/maps_menu');
                  },
                  child: HomeCard(
                    title: 'Locations',
                    imageName: 'map.jpg',
                    // navigate: '/maps_menu',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}