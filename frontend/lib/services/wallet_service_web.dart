// ignore_for_file: avoid_web_libraries_in_flutter

@JS()
library;

import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import 'wallet_models.dart';

@JS('globalThis.esgWallet')
external WalletBridge? get _walletBridge;

extension type WalletBridge(JSObject _) implements JSObject {
  external JSPromise<JSAny?> connectWallet();
  external JSPromise<JSAny?> submitEsgData(JSAny payload);
}

Future<WalletSession> connectWalletImpl() async {
  if (!kIsWeb || _walletBridge == null) {
    throw Exception('Wallet bridge is not available.');
  }

  final result = await _walletBridge!.connectWallet().toDart;
  final map = result.dartify() as Map<dynamic, dynamic>;

  return WalletSession(
    address: map['address'] as String,
    chainId: map['chainId'] as int,
  );
}

Future<WalletSubmissionResult> submitEsgDataImpl({
  required String contractAddress,
  required String companyId,
  required String actor,
  required String period,
  required String dataHash,
  required int co2Grams,
}) async {
  if (!kIsWeb || _walletBridge == null) {
    throw Exception('Wallet bridge is not available.');
  }

  final payload = <String, Object?>{
    'contractAddress': contractAddress,
    'companyId': companyId,
    'actor': actor,
    'period': period,
    'dataHash': dataHash,
    'co2Grams': co2Grams,
  }.jsify() as JSAny;

  final result = await _walletBridge!.submitEsgData(payload).toDart;
  final map = result.dartify() as Map<dynamic, dynamic>;

  return WalletSubmissionResult(
    txHash: map['txHash'] as String,
    walletAddress: map['walletAddress'] as String,
  );
}
