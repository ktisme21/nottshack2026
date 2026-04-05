import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'company_dashboard.dart';
import 'investor_marketplace.dart';

// ─── Design System ────────────────────────────────────────────────────────────
class _T {
  // Backgrounds
  static const bg         = Color(0xFF070B14);
  static const bgCard     = Color(0xFF0D1525);
  static const bgCardAlt  = Color(0xFF111827);

  // Purple spectrum
  static const purple     = Color(0xFF7C3AED);
  static const purpleLight= Color(0xFF9F67FF);
  static const purpleSoft = Color(0xFF1E1035);
  static const purpleFade = Color(0x207C3AED);

  // Blue spectrum
  static const blue       = Color(0xFF2563EB);
  static const blueLight  = Color(0xFF60A5FA);
  static const blueSoft   = Color(0xFF0D1E3D);
  static const blueFade   = Color(0x202563EB);

  // Neutral
  static const white      = Color(0xFFFFFFFF);
  static const white70    = Color(0xB3FFFFFF);
  static const white40    = Color(0x66FFFFFF);
  static const white10    = Color(0x1AFFFFFF);
  static const border     = Color(0xFF1E2D45);
  static const borderGlow = Color(0x407C3AED);
}

class RoleSelectScreen extends StatefulWidget {
  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: Stack(children: [
        // ── Grid background ─────────────────────────────────────────────────
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),

        // ── Glow orbs ───────────────────────────────────────────────────────
        Positioned(top: -120, left: -80,
          child: AnimatedBuilder(animation: _pulseAnim, builder: (_, __) =>
            Opacity(opacity: _pulseAnim.value * 0.35,
              child: Container(width: 400, height: 400,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _T.purple, Colors.transparent,
                  ])))))),
        Positioned(bottom: -100, right: -60,
          child: AnimatedBuilder(animation: _pulseAnim, builder: (_, __) =>
            Opacity(opacity: (1 - _pulseAnim.value) * 0.3 + 0.2,
              child: Container(width: 350, height: 350,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _T.blue, Colors.transparent,
                  ])))))),

        // ── Content ──────────────────────────────────────────────────────────
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo mark
                  _LogoMark(),
                  const SizedBox(height: 28),

                  // Title
                  Text('CHAINVERIFY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 34, fontWeight: FontWeight.w800,
                      color: _T.white, letterSpacing: 6,
                    )),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 40, height: 1, color: _T.purple),
                    const SizedBox(width: 10),
                    Text('BLOCKCHAIN · ESG · SUPPLY CHAIN',
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 10, color: _T.white40, letterSpacing: 2)),
                    const SizedBox(width: 10),
                    Container(width: 40, height: 1, color: _T.blue),
                  ]),

                  const SizedBox(height: 52),

                  // Status bar
                  _StatusBar(),
                  const SizedBox(height: 36),

                  // Role cards
                  _RoleCard(
                    icon: Icons.domain_rounded,
                    badge: 'ENTERPRISE',
                    title: 'Company Portal',
                    subtitle: 'Submit ESG data · Generate verified reports · Track supply chain',
                    accentColor: _T.purple,
                    accentSoft: _T.purpleSoft,
                    accentFade: _T.purpleFade,
                    tag: '↗ DATA UPLOADER',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CompanyDashboard())),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.candlestick_chart_rounded,
                    badge: 'INVESTOR',
                    title: 'Market Intelligence',
                    subtitle: 'Browse verified reports · Analyse ESG scores · Make decisions',
                    accentColor: _T.blue,
                    accentSoft: _T.blueSoft,
                    accentFade: _T.blueFade,
                    tag: '↗ DATA CONSUMER',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => InvestorMarketplace())),
                  ),

                  const Spacer(),

                  // Footer
                  Text('Secured by Polygon Blockchain · ISO 27001',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 10, color: _T.white40, letterSpacing: 1)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Logo mark ─────────────────────────────────────────────────────────────────
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [_T.purple, _T.blue],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(color: _T.purple.withOpacity(0.4),
              blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _T.white10, width: 1),
          ),
        ),
        const Icon(Icons.hub_rounded, color: _T.white, size: 32),
      ]),
    );
  }
}

// ── Status bar ────────────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _T.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: const BoxDecoration(
                color: Color(0xFF22C55E), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('NETWORK LIVE',
          style: GoogleFonts.sourceCodePro(
              fontSize: 10, color: _T.white70, letterSpacing: 1.5,
              fontWeight: FontWeight.w600)),
        const SizedBox(width: 16),
        Container(width: 1, height: 12, color: _T.border),
        const SizedBox(width: 16),
        Text('POLYGON MAINNET',
          style: GoogleFonts.sourceCodePro(
              fontSize: 10, color: _T.white40, letterSpacing: 1)),
      ]),
    );
  }
}

// ── Role card ─────────────────────────────────────────────────────────────────
class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color accentSoft;
  final Color accentFade;
  final String tag;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon, required this.badge, required this.title,
    required this.subtitle, required this.accentColor, required this.accentSoft,
    required this.accentFade, required this.tag, required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? widget.accentSoft : _T.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? widget.accentColor.withOpacity(0.5) : _T.border,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered ? [
              BoxShadow(color: widget.accentColor.withOpacity(0.2),
                  blurRadius: 24, offset: const Offset(0, 8)),
            ] : [],
          ),
          child: Row(children: [
            // Icon box
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: widget.accentFade,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.accentColor.withOpacity(0.3)),
              ),
              child: Icon(widget.icon, color: widget.accentColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(widget.badge,
                      style: GoogleFonts.sourceCodePro(
                          fontSize: 9, color: widget.accentColor,
                          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ),
                ]),
                const SizedBox(height: 5),
                Text(widget.title,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: _T.white)),
                const SizedBox(height: 3),
                Text(widget.subtitle,
                  style: GoogleFonts.sourceCodePro(
                      fontSize: 10, color: _T.white40, height: 1.5)),
              ],
            )),
            const SizedBox(width: 12),

            // Arrow
            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: widget.accentColor),
              const SizedBox(height: 16),
              Text(widget.tag,
                style: GoogleFonts.sourceCodePro(
                    fontSize: 8, color: _T.white40, letterSpacing: 1)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ── Grid background painter ───────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2D45).withOpacity(0.4)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dot intersections
    final dotPaint = Paint()..color = const Color(0xFF1E2D45);
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}