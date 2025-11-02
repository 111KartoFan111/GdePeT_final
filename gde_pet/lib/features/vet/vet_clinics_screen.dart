import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/vet_clinic_model.dart';
import '../../services/vet_clinic_service.dart';

class VetClinicsScreen extends StatefulWidget {
  const VetClinicsScreen({super.key});

  @override
  State<VetClinicsScreen> createState() => _VetClinicsScreenState();
}

class _VetClinicsScreenState extends State<VetClinicsScreen> {
  LatLng? _currentLocation;
  bool _isLoadingLocation = true; // ИЗМЕНЕНИЕ: Начинаем с загрузки
  List<VetClinic> _clinics = [];
  bool _showMapView = false;
  final MapController _mapController = MapController();

  // ИЗМЕНЕНИЕ: Добавили Future для FutureBuilder
  Future<List<VetClinic>>? _clinicsFuture;
  final VetClinicService _vetService = VetClinicService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ИЗМЕНЕНИЕ: Удалили _loadClinics()

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Необходимо разрешение на использование геолокации';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Разрешение на использование геолокации отклонено навсегда';
      }

      final position = await Geolocator.getCurrentPosition();
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        // Запускаем загрузку клиник ПОСЛЕ получения геолокации
        _clinicsFuture = _vetService.fetchVetClinics(_currentLocation!);
      });

    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        // Если не удалось получить геолокацию, 
        // все равно запускаем поиск (API использует IP, если нет координат)
        // или используем координаты по умолчанию (Астана)
        _currentLocation = LatLng(51.169392, 71.449074); // Центр Астаны
        _clinicsFuture = _vetService.fetchVetClinics(_currentLocation!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
              content: Text('Ошибка геолокации: $e. Показываем клиники для Астаны.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  // ... (методы _makePhoneCall, _openWhatsApp, _openWebsite, _openInMaps остаются без изменений) ...
  Future<void> _makePhoneCall(String phone) async {
    // Google Places API возвращает телефон в формате "+7 7172 12 34 56"
    // URL launcher ожидает "tel:+77172123456"
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'[\s-]'), '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text('Не удалось совершить звонок'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Убираем + и пробелы
    final simplePhone = phone.replaceAll(RegExp(r'[\s+]'), '');
    final message = 'Здравствуйте! Я обращаюсь через приложение GdePet. Мне нужна консультация.';
    final uri = Uri.parse("https://wa.me/$simplePhone?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text('WhatsApp недоступен'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text('Не удалось открыть сайт'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openInMaps(VetClinic clinic) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${clinic.location.latitude},${clinic.location.longitude}&query_place_id=${clinic.placeId}'
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text('Не удалось открыть карты'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ... (appBar без изменений) ...
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ветеринарные клиники',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showMapView ? Icons.list : Icons.map,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _showMapView = !_showMapView;
              });
            },
          ),
        ],
      ),
      // ИЗМЕНЕНИЕ: Основной контент теперь управляется FutureBuilder
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEE8A9A),
        onPressed: _getCurrentLocation, // Вызывает обновление местоположения
        tooltip: 'Мое местоположение',
        child: _isLoadingLocation
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Сначала ждем геолокацию
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFEE8A9A)),
            SizedBox(height: 16),
            Text('Определение вашего местоположения...'),
          ],
        ),
      );
    }

    // 2. Геолокация получена, ждем загрузку клиник
    return FutureBuilder<List<VetClinic>>(
      future: _clinicsFuture,
      builder: (context, snapshot) {
        // 2.1. Загрузка...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFFEE8A9A)),
                SizedBox(height: 16),
                Text('Загрузка клиник поблизости...'),
              ],
            ),
          );
        }

        // 2.2. Ошибка
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Ошибка загрузки клиник:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // 2.3. Данных нет (например, "ZERO_RESULTS" от Google)
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Рядом не найдено ветеринарных клиник.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        // 2.4. Успех! Сохраняем данные и отображаем
        _clinics = snapshot.data!;
        
        return _showMapView ? _buildMapView() : _buildListView();
      },
    );
  }


  Widget _buildListView() {
    // _clinics уже заполнена FutureBuilder'ом
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clinics.length,
      itemBuilder: (context, index) {
        final clinic = _clinics[index];
        return _buildClinicCard(clinic);
      },
    );
  }

  Widget _buildClinicCard(VetClinic clinic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                if (clinic.isEmergency)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '24/7',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    clinic.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (_currentLocation != null)
                  Text(
                    clinic.getFormattedDistance(_currentLocation!),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEE8A9A),
                    ),
                  ),
              ],
            ),
            // ИЗМЕНЕНИЕ: Убрали clinic.workingHours, т.к. API его не отдает
            if (clinic.rating != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    clinic.rating!.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // ИЗМЕНЕНИЕ: Скрываем кнопки, если данных нет
                if (clinic.phone != null)
                  ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(clinic.phone!),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Позвонить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE8A9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                if (clinic.whatsapp != null) // (скорее всего будет null)
                  ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(clinic.whatsapp!),
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _openInMaps(clinic),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Маршрут'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEE8A9A),
                    side: const BorderSide(color: Color(0xFFEE8A9A)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                if (clinic.website != null) // (скорее всего будет null)
                  OutlinedButton.icon(
                    onPressed: () => _openWebsite(clinic.website!),
                    icon: const Icon(Icons.language, size: 18),
                    label: const Text('Сайт'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEE8A9A),
                      side: const BorderSide(color: Color(0xFFEE8A9A)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    final center = _currentLocation ?? LatLng(51.169392, 71.449074);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.zharkynismagulov.gdePet',
        ),
        MarkerLayer(
          markers: [
            // Маркер текущей позиции пользователя
            if (_currentLocation != null)
              Marker(
                point: _currentLocation!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            // Маркеры клиник
            ..._clinics.map((clinic) {
              return Marker(
                point: clinic.location,
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinic.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(clinic.address),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (clinic.phone != null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _makePhoneCall(clinic.phone!);
                                      },
                                      icon: const Icon(Icons.phone),
                                      label: const Text('Позвонить'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEE8A9A),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _openInMaps(clinic);
                                    },
                                    icon: const Icon(Icons.directions),
                                    label: const Text('Маршрут'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEE8A9A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.local_hospital,
                    color: clinic.isEmergency ? Colors.red : const Color(0xFFEE8A9A),
                    size: 40,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}