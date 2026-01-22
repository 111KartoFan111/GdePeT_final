// Этот файл будет автоматически сгенерирован после настройки Firebase
// Для генерации выполните: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return iosOptions;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get iosOptions => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'YOUR_FIREBASE_IOS_API_KEY_HERE',
    appId: '1:777709444767:ios:b686af5d31e0689c130caa',
    messagingSenderId: '777709444767',
    projectId: 'gde-pet',
    storageBucket: 'gde-pet.firebasestorage.app',
    iosClientId: '777709444767-okbo2hq38eu993efcsngq455qcvgedsl.apps.googleusercontent.com',
    iosBundleId: 'com.adinaadilova.gdePet',
  );

}
