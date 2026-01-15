class WeatherModel {
  final String city;
  final double temperature;
  final String description;
  final String icon;
  final DateTime date;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.date,
  });

  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    String cityName,
  ) {
    return WeatherModel(
      city: cityName,
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      date: DateTime.parse(json['dt_txt']),
    );
  }
}
