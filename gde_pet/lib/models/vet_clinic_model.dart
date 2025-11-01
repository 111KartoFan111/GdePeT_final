import 'package:latlong2/latlong.dart';

class VetClinic {
  final String id;
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