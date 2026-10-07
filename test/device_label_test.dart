import 'package:cryptography/cryptography.dart';
import 'package:omemo_dart/omemo_dart.dart';
import 'package:test/test.dart';

void main() {
  test('generateRandomOmemoId never returns 0', () {
    for (var i = 0; i < 200; i++) {
      expect(generateRandomOmemoId(), greaterThan(0));
      expect(generateRandomOmemoId(), lessThan(0x7FFFFFFF));
    }
  });

  test('device label signature roundtrip (XEP-0384 0.9.1)', () async {
    final ik = await OmemoKeyPair.generateNewPair(KeyPairType.ed25519);
    const label = 'Phone';
    final sigBytes = await signDeviceLabel(ik, label);
    expect(
      await verifyDeviceLabel(
        identityPublicKey: ik.pk,
        label: label,
        labelSig: sigBytes,
      ),
      isTrue,
    );
    expect(
      await acceptedDeviceLabel(
        identityPublicKey: ik.pk,
        label: label,
        labelSig: sigBytes,
      ),
      label,
    );
  });

  test('invalid labelsig is rejected', () async {
    final ik = await OmemoKeyPair.generateNewPair(KeyPairType.ed25519);
    final other = await OmemoKeyPair.generateNewPair(KeyPairType.ed25519);
    final sigBytes = await signDeviceLabel(ik, 'Phone');
    expect(
      await verifyDeviceLabel(
        identityPublicKey: other.pk,
        label: 'Phone',
        labelSig: sigBytes,
      ),
      isFalse,
    );
    expect(
      await acceptedDeviceLabel(
        identityPublicKey: ik.pk,
        label: 'Phone',
        labelSig: null,
      ),
      isNull,
    );
  });
}
