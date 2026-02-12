import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../widgets/rootcastle_app_bar.dart';

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
    return Scaffold(
      appBar: const RootcastleAppBar(title: Tr.idealHedefler),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Tr.hedeflerBaslik,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: RootcastleColors.blue,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Parametre')),
                DataColumn(label: Text('Hedef Değer')),
              ],
              rows: _targets
                  .map(
                    (t) => DataRow(
                      cells: [
                        DataCell(Text(t.$1)),
                        DataCell(
                          Text(
                            t.$2,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Tr.hedeflerDipnot,
                    style: Theme.of(context).textTheme.bodySmall,
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
