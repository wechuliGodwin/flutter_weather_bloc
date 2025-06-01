part of 'weather_bloc_bloc.dart';

sealed class WeatherBlocEvent extends Equatable {
  const WeatherBlocEvent();

  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherBlocEvent {
  final Position position;

  const FetchWeather(this.position);

  @override
  List<Object> get props => [position];
}
// NEW EVENT: Add this to handle location fetch errors
class LocationError extends WeatherBlocEvent {
  final String message;
  const LocationError(this.message);

  @override
  List<Object> get props => [message];
}
