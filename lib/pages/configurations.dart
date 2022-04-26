import 'package:beacon_test/pages/speech_page.dart';
import 'package:flutter/material.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  // Speach States
  bool gamify = true;
  String nombre = "Custom";
  String speechVel = "0.5";

  String dir7825 = "";
  String pasos7825 = "";

  String dir6666 = "";
  String pasillo6666 = "";

  String dirBA31 = "";
  String pasosBA31 = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Configuration"),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            const Text("Configuraciones"),
            SwitchListTile(
              title: const Text("gamify"),
              value: gamify,
              onChanged: (value) {
                setState(() {
                  gamify = value;
                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  nombre = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter User Name',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  speechVel = value;
                });
              },
              decoration: const InputDecoration(
                label: Text("Vel speech"),
                hintText: 'Enter value from 0 to 1',
              ),
            ),
            const Text("Config Beacons",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const Text("Beacon 7825:"),
            TextField(
              onChanged: (value) {
                setState(() {
                  dir7825 = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Direccion de 7825',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  pasos7825 = value;
                });
              },
              decoration: const InputDecoration(
                label: Text("Pasos"),
                hintText: 'Numero de pasos',
              ),
            ),
            const Text("Beacon BA31:"),
            TextField(
              onChanged: (value) {
                setState(() {
                  dirBA31 = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Direccion de BA31',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  pasosBA31 = value;
                });
              },
              decoration: const InputDecoration(
                label: Text("Pasos"),
                hintText: 'Numero de pasos',
              ),
            ),
            const Text("Beacon 6666 (END):"),
            TextField(
              onChanged: (value) {
                setState(() {
                  dir6666 = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Direccion de 6666',
              ),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  pasillo6666 = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Dir pasillo de 6666',
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 24),
                  backgroundColor: Colors.lightBlue),
              onPressed: () {
                _showSpeechPage(context);
              },
              child: const Text('Start',
                  style: TextStyle(color: Colors.lightGreenAccent)),
            ),
          ],
        )));
  }

  @override
  void initState() {
    super.initState(); // inicializa los estados
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showSpeechPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SpeechPage(
                title: 'Speech',
                gamify: gamify,
                nombre: nombre,
                rateSpeech: speechVel,
                dir7825: dir7825,
                pasos7825: pasos7825,
                dir6666: dir6666,
                pasillo6666: pasillo6666,
                dirBA31: dirBA31,
                pasosBA31: pasosBA31)));
    // Navigator.pushNamed(context, 'beacons', arguments: _lastWords );
  }
}
