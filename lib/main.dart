import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'controllers/app_controller.dart';
import 'controllers/audio_controller.dart';
import 'controllers/image_controller.dart';
import 'views/home_view.dart';
import 'views/encode_view.dart';
import 'views/decode_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WaveCode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomeView()),
        GetPage(name: '/encode', page: () => EncodeView()),
        GetPage(name: '/decode', page: () => DecodeView()),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(AppController());
        Get.put(AudioController());
        Get.put(ImageController());
      }),
    );
  }
}