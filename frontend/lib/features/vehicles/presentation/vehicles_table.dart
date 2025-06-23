import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';

class VehiclesTablePage extends StatefulWidget {
  const VehiclesTablePage({super.key});
  @override
  State<VehiclesTablePage> createState() => _VehiclesTablePageState();
}

class _VehiclesTablePageState extends State<VehiclesTablePage> {
  final _search = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('vehicles');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos registrados'),
        actions: [
          SizedBox(
            width: 240,
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Buscar patente…',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (v) => setState(() => _filter = v.toUpperCase()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _search.clear();
              setState(() => _filter = '');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (ctx, snap) {
          if (snap.hasError) return const Center(child: Text('Error'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs.where((d) {
            if (_filter.isEmpty) return true;
            return (d['plate'] as String).contains(_filter);
          }).toList();

          return _VehiclesDataTable(docs: docs);
        },
      ),
    );
  }
}

class _VehiclesDataTable extends StatefulWidget {
  const _VehiclesDataTable({required this.docs});
  final List<QueryDocumentSnapshot> docs;

  @override
  State<_VehiclesDataTable> createState() => _VehiclesDataTableState();
}

class _VehiclesDataTableState extends State<_VehiclesDataTable> {
  static const _rowsPerPage = 10;
  int _rowsOffset = 0;

  @override
  Widget build(BuildContext context) {
    final rows = widget.docs.map((d) {
      final plate = d['plate'] as String;
      final data = d.data() as Map<String, dynamic>;
      final model = data['model'] ?? '-';
      final color = data['color'] ?? '-';
      final active = !(data.containsKey('inactive') ? data['inactive'] as bool : false);

      return DataRow(cells: [
        DataCell(Text(plate, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        DataCell(Text(model)),
        DataCell(Text(color)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(active ? 'Activo' : 'Inactivo',
              style: GoogleFonts.inter(
                  color: active ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500)),
        )),
      ]);
    }).toList();

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: PaginatedDataTable2(
            wrapInCard: true,
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 600,
            rowsPerPage: _rowsPerPage,
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn2(label: Text('Patente'), size: ColumnSize.S),
              DataColumn2(label: Text('Modelo'),  size: ColumnSize.M),
              DataColumn2(label: Text('Color'),   size: ColumnSize.M),
              DataColumn2(label: Text('Estado'),  size: ColumnSize.S),
            ],
            source: _TableSource(rows),
            onPageChanged: (o) => setState(() => _rowsOffset = o),
            initialFirstRowIndex: _rowsOffset,
          ),
        );
      },
    );
  }
}

class _TableSource extends DataTableSource {
  _TableSource(this._rows);
  final List<DataRow> _rows;
  @override bool get isRowCountApproximate => false;
  @override int get rowCount => _rows.length;
  @override int get selectedRowCount => 0;
  @override DataRow? getRow(int index) => index < _rows.length ? _rows[index] : null;
}
