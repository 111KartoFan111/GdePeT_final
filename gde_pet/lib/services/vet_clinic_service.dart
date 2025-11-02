import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/vet_clinic_model.dart';

class VetClinicService {
  
  // --- ИЗМЕНЕНИЕ: Вставьте свой API ключ сюда ---
  static const String _apiKey = "AIzaSyDDkgc4n89MHw1s4C22PgiacKdBDfUrvFM"; 
  // -------------------------------------------

  final String _nearbySearchUrl = 
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  /// ИЗМЕНЕНИЕ: Новый метод для загрузки клиник из API
  Future<List<VetClinic>> fetchVetClinics(LatLng userLocation) async {
    // Формируем URL запроса
    final String url = 
        '$_nearbySearchUrl?location=${userLocation.latitude},${userLocation.longitude}'
        '&radius=10000' // Ищем в радиусе 10 км
        '&type=veterinary_care'
        '&keyword=ветклиника|ветеринарная'
        '&language=ru'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final List results = data['results'];
          List<VetClinic> clinics = results
              .map((place) => VetClinic.fromGooglePlaces(place))
              .toList();
              
          // Сортируем по расстоянию
          clinics.sort((a, b) => 
            a.getDistanceFrom(userLocation).compareTo(b.getDistanceFrom(userLocation))
          );
          
          return clinics;
        } else {
          // Обработка ошибок API (например, REQUEST_DENIED, ZERO_RESULTS)
          print('Google Places API Error: ${data['status']}');
          throw 'Ошибка Google API: ${data['error_message'] ?? data['status']}';
        }
      } else {
        // Ошибка HTTP
        throw 'Ошибка сети: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Не удалось загрузить клиники: $e';
    }
  }

}