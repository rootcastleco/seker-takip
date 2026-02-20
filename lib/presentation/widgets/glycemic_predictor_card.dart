import 'package:flutter/material.dart';
import '../../core/services/glycemic_engine.dart';
import '../../core/constants.dart';
import '../widgets/glass_widgets.dart';

/// Dashboard'daki Besin Etkisi Tahmini kartı.
///
/// Kullanıcı yemek arar → porsiyon seçer → animasyonlu glisemik tahmin görür.
class GlycemicPredictorCard extends StatefulWidget {
  /// Kamera tarayıcıya geçiş callback'i.
  final VoidCallback? onOpenScanner;

  const GlycemicPredictorCard({super.key, this.onOpenScanner});

  @override
  State<GlycemicPredictorCard> createState() => _GlycemicPredictorCardState();
}

class _GlycemicPredictorCardState extends State<GlycemicPredictorCard>
    with SingleTickerProviderStateMixin {
  TurkishFoodItem? _selectedFood;
  PortionSize _portion = PortionSize.normal;
  GlycemicPrediction? _prediction;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_selectedFood == null) return;
    setState(() {
      _prediction = GlycemicEngine.instance.predict(_selectedFood!, _portion);
    });
    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              GlassSectionHeader(
                title: 'Besin Etkisi Tahmini',
                icon: Icons.restaurant_menu,
              ),
              const Spacer(),
              if (widget.onOpenScanner != null)
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: isDark ? RC.accent : RC.blue,
                    size: 22,
                  ),
                  tooltip: 'AR Kamera ile tara',
                  onPressed: widget.onOpenScanner,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Yemek Arama
          Autocomplete<TurkishFoodItem>(
            displayStringForOption: (f) => '${f.emoji} ${f.name}',
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return GlycemicEngine.turkishFoods.take(8);
              }
              final results =
                  GlycemicEngine.instance.search(textEditingValue.text);
              return results.isEmpty
                  ? GlycemicEngine.turkishFoods.take(5)
                  : results;
            },
            onSelected: (food) {
              setState(() => _selectedFood = food);
              _calculate();
            },
            fieldViewBuilder: (ctx, ctrl, fn, onSubmitted) {
              return TextField(
                controller: ctrl,
                focusNode: fn,
                decoration: glassInputDecoration(
                  context: context,
                  label: 'Yemek ara (Örn: Pilav, Baklava, Elma)',
                ).copyWith(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                ),
                onSubmitted: (_) => onSubmitted(),
              );
            },
            optionsViewBuilder: (ctx, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? RC.bgDark2 : Colors.white,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (_, i) {
                        final food = options.elementAt(i);
                        return ListTile(
                          dense: true,
                          leading: Text(food.emoji, style: const TextStyle(fontSize: 20)),
                          title: Text(
                            food.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${food.category} • GI: ${food.glycemicIndex}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          ),
                          onTap: () => onSelected(food),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Porsiyon seçici
          if (_selectedFood != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Porsiyon: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                ...PortionSize.values.map((p) {
                  final isSelected = p == _portion;
                  final label = p == PortionSize.small
                      ? 'Küçük'
                      : p == PortionSize.large
                          ? 'Büyük'
                          : 'Normal';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      selectedColor: isDark
                          ? RC.blue.withOpacity(0.3)
                          : RC.blue.withOpacity(0.15),
                      onSelected: (_) {
                        setState(() => _portion = p);
                        _calculate();
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ],
            ),
          ],

          // Sonuç kartı
          if (_prediction != null)
            FadeTransition(
              opacity: _fadeAnim,
              child: _buildResult(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    final p = _prediction!;
    final riskColor = p.food.glycemicIndex > 70
        ? Colors.red
        : p.food.glycemicIndex > 55
            ? Colors.orange
            : RC.accentGreen;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            riskColor.withOpacity(isDark ? 0.15 : 0.08),
            riskColor.withOpacity(isDark ? 0.05 : 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: riskColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Row(
            children: [
              Text(
                p.food.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  p.summary,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Metrikler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric(
                icon: Icons.timer,
                label: 'Pik',
                value: '${p.peakMinutes} dk',
                color: riskColor,
                isDark: isDark,
              ),
              _metric(
                icon: Icons.trending_up,
                label: 'Artış',
                value: '~${p.estimatedRiseMgDl} mg/dL',
                color: riskColor,
                isDark: isDark,
              ),
              _metric(
                icon: Icons.speed,
                label: 'GL',
                value: p.glycemicLoad.toStringAsFixed(1),
                color: riskColor,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Egzersiz önerisi
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: RC.accentGreen.withOpacity(isDark ? 0.1 : 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: RC.accentGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_walk, color: RC.accentGreen, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${p.exerciseMinutes} dakika ${p.exerciseType} '
                    'yaparak bu glisemik yükü dengeleyebilirsin.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detaylı açıklama
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              p.detailedAdvice,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white38 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white38 : Colors.grey,
          ),
        ),
      ],
    );
  }
}
