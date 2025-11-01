import 'package:flutter/material.dart';
import 'package:gde_pet/features/home/pet_detail_screen.dart';
import 'package:gde_pet/models/pet_model.dart';
import 'package:timeago/timeago.dart' as timeago;

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
        margin: const EdgeInsets.only(bottom: 16),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Изображение
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                image: pet.imageUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(pet.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: pet.imageUrls.isEmpty ? color.withOpacity(0.3) : null,
              ),
              child: pet.imageUrls.isEmpty
                  ? const Center(
                      child: Icon(Icons.pets, size: 40, color: Colors.white),
                    )
                  : null,
            ),
            // Информация
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Кличка
                    Text(
                      pet.petName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Тип
                    Text(
                      pet.type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Локация
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pet.address ?? 'Место на карте',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Время
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Тег статуса
            Container(
              width: 24,
              height: 140,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(20),
                ),
              ),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    pet.status.displayName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

