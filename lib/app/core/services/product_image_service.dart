import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ProductImageResult {
  const ProductImageResult._({
    required this.success,
    required this.cancelled,
    required this.imageBase64,
    required this.mimeType,
    required this.fileName,
    required this.originalSizeBytes,
    required this.storedSizeBytes,
    required this.width,
    required this.height,
    this.errorMessage,
  });

  const ProductImageResult.cancelled()
      : this._(
          success: false,
          cancelled: true,
          imageBase64: '',
          mimeType: '',
          fileName: '',
          originalSizeBytes: 0,
          storedSizeBytes: 0,
          width: 0,
          height: 0,
        );

  factory ProductImageResult.failure(String message) => ProductImageResult._(
        success: false,
        cancelled: false,
        imageBase64: '',
        mimeType: '',
        fileName: '',
        originalSizeBytes: 0,
        storedSizeBytes: 0,
        width: 0,
        height: 0,
        errorMessage: message,
      );

  factory ProductImageResult.value({
    required Uint8List bytes,
    required String fileName,
    required int originalSizeBytes,
    required int width,
    required int height,
  }) =>
      ProductImageResult._(
        success: true,
        cancelled: false,
        imageBase64: base64Encode(bytes),
        mimeType: 'image/jpeg',
        fileName: fileName,
        originalSizeBytes: originalSizeBytes,
        storedSizeBytes: bytes.length,
        width: width,
        height: height,
      );

  final bool success;
  final bool cancelled;
  final String imageBase64;
  final String mimeType;
  final String fileName;
  final int originalSizeBytes;
  final int storedSizeBytes;
  final int width;
  final int height;
  final String? errorMessage;
}

class ProductImageService {
  ProductImageService({
    ImagePicker? picker,
    Future<XFile?> Function()? pickFileOverride,
  })  : _picker = picker ?? ImagePicker(),
        _pickFileOverride = pickFileOverride;

  static const maxOriginalSizeBytes = 5 * 1024 * 1024;
  static const maxStoredSizeBytes = 500 * 1024;
  static const maxDimension = 800;

  final ImagePicker _picker;
  final Future<XFile?> Function()? _pickFileOverride;

  Future<ProductImageResult> pickFromGallery() async {
    try {
      final file = _pickFileOverride == null
          ? await _picker.pickImage(
              source: ImageSource.gallery,
              requestFullMetadata: false,
            )
          : await _pickFileOverride();
      if (file == null) return const ProductImageResult.cancelled();
      final bytes = await file.readAsBytes();
      return processBytes(bytes, fileName: file.name, mimeType: file.mimeType);
    } catch (_) {
      return ProductImageResult.failure(
          'The image could not be opened. Choose a JPEG, PNG, or WebP file.');
    }
  }

  ProductImageResult processBytes(
    Uint8List bytes, {
    required String fileName,
    String? mimeType,
  }) {
    if (bytes.isEmpty) {
      return ProductImageResult.failure('The selected image is empty.');
    }
    if (bytes.length > maxOriginalSizeBytes) {
      return ProductImageResult.failure(
          'The original image exceeds the 5 MB limit.');
    }
    final detected = _detectMimeType(bytes);
    if (detected == null || !_isAllowedMime(detected)) {
      return ProductImageResult.failure(
          'Unsupported format. Choose a JPEG, PNG, or WebP image.');
    }
    if (mimeType != null &&
        mimeType.isNotEmpty &&
        !_isAllowedMime(mimeType.toLowerCase())) {
      return ProductImageResult.failure(
          'Unsupported format. Choose a JPEG, PNG, or WebP image.');
    }

    try {
      final sourceImage = img.decodeImage(bytes);
      if (sourceImage == null) {
        return ProductImageResult.failure(
            'The selected image is corrupt or cannot be decoded.');
      }
      var decoded = sourceImage;
      decoded = img.bakeOrientation(decoded);
      decoded = _resizeToLimit(decoded, maxDimension);

      Uint8List encoded = img.encodeJpg(decoded, quality: 84);
      var quality = 78;
      while (encoded.length > maxStoredSizeBytes && quality >= 42) {
        encoded = img.encodeJpg(decoded, quality: quality);
        quality -= 6;
      }
      while (encoded.length > maxStoredSizeBytes &&
          decoded.width > 240 &&
          decoded.height > 240) {
        decoded = img.copyResize(
          decoded,
          width: (decoded.width * .82).round(),
          height: (decoded.height * .82).round(),
          interpolation: img.Interpolation.average,
        );
        encoded = img.encodeJpg(decoded, quality: 72);
      }
      if (encoded.length > maxStoredSizeBytes) {
        return ProductImageResult.failure(
            'The image remains too large after optimization. Choose a simpler image.');
      }
      return ProductImageResult.value(
        bytes: encoded,
        fileName: _normalizedName(fileName),
        originalSizeBytes: bytes.length,
        width: decoded.width,
        height: decoded.height,
      );
    } catch (_) {
      return ProductImageResult.failure(
          'The selected image is corrupt or cannot be decoded.');
    }
  }

  static img.Image _resizeToLimit(img.Image image, int limit) {
    if (image.width <= limit && image.height <= limit) return image;
    if (image.width >= image.height) {
      return img.copyResize(image,
          width: limit, interpolation: img.Interpolation.average);
    }
    return img.copyResize(image,
        height: limit, interpolation: img.Interpolation.average);
  }

  static String? _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }

  static bool _isAllowedMime(String value) => const {
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/webp'
      }.contains(value);

  static String _normalizedName(String value) {
    final base = value.trim().isEmpty ? 'product-image' : value.trim();
    final dot = base.lastIndexOf('.');
    return '${dot > 0 ? base.substring(0, dot) : base}.jpg';
  }
}
