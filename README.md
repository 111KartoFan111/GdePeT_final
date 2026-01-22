# GdePet

Мобильное приложение на Flutter для помощи в поиске пропавших и найденных домашних животных. Проект ориентирован на быстрые публикации объявлений, удобный поиск и связь между людьми.

## Основные возможности

- Регистрация и вход пользователей
- Лента объявлений: «пропали» и «найдены»
- Создание объявлений с фото
- Карта с метками (OpenStreetMap через `flutter_map`)
- Встроенный чат
- Профиль пользователя и управление объявлениями

## Стек

- Flutter / Dart
- Firebase: Auth, Firestore, Storage
- Карты: OpenStreetMap (`flutter_map`)
- HTTP запросы: `http`

## Структура проекта

- `gde_pet/` — Flutter приложение
- `gde_pet/lib/` — исходники приложения
- `gde_pet/android/` — Android конфигурация
- `gde_pet/ios/` — iOS конфигурация
- `gde_pet/.env.example` — шаблон переменных окружения

## Требования

- Flutter SDK (стабильный канал)
- Android Studio или Xcode
- Установленный Firebase CLI и FlutterFire CLI (для генерации конфигурации)

## Быстрый старт

1) Установи зависимости:
```bash
cd gde_pet
flutter pub get
```

2) Создай локальный `.env`:
```bash
cp .env.example .env
```

3) Заполни `.env` своими ключами:
```
GOOGLE_PLACES_API_KEY=ваш_ключ
GEMINI_API_KEY=ваш_ключ
FIREBASE_IOS_API_KEY=ваш_ключ
FIREBASE_ANDROID_API_KEY=ваш_ключ
```

4) Запусти приложение:
```bash
flutter run
```

## Полная настройка Firebase (пошагово)

### 1. Создай проект в Firebase
1) Перейди в https://console.firebase.google.com
2) Нажми **Add project**
3) Задай имя проекта (например, `gde-pet`)
4) Отключи/включи Analytics по необходимости
5) Нажми **Create project**

### 2. Добавь Android приложение
1) В Firebase Console нажми иконку **Android**
2) Укажи **Package name**, он должен совпадать с `applicationId` в `gde_pet/android/app/build.gradle` (например, `com.example.gde_pet`)
3) Скачай `google-services.json`
4) Помести файл в `gde_pet/android/app/google-services.json`
5) Если используешь Google/Phone Auth — добавь SHA‑1 и SHA‑256 в настройках приложения

### 3. Добавь iOS приложение
1) В Firebase Console нажми иконку **iOS**
2) Укажи **Bundle ID**, он должен совпадать с `ios/Runner` (например, `com.adinaadilova.gdePet`)
3) Скачай `GoogleService-Info.plist`
4) Помести файл в `gde_pet/ios/Runner/GoogleService-Info.plist`
5) Открой `Runner.xcworkspace` в Xcode и убедись, что файл добавлен в target **Runner**

### 4. Установи Firebase CLI и FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
firebase login
```

### 5. Сгенерируй `firebase_options.dart`
В корне `gde_pet`:
```bash
flutterfire configure
```
Выбери нужный проект и платформы. Файл `gde_pet/lib/firebase_options.dart` будет создан/обновлен.

### 6. Включи сервисы в Firebase Console
- **Authentication** → включи Email/Password и при необходимости Google
- **Firestore Database** → создай базу
- **Storage** → включи хранилище

### 7. Проверь инициализацию Firebase в проекте
Инициализация уже добавлена в `gde_pet/lib/main.dart`. Перед запуском подгружается `.env`:
```dart
await dotenv.load(fileName: '.env');
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 8. Важно про `.env`
- `.env` используется только в Dart‑коде (например, для ключей Google Places и Gemini).
- Файлы `google-services.json` и `GoogleService-Info.plist` не читают `.env`. Они должны содержать реальные данные от Firebase.

## Где используются ключи из `.env`

- Google Places API: `gde_pet/lib/services/vet_clinic_service.dart`
- Gemini API: `gde_pet/lib/services/gemini_service.dart`
- Firebase iOS API key (для `firebase_options.dart`): `gde_pet/lib/firebase_options.dart`

## Полезные команды

- `flutter pub get` — установить зависимости
- `flutter run` — запуск приложения
- `flutter clean` — очистка кешей сборки
- `flutterfire configure` — генерация Firebase конфигурации

## Возможные ошибки и решения

- **No Firebase App '[DEFAULT]' has been created**
  - Проверь, что `Firebase.initializeApp(...)` вызывается после `dotenv.load(...)`.
- **Firebase options not configured**
  - Перезапусти `flutterfire configure` и проверь `firebase_options.dart`.
- **Google Sign-In не работает на Android**
  - Убедись, что добавлены SHA‑1/ SHA‑256 в Firebase Console и перескачан `google-services.json`.

---

Если нужно дополнительно описать фичи или добавить скриншоты/архитектуру — скажи, добавлю.
