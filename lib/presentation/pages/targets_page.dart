import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../widgets/glass_widgets.dart';

/// Diyabette İdeal Hedefler sayfası — sabit tablo.
class TargetsPage extends StatelessWidget {
  const TargetsPage({super.key});

  static const _targets = [
    ('HbA1c', '< %6.5'),
    ('AKŞ (Açlık Kan Şekeri)', '< 100 mg/dL'),
    ('TKŞ (Tokluk Kan Şekeri)', '< 140 mg/dL'),
    ('Kan Basıncı', '< 130/80 mmHg'),
    ('LDL', '< 100 mg/dL'),
    ('HDL', '> 50 mg/dL'),
    ('Trigliserit', '< 150 mg/dL'),
    ('Kolesterol', '< 200 mg/dL'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: const GlassAppBar(title: Tr.idealHedefler),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 50, 16, 24),
        children: [
          Text(
            Tr.hedeflerBaslik,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? RC.accent : RC.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: DataTable(
              columns: [
                DataColumn(
                  label: Text(
                    'Parametre',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RC.blue,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Hedef Değer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RC.blue,
                    ),
                  ),
                ),
              ],
              rows: _targets
                  .map(
                    (t) => DataRow(
                      cells: [
                        DataCell(Text(t.$1)),
                        DataCell(
                          Text(
                            t.$2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? RC.accentGreen : RC.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderColor: Colors.amber.withOpacity(0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Tr.hedeflerDipnot,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
