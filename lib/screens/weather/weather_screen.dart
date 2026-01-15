import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/weather_model.dart';
import '../../services/weather_service.dart';
import '../../utils/location_helper.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController cityController = TextEditingController();

  List<WeatherModel> forecast = [];
  bool loading = false;
  String? error;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    /// 📍 Auto-load current location weather
    loadCurrentLocationWeather();
  }

  @override
  void dispose() {
    _controller.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> searchWeather() async {
    final city = cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await WeatherService.getWeatherByCity(city);
      setState(() {
        forecast = data;
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = "City not found";
      });
    }
  }

  Future<void> loadCurrentLocationWeather() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final position = await LocationHelper.getCurrentPosition();

      final data = await WeatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        forecast = data;
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
        error = "Unable to fetch location weather";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: cityController,
                        decoration: InputDecoration(
                          hintText: "Enter city name",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: searchWeather,
                          ),
                        ),
                        onSubmitted: (_) => searchWeather(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loadCurrentLocationWeather,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use Current Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (loading)
                      const CircularProgressIndicator(color: Colors.white),
                    if (error != null)
                      Column(
                        children: [
                          Text(
                            error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: loadCurrentLocationWeather,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    if (forecast.isNotEmpty) buildWeatherUI(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildWeatherUI() {
    final today = forecast.first;

    return Expanded(
      child: ListView(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    today.city,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.network(
                    "https://openweathermap.org/img/wn/${today.icon}@4x.png",
                    height: 120,
                  ),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: today.temperature),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, _) {
                      return Text(
                        "${value.toStringAsFixed(1)} °C",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  Text(
                    today.description.toUpperCase(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "7-Day Forecast",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          ...forecast.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + index * 100),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Image.network(
                    "https://openweathermap.org/img/wn/${day.icon}@2x.png",
                  ),
                  title: Text(
                    DateFormat('EEEE').format(day.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    "${day.temperature.toStringAsFixed(1)} °C",
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
