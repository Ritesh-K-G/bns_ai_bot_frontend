import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_message.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:dio/dio.dart';
import 'dart:html' as html;


class ApiService {
  static Future<ChatMessage> sendMessage(
      String message, List<Map<String, dynamic>> history) async {
    try {
      final Dio dio =
          Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'));

      Response response = await dio
          .post('/query', data: {"history": history, "query": message});

      final isFile = response.data['type'] == "scenario";
      if (isFile) {
        final List<Map<String, dynamic>> results =
              List<Map<String, dynamic>>.from(response.data['results']);
        if (results.isEmpty) {
          return ChatMessage(
              message: "Please clarify more about your scenario",
              isUser: false,
              content: '');
        }
        final file = await _generateMockFile(results);
        String content = "Predicted Sections: \n";
        for (var section in results) {
          content += section['Section Title'] + '\n';
        }
        if (file == null) {
          return ChatMessage(message: 'Report is downloaded to browser', isUser: false, content: 'Report');
        }
        return ChatMessage(
            message: 'file:${file.path}', isUser: false, content: content);
      } else {
        return ChatMessage(
            message: response.data['results'],
            isUser: false,
            content: response.data['results']);
      }
    } catch (e) {
      print("Error sending message: $e");
      return ChatMessage(
        message:
            'An error occurred while sending your message. Please try again after sometimes :)',
        isUser: false,
        content: '',
      );
    }
  }

  static Future<io.File?> _generateMockFile(List<Map<String, dynamic>> data) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd_MMMM_yyyy_HH_mm_ss').format(now);
    final fileName = 'bns_report_$formattedDate.pdf';

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
                      'Chapter ${entry["Chapter Number"]}: ${entry["Chapter Name"]}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Section ${entry["Section Number"]}: ${entry["Section Title"]}',
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
                      entry["Section Description"],
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
                      entry["Justification"],
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      // Web: trigger browser download
      final blob = html.Blob([pdfBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      return null; // no file created on web
    } else {
      // Mobile/Desktop: save to temp directory
      final dir = await getTemporaryDirectory();
      final file = io.File('${dir.path}/$fileName');
      return await file.writeAsBytes(pdfBytes);
    }
  }
}
