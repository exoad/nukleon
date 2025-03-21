import 'package:nukleon/nukleon.dart';

/// File system utility as well as for the [AssetManifest] and [AssetBundle] APIs.
///
/// To use, please make sure this is initialized. If you are using [Engine.initializeEngine],
/// there is no need to call [initialize] again.
final class Argus {
  Argus._();

  static late final AssetManifest _assetManifest;

  /// Must be called before using [Argus]
  static Future<void> initialize([AssetBundle? bundle]) async {
    _assetManifest = await AssetManifest.loadFromAssetBundle(bundle ?? rootBundle);
  }

  /// Checks if [asset] is present inside of [invariantAssets]. Basically checks
  /// if [asset] is a valid asset.
  static bool isValidAsset(String asset) {
    return invariantAssets.contains(asset);
  }

  /// See [AssetManifest.listAssets]
  static List<String> get invariantAssets => _assetManifest.listAssets();
}
