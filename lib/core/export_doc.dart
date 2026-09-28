import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Build a simple PDF from plain text (stories, notes, solutions).
class ExportDoc {
  static Future<File> toPdf({
    required String title,
    required String body,
  }) async {
    final doc = pw.Document();
    final pages = _chunk(body, 2200);
    for (var i = 0; i < pages.length; i++) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => [
            if (i == 0)
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            if (i == 0) pw.SizedBox(height: 16),
            pw.Text(
              pages[i],
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
            ),
          ],
        ),
      );
    }

    final dir = await getTemporaryDirectory();
    final safe = title
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
        .trim()
        .replaceAll(' ', '_');
    final name = (safe.isEmpty ? 'jagx_export' : safe);
    final file = File('${dir.path}/$name.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static Future<void> sharePdf({
    required String title,
    required String body,
  }) async {
    final f = await toPdf(title: title, body: body);
    await Share.shareXFiles([XFile(f.path)], text: title);
  }

  static Future<void> shareTextFile({
    required String title,
    required String body,
  }) async {
    final dir = await getTemporaryDirectory();
    final safe = title
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
        .trim()
        .replaceAll(' ', '_');
    final file = File('${dir.path}/${safe.isEmpty ? 'jagx' : safe}.txt');
    await file.writeAsString(body);
    await Share.shareXFiles([XFile(file.path)], text: title);
  }

  static List<String> _chunk(String text, int size) {
    if (text.length <= size) return [text];
    final out = <String>[];
    var i = 0;
    while (i < text.length) {
      final end = (i + size > text.length) ? text.length : i + size;
      out.add(text.substring(i, end));
      i = end;
    }
    return out;
  }
}
