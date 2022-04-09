import 'package:flutter_tts/flutter_tts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/material.dart';

class NfcPage extends StatefulWidget {
  const NfcPage({Key? key}) : super(key: key);

  @override
  State<NfcPage> createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  FlutterTts flutterTts = FlutterTts();
  ValueNotifier<dynamic> result = ValueNotifier(null);

  Map producto = {"id": 0, "name": "", "description": ""};
  List tagIds = [
    {
      "id": 1,
      "name": "Café Colombia",
      "tagId": [4, 245, 119, 58, 20, 111, 128],
      "description":
          "Valor 3500 Pesos. 500 gramos de contenido, este producto vence el 20 de Marzo del 2022"
    },
    {
      "id": 2,
      "name": "Chocolate",
      "tagId": [62, 245, 28, 228],
      "description":
          "Valor 2000 Pesos. 500 gramos de contenido, este producto vence el 20 de Enero del 2022"
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder(
          future: checkNfc(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Esperando Data");
            } else {
              return Flex(
                /* mainAxisAlignment: MainAxisAlignment.spaceBetween, */
                direction: Axis.vertical,
                children: [
                  Flexible(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder<dynamic>(
                        valueListenable: result,
                        builder: (context, value, _) => Text('${value ?? ''}'),
                      ),
                    ),
                  ),
                  /* Flexible(
                        flex: 1,
                        child: GridView.count(
                          padding: EdgeInsets.all(4),
                          crossAxisCount: 2,
                          childAspectRatio: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          children: [
                            Text(producto),
                            /* ElevatedButton(
                                child: Text('Tag Read'), onPressed: _tagRead), */

                          ],
                        ),
                      ), */

                  GestureDetector(
                      onDoubleTap: () {
                        _speakDescription(producto["description"]);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        width: 300,
                        height: 600,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lightGreen[50],
                          boxShadow: const [
                            BoxShadow(color: Colors.green, spreadRadius: 3),
                          ],
                        ),
                        child: Center(child: Text(producto["name"])),
                      ))
                ],
              );
            }
          },
        ));
  }

  Future _speak(name) async {
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('es-ES');
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak("El producto es: " + name);
  }

  Future _speakDescription(description) async {
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('es-ES');
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(description);
  }

  Future<bool> checkNfc() async {
    final aux = await NfcManager.instance.isAvailable();
    return aux;
  }

  bool areListsEqual(var list1, var list2) {
    // check if both are lists
    if (!(list1 is List && list2 is List)
        // check if both have same length
        ||
        list1.length != list2.length) {
      return false;
    }
    // check if elements are equal
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
  }

  void _setId(_list) {
    //print (_list);
    for (var item in tagIds) {
      // para cada item del estado tagsIds, se evalua a que identificador corresponde
      if (areListsEqual(item["tagId"], _list)) {
        setState(() {
          producto = item;
        });
        _speak(item[
            'name']); //Si hace match se ejecuta un mensaje de voz con la descripcion del producto.
        print("Entro al  If");
      } else {
        print("No entro");
      }
    }
/*  if(areListsEqual(item["tagId"], [4, 245, 119, 58, 20, 111, 128]) ){
      setState(() {
        producto["name"]="Cafe";
      });
      _speak();
      print ("Entro al  If");
    }else{
      print ("No entro");
    } */
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      _setId(result.value['nfca'][
          'identifier']); // Se ejecuta la funcion _setId quien procesa el identificador del tag
      //NfcManager.instance.stopSession();  // When is uncoment, the app stop the session and init the session by default from NFC phone
    });
  }

  @override
  void initState() {
    // Antes de dibujar por primera vez se ejecuta esta funcion
    super.initState(); // inicializa los estados
    _tagRead(); // Se ejecuta la lectura del tag y la app queda a la espera
  }

  @override
  void dispose() {
    super.dispose();
  }
}
