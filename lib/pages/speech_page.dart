import 'dart:async';
import 'package:beacon_test/pages/beacons_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechPage extends StatefulWidget {
  const SpeechPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends State<SpeechPage> {
  // Speach States
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  // TTS
  FlutterTts flutterTts = FlutterTts();

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
        // Here we take the value from the SpeechPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  // If listening is active show the recognized words
                  _speechToText.isListening
                      ? _lastWords
                      // If listening isn't active but could be tell the user
                      // how to start it, otherwise indicate that speech
                      // recognition is not yet ready or not supported on
                      // the target device
                      : _speechEnabled
                          ? 'Mantener presionado para hablar...'
                          : 'Speech not available',
                ),
              ),
            ),
            GestureDetector(
                onDoubleTap: () {
                  _showBeaconPage(context);
                },
                onLongPress: _startListening,
                onLongPressUp: _stopListening,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  width: 300,
                  height: 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.grey[900],
                    boxShadow: const [
                      BoxShadow(color: Colors.cyan, spreadRadius: 3),
                    ],
                  ),
                ))
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton( //button floating
      //   onPressed:
      //       // If not yet listening for speech start, otherwise stop
      //       _speechToText.isNotListening ? _startListening : _stopListening,
      //   tooltip: 'Listen',
      //   child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      // ),
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

  // Functions to Speech library
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult, localeId: 'es_ES');
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (result.recognizedWords != '') {
      _speakMessage(
          'el producto es: ${result.recognizedWords}. Si es correcto, toca dos veces sobre la pantalla para continuar. Si no es así maten presionado nuevamente para hablar');
    }
  }

  @override
  void initState() {
    super.initState(); // inicializa los estados
    //Funcion periodica que resetea los puntos por si el usuario se queda en un solo punto
    // Timer.periodic(const Duration(seconds: 30), (timer) {
    //   print("Reset CHEKK!!");
    // });

    _speakMessage(
        'Hola Consuelo, bienvenida. Eres muy buena encontrando broductos y es una habilidad que pocos poseen, así que vamos en busca de algunos se ellos. ¿Qué producto quieres encontrar hoy?. Mantén el dedo sobre la pantalla para hablar');
    _initSpeech();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showBeaconPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                BeaconsPage(product: _lastWords)));
    // Navigator.pushNamed(context, 'beacons', arguments: _lastWords );
  }
}
