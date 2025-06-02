import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/images_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImagesProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Biblioteca de Imagens',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
