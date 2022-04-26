import 'package:flutter_tts/flutter_tts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/material.dart';

class NfcPage extends StatefulWidget {
  const NfcPage({Key? key, required this.rateSpeech, required this.gamify})
      : super(key: key);

  final String rateSpeech;
  final bool gamify;
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
      "name": "Café Alcazar. 500 gramos. Tipo Organico. Valor 6000 Pesos. "
          "Mantén el dedo sobre la pantalla para saber la fecha de vencimiento. "
          "Si quieres comprarlo toca dos veces la pantalla",
      "tagId": [4, 245, 119, 58, 20, 111, 128],
      "description": "Este producto vence el 20 de Septiembre del 2022"
    },
    {
      "id": 2,
      "name": "Chocolate Corona. 180 Gramos. No es Organico. Valor 2000 Pesos. "
          "Mantén el dedo sobre la pantalla para saber la fecha de vencimiento. "
          "Si quieres comprarlo toca dos veces la pantalla",
      "tagId": [4, 1, 119, 58, 20, 111, 129],
      "description": "Este producto vence el 20 de Junio del 2022"
    },
    {
      "id": 3,
      "name": "Cafe Minca. 280 Gramos. Tipo Organico. Valor 700 Pesos. "
          "Mantén el dedo sobre la pantalla para saber la fecha de vencimiento. "
          "Si quieres comprarlo toca dos veces la pantalla",
      "tagId": [4, 253, 119, 58, 20, 111, 128],
      "description": "Este producto vence el 12 de Diciembre del 2022"
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
                  GestureDetector(
                      onDoubleTap: () {
                        _productSelected();
                      },
                      onLongPress: () {
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

  Future _productSelected() async {
    await flutterTts.setVolume(1);
    var rate = double.parse(widget.rateSpeech);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('es-ES');
    await flutterTts.awaitSpeakCompletion(true);
    if (widget.gamify) {
      await flutterTts.speak(
          "Producto agregado. Excelente trabajo, tu experiencia incrementó 200 puntos, ahora eres un buscador avanzado. Entre mas experiencia, mas beneficios tendras.");
    } else {
      await flutterTts.speak(
          "Producto agregado. Excelente trabajo, econtraste el producto que querías");
    }
  }

  Future _speak(name) async {
    await flutterTts.setVolume(1);
    var rate = double.parse(widget.rateSpeech);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('es-ES');
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak("El producto es: " + name);
  }

  Future _speakDescription(description) async {
    await flutterTts.setVolume(1);
    var rate = double.parse(widget.rateSpeech);
    await flutterTts.setSpeechRate(rate);
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
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      _setId(result.value['nfca'][
          'identifier']); // Se ejecuta la funcion _setId quien procesa el identificador del tag
      //NfcManager.instance.stopSession();  // Cuando esta descomentado la aplciacion se detiene y usa la aplicacion de scaneo de bfc por default del sistema del telefono
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
