import 'package:flutter/material.dart';
import 'package:gde_pet/features/home/pet_detail_screen.dart';
import 'package:gde_pet/models/pet_model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';

class PetListItem extends StatelessWidget {
  final PetModel pet;

  const PetListItem({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final color = pet.status == PetStatus.lost
        ? const Color(0xFFEE8A9A)
        : const Color(0xFFD6C9FF);
    // Убедимся, что 'ru' локаль установлена
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    final timeAgo = timeago.format(pet.createdAt, locale: 'ru');
    
    // --- Логика избранного ---
    final authProvider = context.watch<AuthProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = authProvider.user != null && favoritesProvider.isFavorite(pet.id);
    
    // --- ИЗМЕНЕНИЕ: Полная замена на вертикальный дизайн PetCard ---
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailScreen(pet: pet),
          ),
        );
      },
      child: Container(
        height: 280, // Высота как у PetCard
        margin: const EdgeInsets.only(bottom: 16), // Отступ для ListView
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Фото питомца
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      image: pet.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(pet.imageUrls.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: pet.imageUrls.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                              color: color.withOpacity(0.3),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.pets,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  // Иконка избранного
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        if (authProvider.user == null) return;
                        await favoritesProvider.toggleFavorite(
                          authProvider.user!.uid, 
                          pet.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Блок информации
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Группа: Кличка и Тип
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Кличка
                        Text(
                          pet.petName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Тип
                        Text(
                          pet.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    // Группа: Локация и Дата
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Локация
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pet.address ?? 'Место на карте',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Дата
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // --- КОНЕЦ ИЗМЕНЕНИЯ ---
  }
}

