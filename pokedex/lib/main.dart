import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/pokemon_provider.dart';
import 'pages/home_page.dart';
import 'bloc/favorites_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar with white icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PokemonProvider()),
        BlocProvider<FavoritesBloc>(
          create: (context) => FavoritesBloc()..add(LoadFavorites()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',

      theme: ThemeData(
        useMaterial3: true,

        // Modern color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE63946), // modern pokemon red
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Colors.white,

        // Apply modern font everywhere
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: const Color(0xFFE63946),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),

      home: const HomePage(),
    );
  }
}
