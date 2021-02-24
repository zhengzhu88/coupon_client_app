import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<CouponList> futureCouponList;
  // List<Coupon> couponList;

  Future<CouponList> _fetchCoupons() async {
    final response = await http.get(Uri.http('192.168.4.114:1129', 'coupons'));

    if (response.statusCode == 200) {
      return CouponList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Could not get coupons. Check if server is up?');
    }
  }

  void _showCreateScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void> (
        builder: (BuildContext context) {

        }
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    futureCouponList = _fetchCoupons();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center (
        child: FutureBuilder<CouponList>(
          future: futureCouponList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Coupon> coupons = snapshot.data.asList();
              return ListView.builder(
                itemCount: coupons.length,
                itemBuilder: (BuildContext _context, int i) {
                  return ListTile(
                    title: Text(coupons[i].toJson().toString()),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateScreen,
        tooltip: 'Does nothing',
        child: Icon(Icons.add),
      ),
    );
  }
}

class CouponList {
  final Map<int, Coupon> couponsById;

  CouponList(this.couponsById);

  List<Coupon> asList() {
    List<Coupon> result = new List();
    couponsById.forEach((key, value) { result.add(value); });
    return result;
  }

  factory CouponList.fromJson(Map<String, dynamic> json) {
    Map<int, Coupon> coupons = new SplayTreeMap();
    json.forEach((key, value) {
      coupons[int.parse(key)] = Coupon.fromJson(value);
    });
    return CouponList(coupons);
  }

  // Doesn't work because Dart JSON encoder doesn't play nicely with non-String
  // keys or custom values. https://github.com/dart-lang/sdk/issues/32476
  String toJson() {
    return jsonEncode(couponsById);
  }
}

class Coupon {
  final int id;
  final String beneficiary;
  final String provider;
  final bool isActive;

  Coupon({this.id, this.beneficiary, this.provider, this.isActive});

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: int.parse(json['id']),
      beneficiary: json['beneficiary'],
      provider: json['provider'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beneficiary': beneficiary,
      'provider': provider,
      'is_active': isActive,
    };
  }
}
