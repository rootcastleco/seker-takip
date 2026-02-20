import 'dart:ui';
import 'package:flutter/material.dart';

/// Rootcastle Glassmorphism Design System.
///
/// Marka renkleri: Blue #0E3D8A, Green #228B55, Black #000000.
/// Tüm cam kartlar BackdropFilter + yarı-saydam gradient kullanır.

// ─── Marka Renkleri ─────────────────────────────────────────
class RC {
  RC._();

  // Primer renkler
  static const Color blue = Color(0xFF0E3D8A);
  static const Color green = Color(0xFF228B55);
  static const Color black = Color(0xFF000000);

  // Gradient renkleri (dark mode)
  static const Color bgDark1 = Color(0xFF050D1A);
  static const Color bgDark2 = Color(0xFF0A1628);
  static const Color bgDark3 = Color(0xFF071230);

  // Gradient renkleri (light mode)
  static const Color bgLight1 = Color(0xFFE8EFF8);
  static const Color bgLight2 = Color(0xFFD0DFEF);
  static const Color bgLight3 = Color(0xFFC2D5E8);

  // Cam efekt renkleri
  static Color glassWhite = Colors.white.withOpacity(0.08);
  static Color glassBorder = Colors.white.withOpacity(0.12);
  static Color glassWhiteLight = Colors.white.withOpacity(0.65);
  static Color glassBorderLight = Colors.white.withOpacity(0.8);

  // Accent
  static const Color accent = Color(0xFF4FC3F7);
  static const Color accentGreen = Color(0xFF66BB6A);
}

// ─── Gradient Background ────────────────────────────────────

/// Animasyonlu tam ekran gradient arka plan
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.isDark,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final colors = widget.isDark
            ? [
                Color.lerp(RC.bgDark1, RC.bgDark3, _animation.value)!,
                RC.bgDark2,
                Color.lerp(RC.bgDark3, RC.bgDark1, _animation.value)!,
              ]
            : [
                Color.lerp(RC.bgLight1, RC.bgLight3, _animation.value)!,
                RC.bgLight2,
                Color.lerp(RC.bgLight3, RC.bgLight1, _animation.value)!,
              ];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Tam ekran gradient arka plan (tüm sayfaların wrapperi).
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: AnimatedGradientBackground(
        isDark: isDark,
        child: body,
      ),
    );
  }
}

// ─── Glass Card ─────────────────────────────────────────────

/// Buzlu cam kart efekti — Glassmorphism ana bileşen.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderRadius = 16.0,
    this.blur = 12.0,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? RC.glassWhite : RC.glassWhiteLight);
    final border =
        borderColor ?? (isDark ? RC.glassBorder : RC.glassBorderLight);

    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Glass AppBar ───────────────────────────────────────────

/// Yarı-saydam cam efektli AppBar.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark
          ? Colors.black.withOpacity(0.4)
          : Colors.white.withOpacity(0.5),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: leading,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                letterSpacing: 0.3,
                color: isDark ? Colors.white : RC.blue,
              ),
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(color: isDark ? Colors.white : RC.blue),
      actions: actions,
    );
  }
}

// ─── Glass Button ───────────────────────────────────────────

/// Cam efektli yükseltilmiş buton.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.color,
    this.fullWidth = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final Color? color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnColor = color ?? RC.blue;

    final btn = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [btnColor, btnColor.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: btnColor.withOpacity(isDark ? 0.4 : 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ─── Glass Input ────────────────────────────────────────────

/// Cam efektli TextFormField dekoratörü.
InputDecoration glassInputDecoration({
  required BuildContext context,
  required String label,
  String? hint,
  String? suffixText,
  Widget? suffixIcon,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffixText,
    suffixIcon: suffixIcon,
    labelStyle: TextStyle(
      color: isDark ? Colors.white70 : RC.blue.withOpacity(0.7),
    ),
    hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
    filled: true,
    fillColor: isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? RC.glassBorder : RC.glassBorderLight,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? RC.glassBorder : Colors.grey.shade300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: RC.blue, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

// ─── Glass ListTile ─────────────────────────────────────────

/// Cam efektli navigasyon tile'ı (dashboard menü öğeleri).
class GlassListTile extends StatelessWidget {
  const GlassListTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ?? (isDark ? RC.accent : RC.blue);

    return GlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: 12,
      blur: 8,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: iconColor.withOpacity(isDark ? 0.15 : 0.1),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : RC.black,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────

/// Bölüm başlığı (kartlar üstü).
class GlassSectionHeader extends StatelessWidget {
  const GlassSectionHeader({super.key, required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isDark ? RC.accent : RC.blue),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : RC.blue.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
