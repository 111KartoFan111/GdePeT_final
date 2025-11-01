import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../add/edit_pet_screen.dart';

class PetManagementScreen extends StatelessWidget {
  final PetModel pet;

  const PetManagementScreen({super.key, required this.pet});

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
          'Управление объявлением',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о питомце
            _buildPetInfoCard(pet),
            
            const SizedBox(height: 24),
            
            const Text(
              'Действия',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Кнопка редактирования
            _buildActionButton(
              context,
              icon: Icons.edit,
              label: 'Редактировать объявление',
              color: const Color(0xFFEE8A9A),
              onTap: () => _editPet(context),
            ),
            
            const SizedBox(height: 12),
            
            // Кнопка изменения статуса активности
            _buildActionButton(
              context,
              icon: pet.isActive ? Icons.pause_circle : Icons.play_circle,
              label: pet.isActive ? 'Деактивировать' : 'Активировать',
              color: pet.isActive ? Colors.orange : Colors.green,
              onTap: () => _toggleActive(context),
            ),
            
            const SizedBox(height: 12),
            
            // Кнопка изменения статуса (Пропал/Найден)
            _buildActionButton(
              context,
              icon: Icons.swap_horiz,
              label: pet.status == PetStatus.lost 
                  ? 'Отметить как найденного' 
                  : 'Отметить как пропавшего',
              color: Colors.blue,
              onTap: () => _toggleStatus(context),
            ),
            
            const SizedBox(height: 12),
            
            // Кнопка "Питомец найден" (закрывает объявление)
            if (pet.status == PetStatus.lost && pet.isActive)
              _buildActionButton(
                context,
                icon: Icons.check_circle,
                label: 'Питомец найден! Закрыть объявление',
                color: Colors.green,
                onTap: () => _markAsFound(context),
              ),
            
            const SizedBox(height: 12),
            
            // Кнопка удаления
            _buildActionButton(
              context,
              icon: Icons.delete,
              label: 'Удалить объявление',
              color: Colors.red,
              onTap: () => _deletePet(context),
            ),
            
            const SizedBox(height: 24),
            
            // Статистика объявления
            _buildStatsSection(pet),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoCard(PetModel pet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: pet.status == PetStatus.lost
                      ? const Color(0xFFEE8A9A)
                      : const Color(0xFFD6C9FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: pet.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          pet.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.pets, size: 30);
                          },
                        ),
                      )
                    : const Icon(Icons.pets, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.petName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.type.displayName} • ${pet.status.displayName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pet.isActive
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pet.isActive ? 'Активно' : 'Неактивно',
                  style: TextStyle(
                    fontSize: 12,
                    color: pet.isActive
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            pet.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(PetModel pet) {
    final daysActive = DateTime.now().difference(pet.createdAt).inDays;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem('Создано', _formatDate(pet.createdAt)),
          if (pet.updatedAt != null) ...[
            const SizedBox(height: 12),
            _buildStatItem('Обновлено', _formatDate(pet.updatedAt!)),
          ],
          const SizedBox(height: 12),
          _buildStatItem('Дней активно', daysActive.toString()),
          const SizedBox(height: 12),
          _buildStatItem('Фотографий', pet.imageUrls.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  // Действия
  
  void _editPet(BuildContext context) {
    _openEditPet(context);
  }

  Future<void> _openEditPet(BuildContext context) async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPetScreen(pet: pet),
      ),
    );

    if (result == true) {
      if (Navigator.canPop(context)) Navigator.pop(context, true);
    }
  }

  Future<void> _toggleActive(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet.isActive ? 'Деактивировать?' : 'Активировать?'),
        content: Text(
          pet.isActive
              ? 'Объявление будет скрыто из поиска'
              : 'Объявление снова появится в поиске',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final petProvider = context.read<PetProvider>();
      final success = await petProvider.togglePetActive(pet.id, !pet.isActive);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text(
              success
                  ? 'Статус изменен'
                  : petProvider.error ?? 'Ошибка изменения статуса',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<void> _toggleStatus(BuildContext context) async {
    final newStatus = pet.status == PetStatus.lost 
        ? PetStatus.found 
        : PetStatus.lost;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить статус?'),
        content: Text(
          'Статус будет изменен на "${newStatus.displayName}"',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Изменить'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final petProvider = context.read<PetProvider>();
      final success = await petProvider.updatePetStatus(pet.id, newStatus);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text(
              success
                  ? 'Статус изменен'
                  : petProvider.error ?? 'Ошибка изменения статуса',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<void> _markAsFound(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Отличная новость!'),
        content: const Text(
          'Питомец найден? Объявление будет переведено в статус "Найден" и деактивировано.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Да, найден!'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final petProvider = context.read<PetProvider>();
      final success = await petProvider.markPetAsFound(pet.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text(
              success
                  ? '🎉 Поздравляем с находкой!'
                  : petProvider.error ?? 'Ошибка',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<void> _deletePet(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить объявление?'),
        content: const Text(
          'Это действие нельзя отменить. Все данные объявления будут удалены.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final petProvider = context.read<PetProvider>();
      final success = await petProvider.deletePet(pet.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            content: Text(
              success
                  ? 'Объявление удалено'
                  : petProvider.error ?? 'Ошибка удаления',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          Navigator.pop(context, true);
        }
      }
    }
  }
}