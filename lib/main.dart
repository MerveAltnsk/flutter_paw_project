import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';


void main() {
  
}

void requestPermissions() async {
  // Mikrofon izni isteme
  if (await Permission.microphone.request().isGranted) {
    // Mikrofon izni verilmiş
  } else {
    // Mikrofon izni verilmemiş
  }

  // Depolama izni isteme
  if (await Permission.storage.request().isGranted) {
    // Depolama izni verilmiş
  } else {
    // Depolama izni verilmemiş
  }
}



// Ses Kaydetme Fonksiyonu:
FlutterSoundRecorder _recorder = FlutterSoundRecorder();
bool isRecording = false;
String? filePath;

Future<void> startRecording() async {
  Directory directory = await getApplicationDocumentsDirectory();
  filePath = '${directory.path}/pet_sound.aac';

  await _recorder.openRecorder();
  await _recorder.startRecorder(toFile: filePath);
  isRecording = true;
}

Future<void> stopRecording() async {
  await _recorder.stopRecorder();
  await _recorder.closeRecorder(); // Make sure to close the recorder session.
  isRecording = false;
}




// Ses Analizi için Yapay Zeka Entegrasyonu

Future<String> translateSound(String filePath) async {
  var request = http.MultipartRequest('POST', Uri.parse('https://your-ai-api-url.com/translate'));
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  var response = await request.send();
  if (response.statusCode == 200) {
    var responseData = await http.Response.fromStream(response);
    var jsonData = jsonDecode(responseData.body);
    return jsonData['translation'];  // "Mama istiyorum" gibi bir çeviri döner
  } else {
    return "Çeviri başarısız oldu";
  }
}


// Kullanıcı Arayüzü Tasarımı

class PetTranslator extends StatefulWidget {
  @override
  _PetTranslatorState createState() => _PetTranslatorState();
}

class _PetTranslatorState extends State<PetTranslator> {
  String translation = "Çeviri bekleniyor...";
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Pet Translator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (!isRecording) {
                  await startRecording();
                } else {
                  await stopRecording();
                  var result = await translateSound(filePath!);
                  setState(() {
                    translation = result;
                  });
                }
                setState(() {
                  isRecording = !isRecording;
                });
              },
              child: Text(isRecording ? 'Kaydı Bitir' : 'Ses Kaydet'),
            ),
            SizedBox(height: 20),
            Text(
              translation,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
