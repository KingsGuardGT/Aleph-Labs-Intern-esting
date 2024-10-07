// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
//
// final corsProxyServiceProvider = Provider<CorsProxyService>((ref) {
//   return CorsProxyService();
// });
//
// class CorsProxyService {
//   final String proxyUrl = "https://cors-anywhere.herokuapp.com/";
//
//   Future<String> getProxiedImageUrl(String originalUrl) async {
//     final proxiedUrl = "$proxyUrl$originalUrl";
//
//     try {
//       // Send a HEAD request to check if the proxied URL is accessible
//       final response = await http.head(Uri.parse(proxiedUrl));
//
//       if (response.statusCode == 200) {
//         // Return the proxied URL if successful
//         return proxiedUrl;
//       } else {
//         throw Exception('Failed to load image through proxy');
//       }
//     } catch (e) {
//       throw Exception('CORS Proxy error: ${e.toString()}');
//     }
//   }
// }
