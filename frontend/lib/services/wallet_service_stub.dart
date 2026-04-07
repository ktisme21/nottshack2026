import 'wallet_models.dart';

Future<WalletSession> connectWalletImpl() {
  throw UnsupportedError('Wallet connection is only supported on Flutter web.');
}

Future<WalletSubmissionResult> submitEsgDataImpl({
  required String contractAddress,
  required String companyId,
  required String actor,
  required String period,
  required String dataHash,
  required int co2Grams,
}) {
  throw UnsupportedError('Direct wallet submission is only supported on Flutter web.');
}
