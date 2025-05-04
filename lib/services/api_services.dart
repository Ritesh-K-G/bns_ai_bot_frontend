import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../models/chat_message.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ApiService {
  static Future<ChatMessage> sendMessage(String message) async {
    await Future.delayed(const Duration(seconds: 1));

    final isFile = message.contains("file");
    if (isFile) {
      if (kIsWeb) {
        // Web fallback
        return ChatMessage(
          message: 'file:web_mock_file.txt',
          isUser: false,
        );
      } else {
        final file = await _generateMockFile();
        return ChatMessage(
          message: 'file:${file.path}',
          isUser: false,
        );
      }
    } else {
      return ChatMessage(
        message: 'Thanks for your message! Here is a response.',
        isUser: false,
      );
    }
  }

  static Future<io.File> _generateMockFile() async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = io.File('${dir.path}/bns_report.pdf');

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('This is a valid generated PDF file.'),
        ),
      ),
    );

    final bytes = await pdf.save();
    return file.writeAsBytes(bytes);
  }
}