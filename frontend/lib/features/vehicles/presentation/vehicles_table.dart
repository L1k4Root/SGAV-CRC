import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../shared/repositories/vehicles_repository.dart';

class VehiclesTablePage extends StatefulWidget {
  final String ownerId;
  const VehiclesTablePage({super.key, required this.ownerId});
  final String ownerId;
  const VehiclesTablePage({super.key, required this.ownerId});
  @override
  State<VehiclesTablePage> createState() => _VehiclesTablePageState();
}

class _VehiclesTablePageState extends State<VehiclesTablePage> {
  final _search = TextEditingController();
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final isAdmin = ModalRoute.of(context)?.settings.name == '/vehicles-admin';
  @override
  Widget build(BuildContext context) {
    final isAdmin = ModalRoute.of(context)?.settings.name == '/vehicles-admin';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

    final query = isAdmin
        ? FirebaseFirestore.instance.collection('vehicles').orderBy('createdAt')
        : FirebaseFirestore.instance.collection('vehicles')
            .where('ownerId', isEqualTo: widget.ownerId);
    final query = isAdmin
        ? FirebaseFirestore.instance.collection('vehicles').orderBy('createdAt')
        : FirebaseFirestore.instance.collection('vehicles')
            .where('ownerId', isEqualTo: widget.ownerId);

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

  final _repo = VehiclesRepository();

  Future<void> _toggleActive(String docId, bool active) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(active ? 'Desactivar invitación' : 'Reactivar invitación'),
        content: Text(
          active
              ? 'Después de desactivarla el vehículo ya no podrá ingresar.\n¿Confirmar?'
              : '¿Confirmar reactivación de la invitación?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('vehicles').doc(docId).update({
      'active': !active,
      'pendingOut': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(active ? 'Invitación desactivada' : 'Invitación reactivada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ModalRoute.of(context)?.settings.name == '/vehicles-admin';

    final rows = widget.docs.map((d) {
      final plate = d['plate'] as String;
      final data = d.data() as Map<String, dynamic>;
      final model = data['model'] ?? '-';
      final color = data['color'] ?? '-';
      final active = data.containsKey('active')
          ? (data['active'] as bool)
          : true; // default true if field missing
      final owner = data['ownerEmail'] ?? '—';

      return DataRow(cells: [
        DataCell(Text(plate, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        if (isAdmin) DataCell(Text(owner)),
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
        if (!isAdmin)
          DataCell(
            IconButton(
              icon: Icon(
                active ? Icons.block : Icons.check_circle,
                size: 18,
                color: active ? Colors.red : Colors.green,
              ),
              tooltip: active ? 'Desactivar' : 'Reactivar',
              onPressed: () => _toggleActive(d.id, active),
            ),
          ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Eliminar vehículo',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: Text('¿Eliminar vehículo $plate?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await _repo.delete(d.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehículo eliminado')),
                );
              }
            },
          ),
        ),
      ]);
    }).toList();

    final columns = [
      const DataColumn2(label: Text('Patente'), size: ColumnSize.S),
      if (isAdmin)
        const DataColumn2(label: Text('Owner'),  size: ColumnSize.M),
      const DataColumn2(label: Text('Modelo'),  size: ColumnSize.M),
      const DataColumn2(label: Text('Color'),   size: ColumnSize.M),
      const DataColumn2(label: Text('Estado'),  size: ColumnSize.S),
      if (!isAdmin)
        const DataColumn2(label: Text('Acción'), size: ColumnSize.S),
      const DataColumn2(label: Text('Eliminar'), size: ColumnSize.S),
    ];

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
            headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
            columns: columns,
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
