import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:pchat_app/firebase_options.dart';
import 'package:pchat_app/services/alert_service.dart';
import 'package:pchat_app/services/auth_services.dart';
import 'package:pchat_app/services/database_service.dart';
import 'package:pchat_app/services/media_service.dart';
import 'package:pchat_app/services/navigation_service.dart';
import 'package:pchat_app/services/storage_services.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
}
