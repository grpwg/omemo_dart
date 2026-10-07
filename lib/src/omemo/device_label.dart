import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:omemo_dart/src/keys.dart';
import 'package:omemo_dart/src/x3dh/x3dh.dart';

/// XEP-0384 0.9.1 signed device label helpers.
///
/// Wire shape (atalk `OmemoDeviceElement` / XEP):
/// ```xml
/// <device id='…' label='Phone' labelsig='base64…'/>
/// ```
///
/// If `label` is set, `labelsig` MUST be `base64(Sig(IK, utf8(label)))` using
/// the device identity key. Recipients MUST ignore `label` when `labelsig` is
/// missing or fails verification.

/// Sign [label] with Ed25519 identity keypair [identityKeyPair].
///
/// Returns raw signature bytes (caller base64-encodes for the `labelsig`
/// attribute).
Future<List<int>> signDeviceLabel(
  OmemoKeyPair identityKeyPair,
  String label,
) async {
  return sig(identityKeyPair, utf8.encode(label));
}

/// Verify [label] against [labelSig] using the device's Ed25519 [identityPublicKey].
///
/// Returns `true` only when the signature is valid. Per XEP-0384 0.9.1, a
/// missing/invalid signature means the label MUST be ignored (treat as
/// unlabeled).
Future<bool> verifyDeviceLabel({
  required OmemoPublicKey identityPublicKey,
  required String label,
  required List<int> labelSig,
}) async {
  if (identityPublicKey.type != KeyPairType.ed25519) {
    return false;
  }
  if (label.isEmpty || labelSig.isEmpty) {
    return false;
  }
  try {
    return Ed25519().verify(
      utf8.encode(label),
      signature: Signature(
        labelSig,
        publicKey: identityPublicKey.asPublicKey(),
      ),
    );
  } catch (_) {
    return false;
  }
}

/// Convenience: return [label] if [labelSig] verifies, otherwise `null`.
Future<String?> acceptedDeviceLabel({
  required OmemoPublicKey identityPublicKey,
  required String? label,
  required List<int>? labelSig,
}) async {
  if (label == null || labelSig == null) return null;
  final ok = await verifyDeviceLabel(
    identityPublicKey: identityPublicKey,
    label: label,
    labelSig: labelSig,
  );
  return ok ? label : null;
}
