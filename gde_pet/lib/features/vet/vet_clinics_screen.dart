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
  bool _isLoadingLocation = false;
  List<VetClinic> _clinics = [];
  bool _showMapView = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadClinics();
    _getCurrentLocation();
  }

  void _loadClinics() {
    setState(() {
      _clinics = VetClinicService.getVetClinics();
    });
  }

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
        // Сортируем клиники по расстоянию
        _clinics = VetClinicService.getSortedByDistance(_currentLocation!);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text('Ошибка определения местоположения: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:+$phone');
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
    final message = 'Здравствуйте! Я обращаюсь через приложение GdePet. Мне нужна консультация.';
    final uri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
    
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
            margin: EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text('Не удалось открыть сайт'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openInMaps(VetClinic clinic) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${clinic.location.latitude},${clinic.location.longitude}'
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
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
      body: _showMapView ? _buildMapView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    if (_clinics.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEE8A9A),
        ),
      );
    }

    return Column(
      children: [
        if (_isLoadingLocation)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.orange.shade100,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Определяем ваше местоположение...'),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _clinics.length,
            itemBuilder: (context, index) {
              final clinic = _clinics[index];
              return _buildClinicCard(clinic);
            },
          ),
        ),
      ],
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
            if (clinic.workingHours != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    clinic.workingHours!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
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
                if (clinic.whatsapp != null)
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
                if (clinic.website != null)
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