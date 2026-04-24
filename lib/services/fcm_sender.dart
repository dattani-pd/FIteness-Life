import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FCMSender {

  // ✅ 1. Use a Dart Map (No more JSON string errors!)
  static final Map<String, dynamic> _serviceAccount = {
    "type": "service_account",
    "project_id": "fitness-life-7f19b",
    "private_key_id": "f4b0b4f34f4d8f5d01f1d5fe791998713fdfc0c7",

    // 👇 The key works perfectly here because we use a raw string
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDLiUKGF0TnIIf5\nNnbaHb/gsb4Dnaksy7dVCkopUfBW404bw2EOgLtd3iGDovYR934noeKxlWB0RStC\nEjTSpWNLOYZ8rG1di2+2EeGGK7xvc/sn5itEKDAdnIxKG5nc57ns9jpsTBSqFZki\nQSwVS65VDzz6JhlM1PF72Uoo3h34jSwtbjuEemH6j94BzzGHqw9BGyPkD1jhzFGS\nZe3Hj97EpnfGQCIwpNuKjVNtB1GpD/Z7CBG/U02y6xln0qcxzBHZD1RmS/WqIgzi\nG+AtrssDTPNJJZzCE85NEJiRJUSYUbdMN383pyIl12pw7ORs9TnvNT+E8DwWBXPb\nHWfCGyynAgMBAAECggEAAOtkU1SclLgnHj9RYpED+4oY4bsoQEjFUcIaf88lUAcs\n//HSzX8vPhT2CINsK5fk/xQgE0ROInYMrXrOk5HmIm/vvD6YmeNfKOWfo9gs4WYE\nqmEfLMYmj8hBoJBdyTkyfTA1AqWGMztdUYZekB01fA3jo/1gyXQkiSPpze0IGg8i\nAAqyLSkC28Lp3OMUavhfVsMXbNAvWj5d1KkYoJELcBdSAekm//4UIKrBBk1QaXm4\nYB5AmbgBxwrBWhyynekJi1E6SHf1hxkdHhMcMO/5QWkZLkMkpLOew96r7bhdmPlU\nskOGiVic5PTAuNPKxNYwuMkF/jOv8lpwuN/F3ZA6gQKBgQD1q3uoHQNmEUr5UIr1\nQG4BbxZdE2RlWQLSZuMS5WRSHHoRYPP3+csWQ4E0v5BCrBoCSvgaPmWXLjKKcKGG\n9p4GQXNB8ZiWRwu2Sm7xFZ7MIhDV4bfQ7XNZ6yh3KsH5MR2n2TUWdsxj7Bl9wYeg\nuX2XWqgRQ52umjZ45B5hnoPYgQKBgQDUGDpmkP3K4l0erGASu0ilFKhIKeEYl0v+\n3l920CwpyI9hMXcateMdwRD08L0oXl4G2xePRphM7SF1cwqyop68qecmDLuHPD2e\nAsIDAHNjR7MMubk59h7YwMPNzqIjxIZNb/n/QLHF0weDb8T5C0Pj8diJKHZOsv9G\nKkMf6VSxJwKBgE+kXhwr+7QVGxckE0hasM7qMnfOF5f7eTy4ehjgINu1u6Typ2TW\nqA35qGNvTtcub+gaYcAwRkLyiRP0W4kjXittAG56YhslwRhBnSGu/qHy0T5lRHAI\n6oJWB/JJ/ERKtfB6LAmyTaR/H+xy1wM13w84JpAiOXYnLE2YtnizKM8BAoGAGqM8\nWntlVKDffyW5H0EkW49fn0ibO8JsygLVzI9SrKDC2TskMVecwbTo00qVB0fq2UOV\nDuqX4Dl8FUswkcT42Msh+9ZnixGWz4ybH1NkKpjrtPJygAQYVbLIJMYJ+SIKmBkz\nNcrDSQw7Clf0Ti8LBMrwHjHVwgabJw3RxmVAvMsCgYAVW5c3/UezrKRUc4A9P7Jp\nWnJlsZUVJVTwuvic+gbRVQlgv/cvZe95U2cXZoILQAlr/ZPgNBCNOEEzOgEhag9e\niIsThZVDj7ZJWkZ+nhr6FEVMcBLv3GaTR2kMXS3PErMrgpA1casEQOKqmaM4l2Js\nXclMyhEylSjyFHrUJuO/2g==\n-----END PRIVATE KEY-----\n",

    "client_email": "firebase-adminsdk-fbsvc@fitness-life-7f19b.iam.gserviceaccount.com",
    "client_id": "101532264435218569408",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40fitness-life-7f19b.iam.gserviceaccount.com"
  };

  static Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    try {
      // 2. Read directly from the Map (No jsonDecode needed!)
      final String projectId = _serviceAccount['project_id'];

      // 3. Authenticate using the Map
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(_serviceAccount);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);

      // 4. Send the message
      final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "message": {
            "topic": "all_users",
            "notification": {
              "title": title,
              "body": body,
            },
            "android": {
              "priority": "high",
              "notification": {
                "channel_id": "high_importance_channel",
                "sound": "default"
              }
            },
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "type": "admin_broadcast"
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notification Sent Successfully!");
      } else {
        print("❌ Failed to send: ${response.body}");
        throw Exception("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("❌ Error: $e");
      rethrow;
    }
  }
}