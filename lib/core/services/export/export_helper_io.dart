import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> saveFile(List<int> bytes, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final filePath = p.join(tempDir.path, fileName);
  final file = File(filePath);
  await file.writeAsBytes(bytes);
  return filePath;
}
