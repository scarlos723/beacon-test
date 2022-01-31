import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  Map<String, bool> way = {
    'FDA50693-A4E2-4FB1-AFCF-C6EB07647825': false,
    'D546DF97-4757-47EF-BE09-3E2DCBDD0C77': false
  };
  FlutterTts flutterTts = FlutterTts();
  StreamSubscription<RangingResult>? _streamRanging;
  StreamSubscription<BluetoothState>? _streamBluetooth;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];

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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(),
      ),
    );
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
    super.initState(); // inicializa los estados
    //Funcion periodica que resetea los puntos por si el usuario se queda en un solo punto
    Timer.periodic(const Duration(seconds: 30), (timer) {
      print("Reset CHEKK!!");
    });
    _beaconRead();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
