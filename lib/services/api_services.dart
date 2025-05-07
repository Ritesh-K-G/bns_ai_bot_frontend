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
        final data = [
          {
            "chapter no.": 1,
            "chapter title": "General Principles",
            "section no.": 101,
            "section title": "Definitions",
            "description": "This section defines key legal terms.",
            "justification": "Clarifies ambiguity in legal proceedings."
          },
          {
            "chapter no.": 2,
            "chapter title": "Offenses",
            "section no.": 202,
            "section title": "Fraud",
            "description": "Defines what constitutes fraud under the code.",
            "justification": "Ensures clarity for law enforcement and judiciary."
          }
        ];
        final file = await _generateMockFile(data);
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

  static Future<io.File> _generateMockFile(List<Map<String, dynamic>> data) async {
    final dir = await getTemporaryDirectory();
    final file = io.File('${dir.path}/bns_report.pdf');

    final pdf = pw.Document();

    final baseColor = PdfColors.blueGrey900;
    final highlightColor = PdfColors.lightBlue100;
    final titleColor = PdfColors.indigo800;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'BNS Court Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: baseColor,
                ),
              ),
            ),
            for (var entry in data)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: highlightColor,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: baseColor, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Chapter ${entry["chapter no."]}: ${entry["chapter title"]}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Section ${entry["section no."]}: ${entry["section title"]}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Description:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: baseColor,
                      ),
                    ),
                    pw.Text(
                      entry["description"],
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Justification:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: baseColor,
                      ),
                    ),
                    pw.Text(
                      entry["justification"],
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    return file.writeAsBytes(bytes);
  }
}