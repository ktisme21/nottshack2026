import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/esg_report.dart';
import 'report_viewer.dart';

class _T {
  static const bg         = Color(0xFF070B14);
  static const bgCard     = Color(0xFF0D1525);
  static const bgCardAlt  = Color(0xFF111827);
  static const purple     = Color(0xFF7C3AED);
  static const purpleLight= Color(0xFF9F67FF);
  static const purpleSoft = Color(0xFF1E1035);
  static const purpleFade = Color(0x207C3AED);
  static const blue       = Color(0xFF2563EB);
  static const blueLight  = Color(0xFF60A5FA);
  static const blueFade   = Color(0x202563EB);
  static const green      = Color(0xFF059669);
  static const greenSoft  = Color(0xFF022C22);
  static const orange     = Color(0xFFD97706);
  static const red        = Color(0xFFEF4444);
  static const redSoft    = Color(0xFF1C0A0A);
  static const white      = Color(0xFFFFFFFF);
  static const white70    = Color(0xB3FFFFFF);
  static const white40    = Color(0x66FFFFFF);
  static const white10    = Color(0x1AFFFFFF);
  static const border     = Color(0xFF1E2D45);
}

class InvestorMarketplace extends StatefulWidget {
  @override
  _InvestorMarketplaceState createState() => _InvestorMarketplaceState();
}

class _InvestorMarketplaceState extends State<InvestorMarketplace>
    with TickerProviderStateMixin {
  final FirestoreService _firestore = FirestoreService();
  final String _investorId = 'investor_demo';

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _purchaseReport(ESGReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => Dialog(
        backgroundColor: _T.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _T.border)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _T.purpleFade,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  color: _T.purple, size: 28),
            ),
            const SizedBox(height: 16),
            Text('CONFIRM PURCHASE',
              style: GoogleFonts.sourceCodePro(
                  fontSize: 11, color: _T.purple,
                  letterSpacing: 2, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('${report.companyName} · ${report.period}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: _T.white),
              textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _T.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AMOUNT',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 10, color: _T.white40, letterSpacing: 2)),
                  Text('\$${report.price.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 22, fontWeight: FontWeight.w800,
                        color: _T.green)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _T.blueFade,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: _T.blueLight),
                const SizedBox(width: 8),
                Expanded(child: Text('Demo mode — no real payment charged',
                  style: GoogleFonts.sourceCodePro(
                      fontSize: 10, color: _T.blueLight))),
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _T.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _T.border),
                  ),
                  child: Center(child: Text('CANCEL',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 11, color: _T.white40,
                        letterSpacing: 2))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_T.purple, _T.blue]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: _T.purple.withOpacity(0.35),
                          blurRadius: 14, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(child: Text(
                    'PAY \$${report.price.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: _T.white))),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );

    if (confirmed == true) {
      await _firestore.purchaseReport(report.id, _investorId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ACCESS GRANTED · ${report.companyName}',
          style: GoogleFonts.sourceCodePro(fontSize: 11, letterSpacing: 1)),
        backgroundColor: _T.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => ReportViewer(reportId: report.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Column(children: [
          _buildHeader(),
          Expanded(child: FadeTransition(
            opacity: _fadeAnim,
            child: StreamBuilder(
              stream: _firestore.getVerifiedReports(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildError('${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(
                      color: _T.purple, strokeWidth: 2));
                }
                final reports = snapshot.data!;
                if (reports.isEmpty) return _buildEmpty();
                return _buildList(reports);
              },
            ),
          )),
        ]),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _T.bgCard,
      child: SafeArea(bottom: false, child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _T.border))),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: _T.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _T.border)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _T.white, size: 14)),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: _T.blueFade,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _T.blue.withOpacity(0.3))),
            child: const Icon(Icons.candlestick_chart_rounded,
                color: _T.blueLight, size: 16),
          ),
          const SizedBox(width: 10),
          Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('MARKET INTELLIGENCE',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: _T.white, letterSpacing: 1)),
            Text('VERIFIED ESG REPORTS',
              style: GoogleFonts.sourceCodePro(
                  fontSize: 9, color: _T.white40, letterSpacing: 2)),
          ]),
          const Spacer(),
          _LiveBadge(),
        ]),
      )),
    );
  }

  Widget _buildList(List<ESGReport> reports) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reports.length,
      itemBuilder: (_, i) => _ReportCard(
        report: reports[i],
        onPurchase: () => _purchaseReport(reports[i]),
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _T.white10, shape: BoxShape.circle),
        child: const Icon(Icons.inbox_rounded, color: _T.white40, size: 36)),
      const SizedBox(height: 16),
      Text('NO REPORTS AVAILABLE',
        style: GoogleFonts.sourceCodePro(
            fontSize: 12, color: _T.white40, letterSpacing: 2)),
      const SizedBox(height: 6),
      Text('Companies must submit ESG data first',
        style: GoogleFonts.spaceGrotesk(
            fontSize: 13, color: _T.white40)),
    ],
  ));

  Widget _buildError(String msg) => Center(child:
    Text('ERROR: $msg',
      style: GoogleFonts.sourceCodePro(color: _T.red, fontSize: 12)));
}

// ── Report card ───────────────────────────────────────────────────────────────
class _ReportCard extends StatefulWidget {
  final ESGReport report;
  final VoidCallback onPurchase;
  const _ReportCard({required this.report, required this.onPurchase});
  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _hovered = false;

  Color get _scoreColor {
    if (widget.report.esgScore >= 80) return const Color(0xFF059669);
    if (widget.report.esgScore >= 60) return const Color(0xFFD97706);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _T.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? _T.purple.withOpacity(0.4)
                : _T.border),
          boxShadow: _hovered ? [
            BoxShadow(color: _T.purple.withOpacity(0.15),
                blurRadius: 20, offset: const Offset(0, 6))
          ] : [],
        ),
        child: Column(children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _T.white10,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(19)),
              border: const Border(
                  bottom: BorderSide(color: _T.border)),
            ),
            child: Row(children: [
              const Icon(Icons.verified_rounded,
                  color: _T.green, size: 14),
              const SizedBox(width: 6),
              Text('BLOCKCHAIN VERIFIED',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: _T.green,
                    letterSpacing: 2, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(df.format(widget.report.createdAt),
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: _T.white40, letterSpacing: 1)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(children: [
                // ESG score bubble
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: _scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _scoreColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text('${widget.report.esgScore}',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: _scoreColor, height: 1)),
                    Text('ESG',
                      style: GoogleFonts.sourceCodePro(
                          fontSize: 8, color: _scoreColor,
                          letterSpacing: 1)),
                  ]),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(widget.report.companyName,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: _T.white)),
                  const SizedBox(height: 4),
                  Row(children: [
                    _dataBadge(Icons.calendar_today_rounded,
                        widget.report.period),
                    const SizedBox(width: 8),
                    _dataBadge(Icons.factory_rounded,
                        '${widget.report.totalEmissions.toStringAsFixed(0)} kg CO₂'),
                  ]),
                ])),
              ]),

              const SizedBox(height: 14),

              // Score bar
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text('ESG SCORE',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 9, color: _T.white40, letterSpacing: 2)),
                  Text('${widget.report.esgScore}/100',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 9, color: _scoreColor, letterSpacing: 1)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.report.esgScore / 100,
                    minHeight: 4,
                    backgroundColor: _T.white10,
                    valueColor: AlwaysStoppedAnimation(_scoreColor),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // Price + buy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('REPORT PRICE',
                    style: GoogleFonts.sourceCodePro(
                        fontSize: 9, color: _T.white40, letterSpacing: 2)),
                  Text('\$${widget.report.price.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 24, fontWeight: FontWeight.w800,
                        color: _T.green)),
                ]),
                GestureDetector(
                  onTap: widget.onPurchase,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_T.purple, _T.blue]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: _T.purple.withOpacity(0.3),
                            blurRadius: 12, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.lock_open_rounded,
                          color: _T.white, size: 15),
                      const SizedBox(width: 8),
                      Text('BUY REPORT',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: _T.white)),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _dataBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _T.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _T.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: _T.white40),
        const SizedBox(width: 4),
        Text(label,
          style: GoogleFonts.sourceCodePro(
              fontSize: 9, color: _T.white40)),
      ]),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF022C22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFF059669).withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
            decoration: const BoxDecoration(
                color: Color(0xFF22C55E), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('LIVE',
          style: GoogleFonts.sourceCodePro(
              fontSize: 9, color: const Color(0xFF22C55E),
              letterSpacing: 2, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1E2D45).withOpacity(0.25)
      ..strokeWidth = 0.5;
    const s = 40.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}