import 'package:daic_home/pages/favorie_page.dart';
import 'package:daic_home/pages/home_page.dart';
import 'package:daic_home/pages/menu_page.dart';
import 'package:daic_home/pages/search_page.dart';
import 'package:daic_home/pages/signup_page.dart';
import 'package:daic_home/services/auth_check.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:daic_home/services/update_checker_version.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Supabase.initialize(
    url: "https://relufzgkhkwsciqjnhdk.supabase.co",
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlbHVmemdraGt3c2NpcWpuaGRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4NDAyNDEsImV4cCI6MjA1OTQxNjI0MX0.G9Ey7tPUMEYrC4Jo0wnJsXaqgqX1gJ8uvaHQGCMkrBM',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization(); // Call the initialization function
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove(); // Remove the splash screen
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daic Homes',
      initialRoute: '/',
      routes: {
        '/': (context) => AuthCheck(),
        '/login': (context) => SignupPage(),
        '/main': (context) => MainPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      debugShowCheckedModeBanner: false,
      // home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _HomePageState();
}

class _HomePageState extends State<MainPage> {
  int selectedIndex = 0;
  late Future avatarnameUser;
  DateTime? lastPressed;

  // Liste des pages pour chaque onglet
  final List<Widget> pages = [
    const HomePage(),
    const SearchPage(),
    const FavoriePage(),
    const MenuPage(),
  ];

  @override
  void initState() {
    super.initState();

    UpdateCheckerVersion().checkForUpdate(context); // Vérifie les mises à jour
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          toolbarHeight: 70,
          // leading: Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Image.asset("assets/images/logo2.jpg"),
          // ),
          title: Text(
            'Daic Homes',
            style: GoogleFonts.acme(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => NavigatorHelper.toEditPage(context: context),
                child: FutureBuilder<String?>(
                  future: AuthService().getUserAvatarUrl(),
                  builder: (context, snapshot) {
                    // Si on a une URL valide d'avatar
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty &&
                        snapshot.data!.startsWith('http')) {
                      return CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        imageBuilder:
                            (context, imageProvider) => CircleAvatar(
                              backgroundImage: imageProvider,
                              radius: 35,
                            ),
                        placeholder:
                            (context, url) => CircleAvatar(
                              backgroundImage: const AssetImage(
                                "assets/images/profil.png",
                              ),
                              radius: 35,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => CircleAvatar(
                              backgroundImage: const AssetImage(
                                "assets/images/profil.png",
                              ),
                              radius: 35,
                            ),
                      );
                    }

                    // Image par défaut si pas d'avatar
                    return CircleAvatar(
                      backgroundImage: const AssetImage(
                        "assets/images/profil.png",
                      ),
                      radius: 35,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 2),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          const maxDuration = Duration(seconds: 2);
          final isWarning =
              lastPressed == null || now.difference(lastPressed!) > maxDuration;

          if (isWarning) {
            lastPressed = DateTime.now();
            Fluttertoast.showToast(
              msg: 'Appuyez à nouveau pour quitter',
              toastLength: Toast.LENGTH_SHORT,
            );
            return false;
          }
          return true;
        },
        child: SafeArea(child: pages[selectedIndex]),
      ), // Affiche la page sélectionnée

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
        type: BottomNavigationBarType.fixed,
        iconSize: 25,
        selectedFontSize: 18,
        unselectedFontSize: 12,
      ),
    );
  }
}
