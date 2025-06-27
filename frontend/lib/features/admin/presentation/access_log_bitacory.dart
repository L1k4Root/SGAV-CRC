

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Página de bitácora global de accesos.
/// Se diferencia del historial por vehículo: aquí mostramos TODOS los accesos
/// (o intentos) y luego se podrá filtrar por rango de fechas, guardia, placa, etc.
class AccessLogBitacoryPage extends StatelessWidget {
  const AccessLogBitacoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de Accesos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('access_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('Sin registros de accesos'));
          }

          final rows = snap.data!.docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            final ts = (data['timestamp'] as Timestamp?)?.toDate();
            final dateStr = ts != null
                ? DateFormat('yyyy-MM-dd HH:mm').format(ts)
                : '-';

            final plate = data['plate'] ?? '-';
            final guard = data['guardId'] ?? '-';
            final permitted = data['permitted'] == true;

            return DataRow(cells: [
              DataCell(Text(dateStr)),
              DataCell(Text(plate)),
              DataCell(Text(guard)),
              DataCell(Center(
                child: Icon(
                  permitted ? Icons.check_circle : Icons.cancel,
                  color: permitted ? Colors.green : Colors.red,
                  size: 18,
                ),
              )),
            ]);
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Patente')),
                DataColumn(label: Text('Guardia')),
                DataColumn(label: Text('Estado')),
              ],
              rows: rows,
            ),
          );
        },
      ),
    );
  }
}