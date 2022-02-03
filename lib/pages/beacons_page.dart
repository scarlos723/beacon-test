import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class BeaconsPage extends StatefulWidget {
  const BeaconsPage({Key? key, required this.product}) : super(key: key);
  final String product;

  @override
  _BeaconsPageState createState() => _BeaconsPageState();
}

class _BeaconsPageState extends State<BeaconsPage> {
  Map<String, bool> way = {
    'FDA50693-A4E2-4FB1-AFCF-C6EB07647825': false,
    'D546DF97-4757-47EF-BE09-3E2DCBDD0C77': false
  };
  var points = [
    {
      'uid': 'FDA50693-A4E2-4FB1-AFCF-C6EB07647825',
      'message': 'gire a la derecha por favor',
    },
    {
      'uid': 'D546DF97-4757-47EF-BE09-3E2DCBDD0C77',
      'message': 'gire a la derecha por favor',
    }
  ];
  String product2 = '';

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
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Text("producto $product2")));
  }

  Future _speakMessage(description) async {
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('es-ES');
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(description);
  }

  void _handlerLists(beacons) {
    try {
      for (var item in points) {
        if (item['uid'] == beacons[0].proximityUUID) {
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
    //beacons con los que trabajaremos
    final regions = <Region>[
      Region(
        identifier: 'iBeacon2.0',
        proximityUUID: 'D546DF97-4757-47EF-BE09-3E2DCBDD0C77', //+encontrado
      ),
      Region(
        identifier: 'iBeacon2.1',
        proximityUUID: 'FDA50693-A4E2-4FB1-AFCF-C6EB07647825',
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
          .requestAuthorization; // es necesario pedir permisos al usuario para poder tener una respuesta!!
    }

    _requestBeacon();
    _initBeacon();

    flutterBeacon.ranging(regions).listen((RangingResult result) {
      //print(result.beacons);
      _handlerLists(result.beacons);
      // for (var item in points) {
      //   if (item['uid'] == result.beacons[0].proximityUUID) {
      //     print(item['message']);
      //   }
      // }
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
}
