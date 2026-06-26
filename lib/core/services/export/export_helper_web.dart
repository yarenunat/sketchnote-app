// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

Future<String> saveFile(List<int> bytes, String fileName) async {
  final base64 = base64Encode(bytes);
  final uri = 'data:application/octet-stream;base64,$base64';
  
  html.AnchorElement(href: uri)
    ..setAttribute('download', fileName)
    ..click();
    
  return 'Browser Download: $fileName';
}
