import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../app/routes.dart';
import '../pages/dashboard_page.dart';
import '../pages/records_table_page.dart';
import '../pages/sofia_ai_page.dart';
import '../pages/settings_page.dart';
import '../widgets/glass_widgets.dart';

/// Ana düzen — BottomNavigationBar + IndexedStack.
///
/// Tablar: Ana Sayfa, Kayıt Defteri, Analiz, Ayarlar.
/// Ortada FAB: Yeni kayıt ekleme (manuel + OCR).
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DashboardPage(),
    RecordsTablePage(),
    SofiaAiPage(),
    SettingsPage(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _onFabPressed() {
    _showNewEntrySheet();
  }

  void _showNewEntrySheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? RC.bgDark2 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                Tr.yeniKayitEkle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : RC.black,
                ),
              ),
              const SizedBox(height: 24),
              // Manuel giriş
              GlassListTile(
                icon: Icons.edit_note,
                label: 'Manuel Giriş',
                color: RC.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.recordEdit);
                },
              ),
              // OCR Tara
              GlassListTile(
                icon: Icons.camera_alt,
                label: Tr.kamerayiTara,
                color: RC.accentGreen,
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to record edit — OCR is accessible from there
                  Navigator.pushNamed(context, AppRoutes.recordEdit);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: RC.blue,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: RC.black,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Tr.tabAnaSayfa, isDark),
              _navItem(1, Icons.list_alt_rounded, Tr.tabKayitDefteri, isDark),
              const SizedBox(width: 56), // Space for FAB
              _navItem(2, Icons.auto_awesome, Tr.tabSofia, isDark),
              _navItem(3, Icons.settings_rounded, Tr.tabAyarlar, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? RC.accent : Colors.white.withValues(alpha: 0.4);

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTap(index),
        splashColor: RC.blue.withValues(alpha: 0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: isSelected
                  ? BoxDecoration(
                      color: RC.blue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
