# omemo_dart

[![status-badge](https://ci.polynom.me/api/badges/16/status.svg)](https://ci.polynom.me/repos/16)

`omemo_dart` is a Dart library to help developers of Dart/Flutter XMPP clients to implement
[OMEMO](https://xmpp.org/extensions/xep-0384.html).

It ships **two** independent stacks:

| Stack | Entry | Protocol | Use |
|-------|-------|----------|-----|
| Classic | `package:omemo_dart/omemo_dart.dart` | XEP-0384 **0.9.1** (crypto same as 0.8.3: AES-256-CBC+HMAC, OMEMO protobufs) | PQ / B-track base Double Ratchet; optional `urn:xmpp:omemo:2` |
| Axolotl | `package:omemo_dart/omemo_dart_axolotl.dart` | XEP-0384 **0.3.0** / Conversations (`eu.siacs.conversations.axolotl`, AES-128-GCM, libsignal) | Interop with Conversations and other legacy clients |

The classic stack provides [X3DH](https://signal.org/docs/specifications/x3dh/), the
[Double Ratchet](https://signal.org/docs/specifications/doubleratchet/) with OMEMO
`ENCRYPT` / `DECRYPT` / `KDF_*`, device `label`/`labelsig` helpers (0.9.1), and a high-level
`OmemoManager`.

This library has no dependency on any XMPP library. Callers transform the intermediary
key/payload format to their stanza XML themselves.

## Important Notes

- **Please note that this library has not been audited for its security! Use at your own risk!**
- This library is not tested with other implementations of OMEMO 0.9.1 as I do not know of any client implementing spec compliant OMEMO 0.9.1. It does, however, work with itself.
- The axolotl stack targets Conversations wire compatibility.

## Usage

Include `omemo_dart` in your `pubspec.yaml` like this:

```yaml
# [...]

dependencies:
  omemo_dart:
    hosted: https://git.polynom.me/api/packages/PapaTutuWawa/pub
    version: ^0.5.0
  # [...]

# [...]
```

### Example

This repository includes a documented ["example"](./example/omemo_dart_example.dart) that explains the basic usage of the library while
leaving out the XMPP specific bits. For a more functional and integrated example, see the `omemo_client.dart` example from
[moxxmpp](https://codeberg.org/moxxy/moxxmpp).

### Persistence

By default, `omemo_dart` uses in-memory implementations for everything. For a real-world application, this is unsuitable as OMEMO devices would be constantly added.
In order to allow persistence, your application needs to keep track of the following:

- The `OmemoDevice` assigned to the `OmemoManager`
- `JID -> [int]`: The device list for each JID
- `(JID, device) -> Ratchet`: The actual ratchet

If you also use the `BlindTrustBeforeVerificationTrustManager`, you additionally need to keep track of:

- `(JID, device) -> (int, bool)`: The trust level and the enablement state

## Contributing

When submitting a PR, please run the linter using `dart analyze` and make sure that all
tests still pass using `dart test`.

To ensure uniform commit message formatting, please also use `gitlint` to lint your commit
messages' formatting.

## License

Licensed under the MIT license.

See `LICENSE`.

## Support

If you like what I do and you want to support me, feel free to donate to me on Ko-Fi.

[<img src="https://codeberg.org/moxxy/moxxyv2/raw/branch/master/assets/repo/kofi.png" height="36" style="height: 36px; border: 0px;"></img>](https://ko-fi.com/papatutuwawa)
