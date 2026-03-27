import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:site_management/core/utils/urls.dart';


Future<Map<String, dynamic>?> fetchAppVersion({int? userId}) async {
  try {
    final uri = userId != null
        ? Uri.parse(BaseUrls.getVersion).replace(
            queryParameters: {'user_id': userId.toString()},
          )
        : Uri.parse(BaseUrls.getVersion);
    final response = await http.get(uri);

    // Handle all HTTP status codes
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Return only the data part
    } else if (response.statusCode >= 500) {
      return null; // Soft fail for server errors
    } else if (response.statusCode == 404) {
      return null;
    } else {
      return null;
    }
  } on TimeoutException {
    return null;
  } on SocketException {
    return null;
  } on FormatException {
    return null;
  } catch (e) {
    return null;
  }
}