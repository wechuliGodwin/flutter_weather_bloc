import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_bloc/bloc/weather_bloc_bloc.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator

class HomeScrean extends StatefulWidget {
  const HomeScrean({super.key});

  @override
  State<HomeScrean> createState() => _HomeScreanState();
}

class _HomeScreanState extends State<HomeScrean> {
  // Add a method to get current position and dispatch event
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // documented in Android's documentation would come in handy).
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();
    // Dispatch the FetchWeather event when the screen initializes
    _getCurrentPosition().then((position) {
      context.read<WeatherBlocBloc>().add(FetchWeather(position));
    }).catchError((e) {
      // Handle the error if location cannot be obtained
      print("Error getting location: $e");
      // Optionally, dispatch a failure state or show a message
      context.read<WeatherBlocBloc>().add(LocationError(e
          .toString())); // You might need a custom event for this, or handle it differently
    });
  }

  Widget getWeatherIcon(int code) {
    String assetPath;
    switch (code) {
      case >= 200 && < 300:
        assetPath = 'assets/11.png'; // Thunderstorm icon
        break;
      case >= 300 && < 400:
        assetPath = 'assets/9.png'; // Drizzle icon
        break;
      case >= 500 && < 600:
        assetPath = 'assets/10.png'; // Rain icon
        break;
      case >= 600 && < 700:
        assetPath = 'assets/13.png'; // Snow icon
        break;
      case >= 700 && < 800:
        assetPath = 'assets/50.png'; // Atmosphere icon (mist, fog, etc.)
        break;
      case 800:
        assetPath = 'assets/1.png'; // Clear sky icon
        break;
      case >= 801 && <= 804:
        assetPath = 'assets/2.png'; // Clouds icon
        break;
      default:
        assetPath = 'assets/2.png'; // Default to clouds if code is unrecognized
        break;
    }

    // Wrap the Image.asset in a SizedBox to control its size
    return SizedBox(
      width:
          250, // Adjust this width to make the icon larger (e.g., 100, 150, 250)
      height: 250, // Adjust this height to make the icon larger
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain, // Ensures the image scales nicely within the box
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          // Added const
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            40, 1.2 * kToolbarHeight, 40, 20), // Changed to EdgeInsets.fromLTRB
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(3, -0.3), // Added const
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    // Added const
                    shape: BoxShape.circle,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-3, 0.3), // Added const
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    // Added const
                    shape: BoxShape.circle,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -1.2), // Added const
                child: Container(
                  height: 300,
                  width: 600,
                  decoration: const BoxDecoration(
                    // Added const
                    color: Color(0xffffab40),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.transparent), // Added const
                ),
              ),
              BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
                builder: (context, state) {
                  if (state is WeatherBlocSuccess) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Null-safe access with fallback
                            '${state.weather.areaName ?? 'Unknown Area'}',
                            style: const TextStyle(
                              // Added const
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(
                            // Added const
                            height: 8,
                          ),
                          const Text(
                            // Added const
                            'Good Morning', // Consider making this dynamic based on time
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Image.asset('assets/cloud.png'),
                          // Pass a default if weatherConditionCode is null
                          getWeatherIcon(
                              state.weather.weatherConditionCode ?? 800),
                          Center(
                            child: Text(
                              // Null-safe access with fallback
                              '${state.weather.temperature?.celsius?.round() ?? '--'}°C',
                              style: const TextStyle(
                                // Added const
                                color: Colors.white,
                                fontSize: 55,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              // Null-safe access with fallback
                              state.weather.weatherMain?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                // Added const
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              // Null-safe access with fallback
                              DateFormat('EEEE dd .').add_jm().format(state
                                      .weather.date ??
                                  DateTime.now()), // Provide fallback for date
                              style: const TextStyle(
                                // Added const
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          const SizedBox(
                            // Added const
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      // Explicitly size the image
                                      width: 80, // Adjust as needed
                                      height: 80, // Adjust as needed
                                      child: Image.asset(
                                        'assets/sunrise.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      // Added const
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            // Added const
                                            'Sunrise',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(
                                            // Added const
                                            height: 3,
                                          ),
                                          Text(
                                            // Null-safe access with fallback
                                            DateFormat().add_jm().format(
                                                state.weather.sunrise ??
                                                    DateTime.now()),
                                            style: const TextStyle(
                                              // Added const
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      // Explicitly size the image
                                      width: 80, // Adjust as needed
                                      height: 80, // Adjust as needed
                                      child: Image.asset(
                                        'assets/sunset.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      // Added const
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            // Added const
                                            'Sunset',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(
                                            // Added const
                                            height: 3,
                                          ),
                                          Text(
                                            // Null-safe access with fallback
                                            DateFormat().add_jm().format(
                                                state.weather.sunset ??
                                                    DateTime.now()),
                                            style: const TextStyle(
                                              // Added const
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0), // Added const
                            child: const Divider(
                              // Added const
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      // Explicitly size the image
                                      width: 80, // Adjust as needed
                                      height: 80, // Adjust as needed
                                      child: Image.asset(
                                        'assets/max_temp.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      // Added const
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            // Added const
                                            'Max Temp',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const SizedBox(
                                            // Added const
                                            height: 3,
                                          ),
                                          Text(
                                            // Null-safe access with fallback
                                            '${state.weather.tempMax?.celsius?.round() ?? '--'}°C',
                                            style: const TextStyle(
                                              // Added const
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      // Explicitly size the image
                                      width: 80, // Adjust as needed
                                      height: 80, // Adjust as needed
                                      child: Image.asset(
                                        'assets/min_temp.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(
                                      // Added const
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            // Added const
                                            'Min Temp',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          const SizedBox(
                                            // Added const
                                            height: 3,
                                          ),
                                          Text(
                                            // Null-safe access with fallback
                                            '${state.weather.tempMin?.celsius?.round() ?? '--'}°C',
                                            style: const TextStyle(
                                              // Added const
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else if (state is WeatherBlocLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  } else if (state is WeatherBlocFailure) {
                    return const Center(
                      child: Text(
                        'Failed to load weather data.\nPlease check your API key, network, or location permissions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }
                  // This handles WeatherBlocInitial or any unexpected state
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
