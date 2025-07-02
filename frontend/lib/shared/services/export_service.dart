// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:html' as html; // solo se compila en web

/// Servicio responsable de exportar registros a PDF.
/// Mantiene la lógica desacoplada de la UI para cumplir principios SOLID.
class ExportService {
  static Future<void> exportLogsAsPdf(BuildContext context) async {
    final query = await FirebaseFirestore.instance
        .collection('access_logs')
        .orderBy('timestamp', descending: true)
        .limit(500) // safety cap
        .get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay registros para exportar')),
      );
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Header(level: 0, child: pw.Text('Bitácora de accesos')),
          pw.Table.fromTextArray(
            headers: ['Fecha', 'Patente', 'Guardia', 'Estado'],
            data: query.docs.map((d) {
              final m = d.data();
              final ts = (m['timestamp'] as Timestamp?)?.toDate();
              final date = ts != null
                  ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
                    '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
                  : '-';
              return [
                date,
                m['plate'] ?? '-',
                m['guardId'] ?? '-',
                m['permitted'] == true ? 'SI' : 'NO',
              ];
            }).toList(),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final b64 = base64Encode(bytes);
      final url = 'data:application/pdf;base64,$b64';
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'bitacora_accesos.pdf')
        ..click();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF descargado')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/bitacora_accesos.pdf');
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generado: ${file.path}')),
      );
      await OpenFile.open(file.path);
    }
  }
}
