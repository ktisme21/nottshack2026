import 'wallet_models.dart';
import 'wallet_service_stub.dart'
    if (dart.library.html) 'wallet_service_web.dart';

class WalletService {
  Future<WalletSession> connectWallet() => connectWalletImpl();

  Future<WalletSubmissionResult> submitEsgData({
    required String contractAddress,
    required String companyId,
    required String actor,
    required String period,
    required String dataHash,
    required int co2Grams,
  }) {
    return submitEsgDataImpl(
      contractAddress: contractAddress,
      companyId: companyId,
      actor: actor,
      period: period,
      dataHash: dataHash,
      co2Grams: co2Grams,
    );
  }
}
