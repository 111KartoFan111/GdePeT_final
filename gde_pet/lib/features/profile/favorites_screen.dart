import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet_model.dart';
import '../home/home_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<PetModel> _favoritePets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    final petProvider = context.read<PetProvider>();

    if (authProvider.user == null) return;

    setState(() => _isLoading = true);

    await favoritesProvider.loadFavorites(authProvider.user!.uid);
    await petProvider.loadPets();

    _favoritePets = petProvider.pets
        .where((pet) => favoritesProvider.isFavorite(pet.id))
        .toList();

    setState(() => _isLoading = false);
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
          'Избранное',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: const Color(0xFFEE8A9A),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFEE8A9A)),
              )
            : _favoritePets.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Нет избранных объявлений',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 280,
                    ),
                    itemCount: _favoritePets.length,
                    itemBuilder: (context, index) {
                      final pet = _favoritePets[index];
                      return PetCard(
                        petModel: pet,
                        color: pet.status == PetStatus.lost
                            ? const Color(0xFFEE8A9A)
                            : const Color(0xFFD6C9FF),
                        title: pet.petName,
                        location: pet.address ?? 'На карте',
                      );
                    },
                  ),
      ),
    );
  }
}