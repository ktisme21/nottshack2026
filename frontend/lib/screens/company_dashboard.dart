import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../services/wallet_service.dart';

class _T {
  static const bg = Color(0xFF070B14);
  static const bgCard = Color(0xFF0D1525);
  static const bgCardAlt = Color(0xFF111827);
  static const purple = Color(0xFF7C3AED);
  static const purpleFade = Color(0x207C3AED);
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0xFF0D1E3D);
  static const green = Color(0xFF059669);
  static const greenSoft = Color(0xFF022C22);
  static const orange = Color(0xFFD97706);
  static const white = Color(0xFFFFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const border = Color(0xFF1E2D45);
  static const error = Color(0xFFEF4444);
}

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard>
    with TickerProviderStateMixin {
  final FirestoreService _firestore = FirestoreService();
  final WalletService _walletService = WalletService();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool _isConnectingWallet = false;

  String _selectedCompanyId = 'COMP_001';
  final List<Map<String, String>> _companies = const [
    {'id': 'COMP_001', 'name': 'Nestle'},
    {'id': 'COMP_002', 'name': 'Unilever'},
    {'id': 'COMP_003', 'name': 'Tesla'},
  ];

  final _periodController = TextEditingController(text: '2026-04');
  final _supplierNameController = TextEditingController();
  final _supplierEmissionsController = TextEditingController();
  final _supplierCertController = TextEditingController();
  final _mfrEmissionsController = TextEditingController();
  final _mfrEnergyController = TextEditingController();
  final _mfrRenewableController = TextEditingController();
  final _logFuelController = TextEditingController();
  final _logDistanceController = TextEditingController();
  final _logWeightController = TextEditingController();

  String? _submittedReportId;
  String? _txHash;
  String? _dataHash;
  String? _walletAddress;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _periodController.dispose();
    _supplierNameController.dispose();
    _supplierEmissionsController.dispose();
    _supplierCertController.dispose();
    _mfrEmissionsController.dispose();
    _mfrEnergyController.dispose();
    _mfrRenewableController.dispose();
    _logFuelController.dispose();
    _logDistanceController.dispose();
    _logWeightController.dispose();
    super.dispose();
  }

  Future<void> _connectWallet() async {
    setState(() => _isConnectingWallet = true);
    try {
      final session = await _walletService.connectWallet();
      setState(() {
        _walletAddress = session.address;
        _isConnectingWallet = false;
      });
      _snack('Wallet connected: ${session.address.substring(0, 8)}...', ok: true);
    } catch (e) {
      setState(() => _isConnectingWallet = false);
      _snack('Wallet connection failed: $e', ok: false);
    }
  }

  Future<void> _submitESGData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_walletAddress == null) {
      _snack('Connect a wallet before submitting.', ok: false);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final companyName = _companies
          .firstWhere((company) => company['id'] == _selectedCompanyId)['name']!;

      final supplierData = {
        'name': _supplierNameController.text,
        'emissionReduction':
            double.tryParse(_supplierEmissionsController.text) ?? 0,
        'certifications': _supplierCertController.text,
      };
      final manufacturerData = {
        'emissions': double.tryParse(_mfrEmissionsController.text) ?? 0,
        'energyUsage': double.tryParse(_mfrEnergyController.text) ?? 0,
        'renewableEnergy': double.tryParse(_mfrRenewableController.text) ?? 0,
      };
      final logisticsData = {
        'fuelUsage': double.tryParse(_logFuelController.text) ?? 0,
        'distance': double.tryParse(_logDistanceController.text) ?? 0,
        'transportEmissions':
            (double.tryParse(_logWeightController.text) ?? 0) * 2.3,
      };

      final preparedResponse = await ApiService.prepareWalletSubmission(
        companyId: _selectedCompanyId,
        companyName: companyName,
        period: _periodController.text,
        stakeholderWallet: _walletAddress!,
        supplierData: supplierData,
        manufacturerData: manufacturerData,
        logisticsData: logisticsData,
      );

      final preparedSubmission =
          Map<String, dynamic>.from(preparedResponse['preparedSubmission'] as Map);
      final walletResult = await _walletService.submitEsgData(
        contractAddress: preparedSubmission['contractAddress'] as String,
        companyId: preparedSubmission['companyId'] as String,
        actor: preparedSubmission['actor'] as String,
        period: preparedSubmission['period'] as String,
        dataHash: preparedSubmission['dataHash'] as String,
        co2Grams: preparedSubmission['co2Grams'] as int,
      );

      final reportId = await _firestore.submitESGReport(
        companyId: _selectedCompanyId,
        companyName: companyName,
        period: _periodController.text,
        supplierData: supplierData,
        manufacturerData: manufacturerData,
        logisticsData: logisticsData,
        txHash: walletResult.txHash,
        dataHash: preparedSubmission['dataHash'] as String,
        totalCO2:
            ((preparedResponse['breakdown'] as Map)['totalCO2Kg'] as num).toDouble(),
      );

      setState(() {
        _submittedReportId = reportId;
        _txHash = walletResult.txHash;
        _dataHash = preparedSubmission['dataHash'] as String;
        _walletAddress = walletResult.walletAddress;
        _isSubmitting = false;
      });

      _snack(
        'Wallet-signed blockchain submission recorded. ID: ${reportId.substring(0, 12)}...',
        ok: true,
      );

      for (final controller in [
        _supplierNameController,
        _supplierEmissionsController,
        _supplierCertController,
        _mfrEmissionsController,
        _mfrEnergyController,
        _mfrRenewableController,
        _logFuelController,
        _logDistanceController,
        _logWeightController,
      ]) {
        controller.clear();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _snack('Submission failed: $e', ok: false);
    }
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.sourceCodePro(fontSize: 12)),
        backgroundColor: ok ? _T.green : _T.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompanySelector(),
                          const SizedBox(height: 20),
                          _buildWalletCard(),
                          const SizedBox(height: 20),
                          _buildSection(
                            icon: Icons.agriculture_rounded,
                            label: 'SUPPLIER',
                            title: 'Supplier ESG Data',
                            color: _T.green,
                            fields: [
                              _buildField(
                                _supplierNameController,
                                'Supplier Name',
                                Icons.storefront_rounded,
                              ),
                              _buildField(
                                _supplierEmissionsController,
                                'Carbon Sequestration (kg CO2)',
                                Icons.eco_rounded,
                                isNumber: true,
                              ),
                              _buildField(
                                _supplierCertController,
                                'Certifications (e.g. RSPO, Fair Trade)',
                                Icons.verified_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            icon: Icons.precision_manufacturing_rounded,
                            label: 'MANUFACTURER',
                            title: 'Production Data',
                            color: _T.orange,
                            fields: [
                              _buildField(
                                _mfrEmissionsController,
                                'CO2 Emissions (kg)',
                                Icons.factory_rounded,
                                isNumber: true,
                              ),
                              _buildField(
                                _mfrEnergyController,
                                'Energy Usage (kWh)',
                                Icons.bolt_rounded,
                                isNumber: true,
                              ),
                              _buildField(
                                _mfrRenewableController,
                                'Renewable Energy %',
                                Icons.solar_power_rounded,
                                isNumber: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            icon: Icons.local_shipping_rounded,
                            label: 'LOGISTICS',
                            title: 'Transport Data',
                            color: _T.purple,
                            fields: [
                              _buildField(
                                _logFuelController,
                                'Fuel Usage (litres)',
                                Icons.local_gas_station_rounded,
                                isNumber: true,
                              ),
                              _buildField(
                                _logDistanceController,
                                'Distance (km)',
                                Icons.route_rounded,
                                isNumber: true,
                              ),
                              _buildField(
                                _logWeightController,
                                'Transport Emissions (kg CO2)',
                                Icons.co2_rounded,
                                isNumber: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          _buildSubmitButton(),
                          if (_submittedReportId != null) ...[
                            const SizedBox(height: 16),
                            _buildSuccessCard(),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _T.bgCard,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _T.border)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _T.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _T.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _T.white,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _T.purpleFade,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _T.purple.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.upload_rounded, color: _T.purple, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPANY PORTAL',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _T.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'ESG DATA SUBMISSION',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 9,
                      color: _T.white40,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const _LiveBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTITY SELECTION',
            style: GoogleFonts.sourceCodePro(
              fontSize: 10,
              color: _T.white40,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCompanyId,
                  dropdownColor: _T.bgCardAlt,
                  style: GoogleFonts.spaceGrotesk(
                    color: _T.white,
                    fontSize: 14,
                  ),
                  decoration: _inputDecoration('Company', Icons.domain_rounded),
                  items: _companies
                      .map(
                        (company) => DropdownMenuItem(
                          value: company['id'],
                          child: Text(
                            company['name']!,
                            style: GoogleFonts.spaceGrotesk(color: _T.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCompanyId = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _periodController,
                  style: GoogleFonts.sourceCodePro(color: _T.white, fontSize: 13),
                  decoration: _inputDecoration(
                    'Reporting Period',
                    Icons.calendar_today_rounded,
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WALLET AUTH',
            style: GoogleFonts.sourceCodePro(
              fontSize: 10,
              color: _T.white40,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _walletAddress == null
                      ? 'Connect MetaMask. This wallet will sign the ESG submission.'
                      : 'Connected wallet: $_walletAddress',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 12,
                    color: _walletAddress == null ? _T.white40 : _T.white70,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isConnectingWallet ? null : _connectWallet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _walletAddress == null ? _T.blueSoft : _T.greenSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _walletAddress == null ? _T.blue : _T.green,
                    ),
                  ),
                  child: _isConnectingWallet
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _T.white,
                          ),
                        )
                      : Text(
                          _walletAddress == null ? 'CONNECT WALLET' : 'RECONNECT',
                          style: GoogleFonts.spaceGrotesk(
                            color: _T.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String label,
    required String title,
    required Color color,
    required List<Widget> fields,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: const Border(bottom: BorderSide(color: _T.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: color, size: 15),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 9,
                        color: color.withValues(alpha: 0.8),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _T.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: fields
                  .map(
                    (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: field,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: GoogleFonts.sourceCodePro(color: _T.white, fontSize: 13),
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.sourceCodePro(color: _T.white40, fontSize: 12),
      prefixIcon: Icon(icon, color: _T.white40, size: 18),
      filled: true,
      fillColor: _T.white10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.purple, width: 1.5),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitESGData,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: _isSubmitting
              ? null
              : const LinearGradient(
                  colors: [_T.purple, _T.blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isSubmitting ? _T.bgCard : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isSubmitting ? _T.border : _T.purple.withValues(alpha: 0.4),
          ),
          boxShadow: _isSubmitting
              ? []
              : [
                  BoxShadow(
                    color: _T.purple.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _isSubmitting
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _T.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AWAITING WALLET SIGNATURE...',
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 11,
                        color: _T.white40,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link_rounded, color: _T.white, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'SUBMIT WITH WALLET',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _T.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.greenSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _T.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'COMMITTED SUCCESSFULLY',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 10,
                  color: _T.green,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _codeRow('REPORT_ID', _submittedReportId!),
          _codeRow('TX_HASH', _txHash ?? 'pending'),
          _codeRow('DATA_HASH', _dataHash ?? 'pending'),
          _codeRow('WALLET', _walletAddress ?? 'not connected'),
          _codeRow('NETWORK', 'HARDHAT_LOCAL'),
          const SizedBox(height: 10),
          Text(
            'Backend prepares the ESG hash and authorizes the stakeholder wallet. MetaMask signs the final submission transaction directly from the stakeholder wallet.',
            style: GoogleFonts.sourceCodePro(
              fontSize: 10,
              color: _T.white40,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$key: ',
            style: GoogleFonts.sourceCodePro(fontSize: 11, color: _T.white40),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.sourceCodePro(fontSize: 11, color: _T.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _T.greenSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _T.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: GoogleFonts.sourceCodePro(
              fontSize: 9,
              color: const Color(0xFF22C55E),
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2D45).withValues(alpha: 0.25)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
