import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gde_pet/features/messenger/chat_detail_screen.dart';
import 'package:gde_pet/services/chat_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/pet_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/pet_provider.dart';
import '../../features/vet/vet_clinics_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final PetModel pet;
  
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullscreenImagePage({super.key, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Hero(
            tag: tag,
            child: imageUrl.startsWith('assets/')
                ? Image.asset(imageUrl, fit: BoxFit.contain)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/images/pet_image_placeholder.png', fit: BoxFit.contain);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _PetDetailScreenState extends State<PetDetailScreen> {

// Улучшенная функция "Поделиться" с поддержкой iOS/iPad
void _sharePet() async {
  try {
    final pet = widget.pet;
    
    // Формируем текст для отправки
    final statusEmoji = pet.status == PetStatus.lost ? '🆘' : '✅';
    final statusText = pet.status == PetStatus.lost ? 'Пропал(а)' : 'Найден(а)';
    
    String locationInfo = '';
    if (pet.address != null && pet.address!.isNotEmpty) {
      locationInfo = '\n📍 Местоположение: ${pet.address}';
    } else if (pet.latitude != null && pet.longitude != null) {
      locationInfo = '\n📍 Координаты: ${pet.latitude!.toStringAsFixed(6)}, ${pet.longitude!.toStringAsFixed(6)}\n'
                     '🗺️ Карта: https://maps.google.com/?q=${pet.latitude},${pet.longitude}';
    }
    
    String contactInfo = '';
    if (pet.contactPhone != null && pet.contactPhone!.isNotEmpty) {
      contactInfo += '\n📞 Телефон: ${pet.contactPhone}';
    }
    if (pet.contactTelegram != null && pet.contactTelegram!.isNotEmpty) {
      contactInfo += '\n✈️ Telegram: ${pet.contactTelegram}';
    }
    
    final text = '$statusEmoji Внимание! $statusText ${pet.type.displayName.toLowerCase()}!\n\n'
                 '🐾 Кличка: ${pet.petName}\n'
                 '📋 Приметы: ${pet.description}$locationInfo'
                 '$contactInfo\n\n'
                 '👤 Владелец: ${pet.ownerName}\n\n'
                 '📱 Приложение: GdePet\n'
                 'Помогите найти или вернуть питомца!';

    // Получаем размер экрана для позиционирования на iPad
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    // Share.share с указанием позиции для iPad
    await Share.share(
      text,
      subject: '$statusText ${pet.type.displayName} "${pet.petName}"',
      sharePositionOrigin: sharePositionOrigin,
    );
    
    print('Share dialog opened successfully');
    
  } catch (e) {
    print('Error sharing: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Не удалось открыть меню: ${e.toString()}'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Повторить',
            textColor: Colors.white,
            onPressed: () => _sharePet(),
          ),
        ),
      );
    }
    }
  }

  void _openFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenImagePage(
          imageUrl: imageUrl,
          tag: 'pet-image-${widget.pet.id}',
        ),
      ),
    );
  }

Future<void> _callForHelp() async {
  final pet = widget.pet;
  
  // Показываем диалог с выбором способа связи
  final method = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Text('🆘 Позвать на помощь'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите способ связи с волонтерами:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                    SizedBox(width: 8),
                    Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(' - быстрое сообщение', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Позвонить', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(' - прямой звонок', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.message, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('SMS', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(' - текстовое сообщение', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'sms'),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.message, size: 18),
              SizedBox(width: 4),
              Text('SMS'),
            ],
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'call'),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone, size: 18),
              SizedBox(width: 4),
              Text('Позвонить'),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, 'whatsapp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366), // WhatsApp color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat, size: 18, color: Colors.white),
              SizedBox(width: 4),
              Text('WhatsApp', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    ),
  );

  if (method == null) return;

  const String phone = '77771959900';
  
  // Формируем информацию о местоположении
  String locationInfo;
  if (pet.address != null && pet.address!.isNotEmpty) {
    locationInfo = pet.address!;
  } else if (pet.latitude != null && pet.longitude != null) {
    locationInfo = 'Координаты: ${pet.latitude}, ${pet.longitude}\n'
                   'Карта: https://maps.google.com/?q=${pet.latitude},${pet.longitude}';
  } else {
    locationInfo = 'Местоположение не указано';
  }
  
  // Формируем сообщение
  final message = '🆘 Требуется помощь!\n\n'
                  '🐾 Животное: ${pet.petName}\n'
                  '📋 Тип: ${pet.type.displayName}\n'
                  '📝 Приметы: ${pet.description}\n\n'
                  '📍 Местоположение:\n$locationInfo\n\n'
                  '👤 Владелец: ${pet.ownerName}\n'
                  '📱 Приложение: GdePet';

  try {
    Uri uri;
    
    switch (method) {
      case 'whatsapp':
        uri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
        break;
      case 'call':
        uri = Uri.parse('tel:+$phone');
        break;
      case 'sms':
        uri = Uri.parse('sms:+$phone?body=${Uri.encodeComponent(message)}');
        break;
      default:
        return;
    }
    
    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть ${_getMethodName(method)}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getMethodName(method)} недоступен на этом устройстве'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          ),
        );
      }
    }
  } catch (e) {
    print('Error calling for help: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }
}

String _getMethodName(String method) {
  switch (method) {
    case 'whatsapp':
      return 'WhatsApp';
    case 'call':
      return 'приложение для звонков';
    case 'sms':
      return 'приложение для SMS';
    default:
      return 'приложение';
  }
}
  Future<void> _handleSeenSighting() async {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Для этого действия нужно войти в аккаунт'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('👀 Видели питомца?'),
        content: const Text(
          'Эта функция поможет владельцу найти питомца!\n\n'
          'Ваше текущее местоположение будет отправлено владельцу в чат '
          'вместе со ссылкой на Google Maps.\n\n'
          'Нужно разрешить доступ к геолокации.',
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
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Подтвердить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    
    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFEE8A9A)),
                SizedBox(height: 16),
                Text('Определение местоположения...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Проверяем, включена ли геолокация
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          Navigator.of(context).pop(); // Закрываем диалог загрузки
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
              content: const Text('Включите геолокацию в настройках устройства'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Настройки',
                textColor: Colors.white,
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
              ),
            ),
          );
        }
        return;
      }

      // Проверяем разрешения
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
                content: Text('Доступ к геолокации запрещен'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Нет доступа к геолокации'),
              content: const Text(
                'Доступ к геолокации запрещен навсегда.\n\n'
                'Пожалуйста, разрешите доступ в настройках приложения.',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Geolocator.openAppSettings();
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE8A9A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Настройки', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Получаем местоположение
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Превышено время ожидания');
          },
        );
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
              content: Text('Не удалось определить местоположение. Попробуйте еще раз'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Отправляем отметку
      final petProvider = context.read<PetProvider>();
      bool success = false;
      
      try {
        success = await petProvider.addSighting(
          petId: widget.pet.id,
          latitude: position.latitude,
          longitude: position.longitude,
          userId: authProvider.user!.uid,
        );
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
              content: Text('Ошибка отправки: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(); // Закрываем диалог загрузки
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ Спасибо! Владелец получил сообщение с вашим местоположением',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
              content: Text(
                petProvider.error ?? 'Не удалось добавить отметку',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _openChat() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          content: Text('Для этого действия нужно войти в аккаунт')
        ),
        
      );
      return;
    }
    
    final currentUserId = authProvider.user!.uid;
    final receiverId = widget.pet.userId;

    if (currentUserId == receiverId) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          content: Text('Вы не можете написать самому себе')
        ),
      );
      return;
    }

    final chatService = ChatService();
    final chatId = await chatService.createOrGetChat(currentUserId, receiverId);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chatId: chatId,
            receiverId: receiverId,
            receiverName: widget.pet.ownerName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = authProvider.user != null && favoritesProvider.isFavorite(widget.pet.id);
    final statusColor = widget.pet.status == PetStatus.lost 
        ? const Color(0xFFEE8A9A) 
        : const Color(0xFFD6C9FF);
    
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            width: double.infinity,
            child: widget.pet.imageUrls.isNotEmpty
                ? GestureDetector(
                    onTap: () => _openFullImage(widget.pet.imageUrls.first),
                    child: Hero(
                      tag: 'pet-image-${widget.pet.id}',
                      child: Image.network(
                        widget.pet.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return GestureDetector(
                            onTap: () => _openFullImage('assets/images/pet_image_placeholder.png'),
                            child: Image.asset(
                              'assets/images/pet_image_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => _openFullImage('assets/images/pet_image_placeholder.png'),
                    child: Hero(
                      tag: 'pet-image-${widget.pet.id}',
                      child: Image.asset(
                        'assets/images/pet_image_placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.pet.status.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                 color: Color(0xFFF9E1E1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Expanded(
                           child: Text(
                            widget.pet.petName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                                                   ),
                         ),
                        IconButton(
                          onPressed: () async {
                            if (authProvider.user == null) return;
                            await favoritesProvider.toggleFavorite(authProvider.user!.uid, widget.pet.id);
                          },
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.redAccent : Colors.black,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.pet.type.displayName} • ${widget.pet.ownerName}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.pet.description,
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.pet.status == PetStatus.lost) ...[
           SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.visibility, color: Colors.white),
              onPressed: _handleSeenSighting,
              label: const Text('Видели? Жмите!', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _openChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE8A9A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Написать хозяину', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  onPressed: _sharePet,
                  label: const Text('Поделиться'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
             Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.support_agent),
                  onPressed: _callForHelp,
                  label: const Text('Помощь'),
                   style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VetClinicsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.local_hospital),
              label: const Text('Ближайшие ветклиники'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // Зеленый цвет для медицины
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],

        )
      ],
    );
  }
}