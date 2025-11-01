import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../../models/pet_model.dart';
import '../profile/pet_management_screen.dart';

class UserPetsScreen extends StatefulWidget {
  const UserPetsScreen({super.key});

  @override
  State<UserPetsScreen> createState() => _UserPetsScreenState();
}

class _UserPetsScreenState extends State<UserPetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPets();
    });
  }

  Future<void> _loadUserPets() async {
    final authProvider = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();
    if (authProvider.user != null) {
      await petProvider.loadUserPets(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final pets = petProvider.userPets;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Мои объявления',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserPets,
        color: const Color(0xFFEE8A9A),
        child: petProvider.isLoading && pets.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFEE8A9A)),
              )
            : pets.isEmpty
                ? const Center(
                    child: Text(
                      'Вы еще не создали ни одного объявления.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      // Создаем свою карточку вместо использования PetCard
                      return _buildUserPetCard(pet);
                    },
                  ),
      ),
    );
  }

  Widget _buildUserPetCard(PetModel pet) {
    final color = pet.status == PetStatus.lost
        ? const Color(0xFFEE8A9A)
        : const Color(0xFFD6C9FF);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetManagementScreen(pet: pet),
          ),
        ).then((result) {
          if (result == true) {
            _loadUserPets();
          }
        });
      },
      child: PetCard(
        petModel: pet,
        color: color,
        title: pet.petName,
        location: pet.address ?? 'На карте',
      ),
    );
  }
}