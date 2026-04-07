class WalletSession {
  final String address;
  final int chainId;

  const WalletSession({
    required this.address,
    required this.chainId,
  });
}

class WalletSubmissionResult {
  final String txHash;
  final String walletAddress;

  const WalletSubmissionResult({
    required this.txHash,
    required this.walletAddress,
  });
}
