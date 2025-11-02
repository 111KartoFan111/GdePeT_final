import 'package:latlong2/latlong.dart';

class VetClinic {
  final String id;
  // ИЗМЕНЕНИЕ: Добавили placeId для будущих запросов (например, деталей)
  final String? placeId;
  final String name;
  final String address;
  final LatLng location;
  final String? phone;
  final String? website;
  final String? whatsapp;
  final String? workingHours;
  final double? rating;
  final bool isEmergency; // работает круглосуточно

  VetClinic({
    required this.id,
    this.placeId, // ИЗМЕНЕНИЕ
    required this.name,
    required this.address,
    required this.location,
    this.phone,
    this.website,
    this.whatsapp,
    this.workingHours,
    this.rating,
    this.isEmergency = false,
  });

  // ИЗМЕНЕНИЕ: Фабричный конструктор для парсинга ответа от Google Places
  factory VetClinic.fromGooglePlaces(Map<String, dynamic> json) {
    final lat = json['geometry']['location']['lat'];
    final lng = json['geometry']['location']['lng'];
    
    return VetClinic(
      id: json['place_id'], // Используем place_id как уникальный id
      placeId: json['place_id'],
      name: json['name'],
      address: json['vicinity'] ?? 'Адрес не указан',
      location: LatLng(lat, lng),
      rating: (json['rating'] as num?)?.toDouble(),
      isEmergency: json['opening_hours']?['open_now'] ?? false,
    );
  }


  // Расчет расстояния до клиники от текущей позиции
  double getDistanceFrom(LatLng userLocation) {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, userLocation, location);
  }

  String getFormattedDistance(LatLng userLocation) {
    final distanceKm = getDistanceFrom(userLocation);
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} м';
    }
    return '${distanceKm.toStringAsFixed(1)} км';
  }
}