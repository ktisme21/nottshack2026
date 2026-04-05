import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';
import '../models/esg_report.dart';
import '../widgets/blockchain_badge.dart';

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
  static const greenLight = Color(0xFF34D399);
  static const orange     = Color(0xFFD97706);
  static const orangeLight= Color(0xFFFBBF24);
  static const red        = Color(0xFFEF4444);
  static const white      = Color(0xFFFFFFFF);
  static const white70    = Color(0xB3FFFFFF);
  static const white40    = Color(0x66FFFFFF);
  static const white10    = Color(0x1AFFFFFF);
  static const border     = Color(0xFF1E2D45);
}

class ReportViewer extends StatelessWidget {
  final String reportId;
  const ReportViewer({required this.reportId});

  Color _scoreColor(int s) {
    if (s >= 80) return _T.green;
    if (s >= 60) return _T.orange;
    return _T.red;
  }

  String _scoreLabel(int s) {
    if (s >= 80) return 'EXCELLENT · LOW RISK';
    if (s >= 60) return 'MODERATE · REVIEW ADVISED';
    return 'HIGH RISK · ACTION REQUIRED';
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    return Scaffold(
      backgroundColor: _T.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Column(children: [
          _buildHeader(context),
          Expanded(child: StreamBuilder(
            stream: fs.streamReport(reportId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(
                    color: _T.purple, strokeWidth: 2));
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text('REPORT NOT FOUND',
                  style: GoogleFonts.sourceCodePro(
                      color: _T.red, fontSize: 12, letterSpacing: 2)));
              }
              return _buildContent(context, snapshot.data!);
            },
          )),
        ]),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                color: _T.greenSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _T.green.withOpacity(0.3))),
            child: const Icon(Icons.article_rounded,
                color: _T.greenLight, size: 16),
          ),
          const SizedBox(width: 10),
          Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('ESG REPORT VIEWER',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: _T.white, letterSpacing: 1)),
            Text('BLOCKCHAIN · VERIFIED · IMMUTABLE',
              style: GoogleFonts.sourceCodePro(
                  fontSize: 9, color: _T.white40, letterSpacing: 2)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _T.greenSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _T.green.withOpacity(0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.verified_rounded,
                  color: _T.greenLight, size: 11),
              const SizedBox(width: 5),
              Text('VERIFIED',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: _T.greenLight,
                    letterSpacing: 2, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      )),
    );
  }

  Widget _buildContent(BuildContext context, ESGReport report) {
    final sc = _scoreColor(report.esgScore);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Company hero ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_T.purple.withOpacity(0.15), _T.blue.withOpacity(0.1)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _T.purple.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_T.purple, _T.blue]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(
                report.companyName.substring(0, 1),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 24, fontWeight: FontWeight.w800,
                    color: _T.white))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(report.companyName,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: _T.white)),
              Text(report.period,
                style: GoogleFonts.sourceCodePro(
                    fontSize: 11, color: _T.white40, letterSpacing: 1)),
            ])),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              const Icon(Icons.verified_rounded,
                  color: _T.green, size: 18),
              const SizedBox(height: 4),
              Text('ON-CHAIN',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 8, color: _T.green, letterSpacing: 2)),
            ]),
          ]),
        ),

        const SizedBox(height: 20),

        // ── Score card ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sc.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: sc.withOpacity(0.1),
                  blurRadius: 20, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(children: [
            Text('OVERALL ESG SCORE',
              style: GoogleFonts.sourceCodePro(
                  fontSize: 10, color: _T.white40,
                  letterSpacing: 3)),
            const SizedBox(height: 12),
            Text('${report.esgScore}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 64, fontWeight: FontWeight.w900,
                  color: sc, height: 1)),
            Text(_scoreLabel(report.esgScore),
              style: GoogleFonts.sourceCodePro(
                  fontSize: 10, color: sc,
                  letterSpacing: 2, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: report.esgScore / 100,
                minHeight: 8,
                backgroundColor: _T.white10,
                valueColor: AlwaysStoppedAnimation(sc),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text('0',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: _T.red)),
              Text('60',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: _T.orange)),
              Text('80',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: _T.green)),
              Text('100',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: _T.green)),
            ]),
          ]),
        ),

        const SizedBox(height: 20),

        // ── Emissions chart ─────────────────────────────────────────────────
        _SectionCard(
          label: 'BREAKDOWN',
          title: 'Carbon Footprint by Source',
          icon: Icons.pie_chart_rounded,
          iconColor: _T.purple,
          child: Column(children: [
            SizedBox(
              height: 180,
              child: PieChart(PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: report.breakdown['supplier']?.toDouble() ?? 0,
                    color: _T.greenLight,
                    title: '',
                    radius: 55,
                  ),
                  PieChartSectionData(
                    value: report.breakdown['manufacturer']?.toDouble() ?? 0,
                    color: _T.orangeLight,
                    title: '',
                    radius: 55,
                  ),
                  PieChartSectionData(
                    value: report.breakdown['logistics']?.toDouble() ?? 0,
                    color: _T.purpleLight,
                    title: '',
                    radius: 55,
                  ),
                ],
              )),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _legend('Supplier',     _T.greenLight),
              _legend('Manufacturer', _T.orangeLight),
              _legend('Logistics',    _T.purpleLight),
            ]),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Key metrics ─────────────────────────────────────────────────────
        _SectionCard(
          label: 'METRICS',
          title: 'Key Data Points',
          icon: Icons.analytics_rounded,
          iconColor: _T.blue,
          child: Column(children: [
            _metricRow('Total Emissions',
                '${report.totalEmissions.toStringAsFixed(0)} kg CO₂e',
                Icons.factory_rounded, _T.orange),
            _metricRow('Report Price',
                '\$${report.price.toStringAsFixed(2)}',
                Icons.attach_money_rounded, _T.green),
            _metricRow('Verification',
                report.isVerified ? 'ON-CHAIN VERIFIED' : 'PENDING',
                Icons.verified_rounded,
                report.isVerified ? _T.green : _T.orange),
            _metricRow('Report ID',
                '${report.id.substring(0, 20)}…',
                Icons.qr_code_rounded, _T.white40),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Blockchain badge ────────────────────────────────────────────────
        BlockchainBadge(
            hash: _txHash ?? report.blockchainHash,
            timestamp: report.createdAt),

        const SizedBox(height: 20),

        // ── Download ────────────────────────────────────────────────────────
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('PDF EXPORT · DEMO MODE',
              style: GoogleFonts.sourceCodePro(
                  fontSize: 11, letterSpacing: 1)),
            backgroundColor: _T.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          )),
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              color: _T.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Icon(Icons.download_rounded,
                  color: _T.white40, size: 18),
              const SizedBox(width: 10),
              Text('DOWNLOAD FULL REPORT (PDF)',
                style: GoogleFonts.sourceCodePro(
                    fontSize: 11, color: _T.white40,
                    letterSpacing: 2)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _legend(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label,
        style: GoogleFonts.sourceCodePro(
            fontSize: 10, color: _T.white40)),
    ],
  );

  Widget _metricRow(String label, String value,
      IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
          style: GoogleFonts.sourceCodePro(
              fontSize: 11, color: _T.white40))),
        Text(value,
          style: GoogleFonts.sourceCodePro(
              fontSize: 11, color: _T.white70,
              fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String label;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.label, required this.title,
    required this.icon, required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19)),
            border: const Border(
                bottom: BorderSide(color: _T.border)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 14)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                style: GoogleFonts.sourceCodePro(
                    fontSize: 9, color: iconColor.withOpacity(0.7),
                    letterSpacing: 2, fontWeight: FontWeight.w600)),
              Text(title,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: _T.white)),
            ]),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(16), child: child),
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