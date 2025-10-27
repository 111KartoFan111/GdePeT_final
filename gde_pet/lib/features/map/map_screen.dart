import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet_model.dart';
import '../home/pet_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static final LatLng _astanaCenter = LatLng(51.169392, 71.449074);
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadPets();
    _checkLocationPermission();
  }

  Future<void> _loadPets() async {
    final petProvider = context.read<PetProvider>();
    // Загружаем все активные объявления
    await petProvider.loadPets();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      
      _mapController.move(_currentLocation!, 15.0);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось определить местоположение'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final pets = petProvider.pets.where((pet) => 
        pet.isActive && 
        pet.latitude != null && 
        pet.longitude != null
    ).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () {},
        ),
        title: const Text(
          'Карта',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _astanaCenter, 
              initialZoom: 12.0,
              onTap: (tapPosition, point) {
                // Можно добавить логику для добавления новых объявлений
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.zharkynismagulov.gde_pet', 
              ),
              MarkerLayer(
                markers: [
                  ...pets.map((pet) => _buildPetMarker(pet)).toList(),
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFEE8A9A),
              onPressed: _getCurrentLocation,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildPetMarker(PetModel pet) {
    return Marker(
      point: LatLng(pet.latitude!, pet.longitude!),
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _openPetDetail(pet),
        child: Container(
          decoration: BoxDecoration(
            color: pet.status == PetStatus.lost 
                ? const Color(0xFFEE8A9A) 
                : const Color(0xFFD6C9FF),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            pet.type == PetType.dog 
                ? Icons.pets 
                : pet.type == PetType.cat 
                    ? Icons.pets 
                    : Icons.pets,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _openPetDetail(PetModel pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailScreen(pet: pet),
      ),
    );
  }
}
