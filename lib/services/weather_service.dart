import '../core/dio_service.dart';
import '../model/weather_model.dart';

class WeatherService {
  static const String apiKey = "4da86d71a3740db181c0e86f4d73394d";

  static Future<List<WeatherModel>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    try {
      final response = await DioService.dio.get(
        "forecast",
        queryParameters: {
          "lat": lat,
          "lon": lon,
          "appid": apiKey,
          "units": "metric",
        },
      );

      final List list = response.data['list'];
      final String cityName = response.data['city']['name'];

      final dailyForecast = list.where(
        (item) => item['dt_txt'].contains("12:00:00"),
      );

      return dailyForecast
          .map((e) => WeatherModel.fromJson(e, cityName))
          .toList();
    } catch (e) {
      throw Exception("Unable to fetch weather by location");
    }
  }

  static Future<List<WeatherModel>> getWeatherByCity(String city) async {
    try {
      final response = await DioService.dio.get(
        "forecast",
        queryParameters: {
          "q": city,
          "appid": apiKey,
          "units": "metric",
        },
      );

      final List list = response.data['list'];
      final String cityName = response.data['city']['name'];

      final dailyForecast = list.where(
        (item) => item['dt_txt'].contains("12:00:00"),
      );

      return dailyForecast
          .map((e) => WeatherModel.fromJson(e, cityName))
          .toList();
    } catch (e) {
      throw Exception("Unable to fetch weather by city");
    }
  }
}
