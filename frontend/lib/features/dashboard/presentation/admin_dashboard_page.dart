import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = Timestamp.fromDate(
        DateTime(_range.start.year, _range.start.month, _range.start.day));
    final end = Timestamp.fromDate(
        DateTime(_range.end.year, _range.end.month, _range.end.day + 1)
            .subtract(const Duration(milliseconds: 1)));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboards')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // Date range filter
                Row(
                  children: [
                    Text(
                      'Rango: ${DateFormat('dd/MM/yyyy').format(_range.start)} - ${DateFormat('dd/MM/yyyy').format(_range.end)}',
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Seleccionar rango'),
                      onPressed: _pickDateRange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('access_logs')
                      .where('timestamp', isGreaterThanOrEqualTo: start)
                      .where('timestamp', isLessThanOrEqualTo: end)
                      .snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    // Compute metrics
                    final total = docs.length;
                    final allowed = docs.where((d) => (d['permitted'] ?? false)).length;
                    final denied = total - allowed;
                    final vehicles = <String>{};
                    final guards = <String>{};
                    final dailyCounts = <String, int>{};
                    for (var d in docs) {
                      vehicles.add(d['plate'] ?? '');
                      guards.add(d['guardId'] ?? '');
                      final ts = (d['timestamp'] as Timestamp).toDate();
                      final day = DateFormat('yyyy-MM-dd').format(ts);
                      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
                    }
                    // Prepare sorted daily list
                    final days = dailyCounts.keys.toList()..sort();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildCard('Total accesos', total.toString(), Colors.blue),
                            _buildCard('Ingresos', allowed.toString(), Colors.green),
                            _buildCard('Denegados', denied.toString(), Colors.red),
                            _buildCard('Vehículos únicos', vehicles.length.toString(), Colors.orange),
                            _buildCard('Guardias únicos', guards.length.toString(), Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Accesos por día', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              height: 220,
                              child: _buildBarChart(dailyCounts, days),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Detalles por día', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Fecha')),
                                DataColumn(label: Text('Conteo')),
                              ],
                              rows: days.map((day) {
                                return DataRow(cells: [
                                  DataCell(Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(day)))),
                                  DataCell(Text(dailyCounts[day].toString())),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> dailyCounts, List<String> days) {
    final maxCount = dailyCounts.values.isEmpty ? 0.0 : dailyCounts.values.reduce(max).toDouble();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 20,
        maxY: maxCount * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = days[group.x.toInt()];
              return BarTooltipItem(
                '${rod.toY.toInt()}\n$date',
                TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) return const SizedBox();
                final date = DateFormat('dd/MM').format(DateTime.parse(days[idx]));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxCount > 5 ? (maxCount / 5).ceilToDouble() : 1,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxCount > 5 ? (maxCount / 5) : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
        barGroups: List.generate(days.length, (i) {
          final y = dailyCounts[days[i]]!.toDouble();
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: y, color: Colors.blue.shade300, width: 20),
          ]);
        }),
      ),
    );
  }
}