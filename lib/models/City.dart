import 'dart:convert';

List<CityName> cityFromJson(String str) => List<CityName>.from(json.decode(str).map((x) => CityName.fromJson(x)));

String cityToJson(List<CityName> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CityName {
  final String cityName;

  CityName({
    required this.cityName,
  });

  factory CityName.fromJson(Map<String, dynamic> json) => CityName(
    cityName: json["city_name"],
  );

  Map<String, dynamic> toJson() => {
    "city_name": cityName,
  };
}

List<CityName> cities = [];