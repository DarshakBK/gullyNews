import 'dart:convert';

List<StateName> stateFromJson(String str) => List<StateName>.from(json.decode(str).map((x) => StateName.fromJson(x)));

String stateToJson(List<StateName> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StateName {
  final String stateName;

  StateName({
    required this.stateName,
  });

  factory StateName.fromJson(Map<String, dynamic> json) => StateName(
    stateName: json["state_name"],
  );

  Map<String, dynamic> toJson() => {
    "state_name": stateName,
  };
}

List<StateName> states = [];