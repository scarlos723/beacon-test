import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:beacon_test/pages/nfc_page.dart';
import 'dart:convert';

class BeaconsPage extends StatefulWidget {
  const BeaconsPage({Key? key, required this.product}) : super(key: key);
  final String product;

  @override
  _BeaconsPageState createState() => _BeaconsPageState();
}

class _BeaconsPageState extends State<BeaconsPage> {
  Map<String, bool> way = {
    '8961F890-B318-4D51-8130-034444B73E10': false,
    'FDA50693-A4E2-4FB1-AFCF-C6EB07647825': false,
    'FDA50693-A4E2-4FB1-AFCF-C6EB07646666': false
  };
  var points = [
    {
      'uid': '8961F890-B318-4D51-8130-034444B73E10',
      'message':
          'Puedes empezar a caminar, sigue de frente hasta ecuchar la próxima indicación',
      'minrssi': -60
    },
    {
      'uid': 'FDA50693-A4E2-4FB1-AFCF-C6EB07647825',
      'message':
          'gire a la derecha por favor y camine 20 pasos aproximadamente',
      'minrssi': -60
    },
    {
      'uid': 'FDA50693-A4E2-4FB1-AFCF-C6EB07646666',
      'message':
          'gire a la izquierda por favor y camine 10 pasos aproximadamente',
      'minrssi': -60
    }
  ];
  var infoBeacons = [];
  String product2 = ''; //value asigned in initState function

  // StreamSubscription<RangingResult>? _streamRanging;
  // StreamSubscription<BluetoothState>? _streamBluetooth;
  // final _regionBeacons = <Region, List<Beacon>>{};
  // final _beacons = <Beacon>[];

  //State TTS
  FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the SpeechPage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Beacons'),
        ),
        body: Column(
          children: <Widget>[
            Text("producto $product2"),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: infoBeacons.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Center(child: Text('Entry ${infoBeacons[index]}')),
                  );
                })
          ],
          //children: Text("producto $product2")
        ));

    // Center is a layout widget. It takes a single child and positions it
    // in the middle of the parent.
  }

  Future _speakMessage(description) async {
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('es-ES');
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(description);
  }

  void _compareLists(beacons) {
    try {
      for (var item in points) {
        if (item['uid'] == beacons[0].proximityUUID &&
            beacons[0].rssi >= item['minrssi']) {
          print(way[item['uid']]);
          if (way[item['uid']] == false) {
            _speakMessage(item['message']);
            setState(() {
              way[item['uid'].toString()] = true;
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _beaconRead() {
    //Region de beacons con los que trabajaremos
    final regions = <Region>[
      Region(
          identifier: 'iBeacon', //Start Beacon
          proximityUUID: '8961F890-B318-4D51-8130-034444B73E10'),
      Region(
        identifier: 'iBeacon1',
        proximityUUID: 'FDA50693-A4E2-4FB1-AFCF-C6EB07647825',
      ),
      Region(
        identifier: 'iBeacon2',
        proximityUUID: 'FDA50693-A4E2-4FB1-AFCF-C6EB07646666',
      ),
    ];
    void _initBeacon() async {
      try {
        // if you want to manage manual checking about the required permissions
        await flutterBeacon.initializeScanning;
        // or if you want to include automatic checking permission
        //await flutterBeacon.initializeAndCheckScanning;
      } on FormatException catch (e) {
        // library failed to initialize, check code and message
        print(e);
      }
    }

    void _requestBeacon() async {
      await flutterBeacon
          .requestAuthorization; // Es necesario pedir permisos al usuario para poder usar los servicios!!
    }

    _requestBeacon();
    _initBeacon();

    //Escaneo de beacons
    flutterBeacon.ranging(regions).listen((RangingResult result) {
      print(result.beacons);
      setState(() {
        infoBeacons = result.beacons;
      });
      _compareLists(result.beacons);
      if (way['FDA50693-A4E2-4FB1-AFCF-C6EB07646666'] == true) {
        _showNfcPage(context);
        return;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      product2 = widget.product;
    });
    _beaconRead();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showNfcPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => const NfcPage()));
    // Navigator.pushNamed(context, 'beacons', arguments: _lastWords );
  }
}
