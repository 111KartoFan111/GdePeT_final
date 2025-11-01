import 'package:latlong2/latlong.dart';
import '../models/vet_clinic_model.dart';

class VetClinicService {
  // Захардкоженные данные ветклиник для Астаны
  // В будущем можно заменить на API запросы к Google Places или собственному бэкенду
  static List<VetClinic> getVetClinics() {
    return [
      VetClinic(
        id: '1',
        name: 'Ветеринарная клиника "Четыре лапы"',
        address: 'пр. Мангилик Ел, 55/21',
        location: LatLng(51.1284, 71.4301),
        phone: '+77172123456',
        whatsapp: '77172123456',
        workingHours: 'Пн-Вс: 9:00 - 21:00',
        rating: 4.8,
        isEmergency: false,
      ),
      VetClinic(
        id: '2',
        name: 'Ветклиника "Доктор Айболит"',
        address: 'ул. Кенесары, 40',
        location: LatLng(51.1691, 71.4495),
        phone: '+77172234567',
        whatsapp: '77172234567',
        workingHours: 'Круглосуточно',
        rating: 4.6,
        isEmergency: true,
      ),
      VetClinic(
        id: '3',
        name: 'Центр ветеринарной медицины "Зоомир"',
        address: 'ул. Сауран, 3/1',
        location: LatLng(51.1355, 71.4269),
        phone: '+77172345678',
        whatsapp: '77172345678',
        website: 'https://zoomir-vet.kz',
        workingHours: 'Пн-Пт: 8:00 - 20:00, Сб-Вс: 9:00 - 18:00',
        rating: 4.9,
        isEmergency: false,
      ),
      VetClinic(
        id: '4',
        name: 'Ветеринарная станция "Друг"',
        address: 'ул. Богенбай батыра, 28',
        location: LatLng(51.1802, 71.4460),
        phone: '+77172456789',
        whatsapp: '77172456789',
        workingHours: 'Пн-Вс: 9:00 - 22:00',
        rating: 4.5,
        isEmergency: false,
      ),
      VetClinic(
        id: '5',
        name: 'Клиника "Здоровый питомец"',
        address: 'пр. Кабанбай батыра, 60',
        location: LatLng(51.1603, 71.4704),
        phone: '+77172567890',
        whatsapp: '77172567890',
        workingHours: 'Круглосуточно',
        rating: 4.7,
        isEmergency: true,
      ),
      VetClinic(
        id: '6',
        name: 'Ветцентр "ПетКлиник"',
        address: 'ул. Туркестан, 14/2',
        location: LatLng(51.1512, 71.4389),
        phone: '+77172678901',
        website: 'https://petclinic-astana.kz',
        workingHours: 'Пн-Сб: 8:00 - 20:00',
        rating: 4.4,
        isEmergency: false,
      ),
    ];
  }

  // Получить клиники отсортированные по расстоянию от пользователя
  static List<VetClinic> getSortedByDistance(LatLng userLocation) {
    final clinics = getVetClinics();
    clinics.sort((a, b) => 
      a.getDistanceFrom(userLocation).compareTo(b.getDistanceFrom(userLocation))
    );
    return clinics;
  }

  // Получить только круглосуточные клиники
  static List<VetClinic> getEmergencyClinics() {
    return getVetClinics().where((clinic) => clinic.isEmergency).toList();
  }
}