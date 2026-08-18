import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Penyimpanan objek ke Cloudflare R2 lewat S3 API (AWS Signature V4).
///
/// - Upload: PUT object terotentikasi (Access Key + Secret dari .env)
/// - Hasil upload diakses lewat URL publik bucket (R2.dev) yang disimpan
///   ke Firestore sebagai [Product.imageUrl].
///
/// Implementasi murni Dart (tanpa dart:io) sehingga jalan di Web & mobile.
class R2StorageException implements Exception {
  final String message;
  R2StorageException(this.message);

  @override
  String toString() => message;
}

class R2StorageService {
  R2StorageService._();

  static String get _accountId => dotenv.env['R2_ACCOUNT_ID'] ?? '';
  static String get _accessKeyId => dotenv.env['R2_ACCESS_KEY_ID'] ?? '';
  static String get _secretAccessKey => dotenv.env['R2_SECRET_ACCESS_KEY'] ?? '';
  static String get _bucket => dotenv.env['R2_BUCKET'] ?? 'flokower';
  static String get _publicBaseUrl => dotenv.env['R2_PUBLIC_BASE_URL'] ?? '';

  static String get _endpointHost => '$_accountId.r2.cloudflarestorage.com';
  static String get _endpoint => 'https://$_endpointHost';

  /// Upload foto produk ke R2, kembalikan URL publiknya.
  static Future<String> uploadProductImage(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    if (_accountId.isEmpty || _accessKeyId.isEmpty || _secretAccessKey.isEmpty) {
      throw R2StorageException(
        'R2 belum dikonfigurasi. Isi R2_ACCESS_KEY_ID & R2_SECRET_ACCESS_KEY di file .env',
      );
    }
    if (_publicBaseUrl.isEmpty) {
      throw R2StorageException('R2_PUBLIC_BASE_URL belum diisi di .env');
    }

    final key = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _putObject(key, bytes, contentType);

    final base = _publicBaseUrl.endsWith('/')
        ? _publicBaseUrl.substring(0, _publicBaseUrl.length - 1)
        : _publicBaseUrl;
    return '$base/$key';
  }

  /// PUT object ke R2 dengan AWS Signature Version 4.
  static Future<void> _putObject(String key, Uint8List bytes, String contentType) async {
    final now = DateTime.now().toUtc();
    final amzDate = _amzDate(now); // YYYYMMDDTHHMMSSZ
    final dateStamp = amzDate.substring(0, 8); // YYYYMMDD
    final payloadHash = _hex(sha256.convert(bytes).bytes);

    // Header yang ikut ditandatangani (wajib urut abjad)
    final headersToSign = <String, String>{
      'content-type': contentType,
      'host': _endpointHost,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
    };
    final sortedNames = headersToSign.keys.toList()..sort();
    final canonicalHeaders =
        sortedNames.map((name) => '$name:${headersToSign[name]!.trim()}\n').join();
    final signedHeaders = sortedNames.join(';');

    final canonicalUri = '/$_bucket/$key';
    final canonicalRequest = [
      'PUT',
      canonicalUri,
      '', // tanpa query string
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final scope = '$dateStamp/auto/s3/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      scope,
      _hex(sha256.convert(utf8.encode(canonicalRequest)).bytes),
    ].join('\n');

    // Signing key: HMAC berantai
    final kDate = _hmac(utf8.encode('AWS4$_secretAccessKey'), utf8.encode(dateStamp));
    final kRegion = _hmac(kDate, utf8.encode('auto')); // R2 region = "auto"
    final kService = _hmac(kRegion, utf8.encode('s3'));
    final kSigning = _hmac(kService, utf8.encode('aws4_request'));
    final signature = _hex(_hmac(kSigning, utf8.encode(stringToSign)));

    final authorization =
        'AWS4-HMAC-SHA256 Credential=$_accessKeyId/$scope, SignedHeaders=$signedHeaders, Signature=$signature';

    final http.Response response;
    try {
      response = await http
          .put(
            Uri.parse('$_endpoint$canonicalUri'),
            headers: {
              'Authorization': authorization,
              'Content-Type': contentType,
              'x-amz-date': amzDate,
              'x-amz-content-sha256': payloadHash,
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 60));
    } catch (e) {
      if (e is R2StorageException) rethrow;
      throw R2StorageException('Tidak bisa terhubung ke Cloudflare R2: $e');
    }

    if (response.statusCode != 200) {
      throw R2StorageException(
        'Upload R2 gagal (HTTP ${response.statusCode}): ${response.body}',
      );
    }
  }

  // ─── Helpers ───

  static List<int> _hmac(List<int> key, List<int> data) =>
      Hmac(sha256, key).convert(data).bytes;

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static String _amzDate(DateTime utc) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}'
        'T${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }
}
