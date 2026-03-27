import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../utils/token_manager.dart';

// Replace with your actual base URL
class BaseUrls {
  static const String ip = 'https://your-api-base-url.com';
  static const String login = '$ip/api/login/';
  static const String logout = '$ip/api/logout/';
  // Add other endpoints as needed
}

// NavigationService - add navigatorKey to your MaterialApp
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> navigateToLogin() async {
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class TokenService {
  final String baseUrl = BaseUrls.ip;

  Future<http.Response> sendRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    List<http.MultipartFile>? files,
    bool retry = true,
    bool isFormData = false,
  }) async {
    String? accessToken = await TokenManager.getAccessToken();

    Uri url;
    if (endpoint.startsWith('http')) {
      url = Uri.parse(endpoint);
    } else {
      url = Uri.parse(baseUrl + endpoint);
    }

    // Multipart branch
    if (method.toUpperCase() == "MULTIPART") {
      var request = http.MultipartRequest('POST', url);
      body?.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      if (files != null && files.isNotEmpty) {
        request.files.addAll(files);
      }
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 502) _show502ErrorPopup();
      return response;
    }

    // Normal JSON branch
    Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case "POST":
          response = await http.post(url,
              headers: headers, body: jsonEncode(body));
          break;
        case "PUT":
          response =
              await http.put(url, headers: headers, body: jsonEncode(body));
          break;
        case "PATCH":
          response =
              await http.patch(url, headers: headers, body: jsonEncode(body));
          break;
        case "DELETE":
          response = await http.delete(url, headers: headers);
          break;
        default:
          response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 502) _show502ErrorPopup();

      if (response.statusCode == 401 && retry) {
        bool refreshed = await _refreshAccessToken();
        if (refreshed) {
          return sendRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            files: files,
            retry: false,
          );
        } else {
          await TokenManager.clearTokens();
          _navigateToLogin();
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _refreshAccessToken() async {
    String? refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken == null) {
      await TokenManager.clearTokens();
      _navigateToLogin();
      return false;
    }

    final refreshEndpoints = [
      "/token/refresh/",
      "/Auth/refresh/",
      "/refresh-access-token/",
    ];

    for (final endpoint in refreshEndpoints) {
      try {
        var url = Uri.parse(baseUrl + endpoint);
        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"refresh": refreshToken}),
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          String? newAccessToken = data["access"] ??
              data["access_token"] ??
              data["accessToken"];
          if (newAccessToken != null) {
            await TokenManager.saveAccessToken(newAccessToken);
            return true;
          }
        } else if (response.statusCode == 502) {
          _show502ErrorPopup();
          return false;
        }
      } catch (e) {
        continue;
      }
    }

    await TokenManager.clearTokens();
    _navigateToLogin();
    return false;
  }

  void _navigateToLogin() {
    NavigationService.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  bool _is502DialogShowing = false;

  void _show502ErrorPopup() {
    if (_is502DialogShowing) return;
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      _is502DialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.warning, color: Colors.orange, size: 27),
                SizedBox(width: 10),
                Text(
                  "Service Unavailable",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Service is temporarily unavailable. Our team is working to resolve the issue.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 15),
                Text(
                  "Please try again later.",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _is502DialogShowing = false;
                    Navigator.of(context).pop();
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A9D8F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("OK",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 10,
          );
        },
      ).then((_) => _is502DialogShowing = false);
    }
  }
}
