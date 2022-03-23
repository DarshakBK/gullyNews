import 'dart:convert';

Token tokenFromJson(String str) => Token.fromJson(json.decode(str));

String tokenToJson(Token data) => json.encode(data.toJson());

class Token {
  Token({
    required this.authToken,
  });

  final String authToken;

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    authToken: json["auth_token"],
  );

  Map<String, dynamic> toJson() => {
    "auth_token": authToken,
  };
}

Token token = Token(authToken: '');