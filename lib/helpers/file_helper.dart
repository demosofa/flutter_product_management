import 'dart:io';

import 'package:archive/archive_io.dart';

mixin FileHelper {
  Future<FileSystemEntity> delete(String path) async {
    return File(path).delete();
  }

  Future<File?> archive(List<String> paths, String targetPath) async {
    final isZip = targetPath.endsWith(".zip");
    final isTar = targetPath.endsWith(".tar");
    if (!isZip && !isTar) {
      return null;
    }
    final archive = Archive();
    for (String path in paths) {
      final bytes = await File(path).readAsBytes();
      final file = ArchiveFile(path, bytes.length, bytes);
      archive.addFile(file);
    }
    List<int>? encodeArchive;
    if (isZip) {
      final zipEncoder = ZipEncoder();
      encodeArchive = zipEncoder.encode(archive);
    } else if (isTar) {
      final tarEncoder = TarEncoder();
      encodeArchive = tarEncoder.encode(archive);
    }
    if (encodeArchive == null) return null;
    return File(targetPath).writeAsBytes(encodeArchive);
  }

  List<File?> extract(String path, [String targetPath = 'out']) {
    final isZip = path.endsWith(".zip");
    final isTar = path.endsWith(".tar");
    if (!isZip && !isTar) {
      return [];
    }
    final inputStream = InputFileStream(path);
    Archive? decodeArchive;
    if (isZip) {
      final zipDecoder = ZipDecoder();
      decodeArchive = zipDecoder.decodeStream(inputStream);
    } else if (isTar) {
      final tarDecoder = TarDecoder();
      decodeArchive = tarDecoder.decodeStream(inputStream);
    }
    if (decodeArchive == null) return [];
    return decodeArchive.files.map((file) {
      if (file.isFile) {
        final outPath = "$targetPath/${file.name}";
        final outputStream = OutputFileStream(outPath);
        file.writeContent(outputStream);
        outputStream.close();
        return File(outPath);
      }
    }).toList();
  }
}
