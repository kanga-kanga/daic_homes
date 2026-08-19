import 'package:daic_home/pages/favorie_page.dart';
import 'package:daic_home/pages/home_page.dart';
import 'package:daic_home/pages/menu_page.dart';
import 'package:daic_home/pages/search_page.dart';
import 'package:daic_home/pages/login_page.dart';
import 'package:daic_home/pages/signup_page.dart';
import 'package:daic_home/services/auth_check.dart';
import 'package:daic_home/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upgrader/upgrader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:daic_home/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:daic_home/admin/pages/admin_home_page.dart'; // Added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Les fonctions d'initialisation peuvent être ajoutées ici
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daic Homes',
      initialRoute: '/',
      routes: {
        '/': (context) => AuthCheck(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/main': (context) => MainPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF2E7D32),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black.withOpacity(0.05),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: const Color(0xFF1B5E20),
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          toolbarHeight: 70,
          // leading: Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Image.asset("assets/images/logo2.jpg"),
          // ),
          title: Text(
            'Daic Homes',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
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
      body: kIsWeb
          ? PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;

                if (selectedIndex != 0) {
                  setState(() {
                    selectedIndex = 0;
                  });
                  return;
                }
              },
              child: SafeArea(child: pages[selectedIndex]),
            )
          : UpgradeAlert(
              upgrader: Upgrader(
                languageCode: 'fr',
                messages: UpgraderMessages(code: 'fr'),
                durationUntilAlertAgain: const Duration(days: 1),
              ),
              showIgnore: false,
              showLater: true,
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return;

                  if (selectedIndex != 0) {
                    setState(() {
                      selectedIndex = 0;
                    });
                    return;
                  }

                  final now = DateTime.now();
                  const maxDuration = Duration(seconds: 2);
                  final isWarning =
                      lastPressed == null ||
                      now.difference(lastPressed!) > maxDuration;

                  if (isWarning) {
                    lastPressed = DateTime.now();
                    Fluttertoast.showToast(
                      msg: 'Appuyez à nouveau pour quitter',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                    return;
                  }
                  SystemNavigator.pop();
                },
                child: SafeArea(child: pages[selectedIndex]),
              ),
            ), // Affiche la page sélectionnée avec alerte de mise à jour

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 4,
              activeColor: Theme.of(context).colorScheme.primary,
              iconSize: 20,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              color: Colors.grey[500],
              tabs: [
                GButton(icon: Icons.home_rounded, text: 'Accueil'),
                GButton(icon: Icons.search_rounded, text: 'Recherche'),
                GButton(icon: Icons.favorite_rounded, text: 'Favoris'),
                GButton(icon: Icons.menu_rounded, text: 'Menu'),
              ],
              selectedIndex: selectedIndex,
              onTabChange: onItemTapped,
            ),
          ),
        ),
      ),
      floatingActionButton:
          selectedIndex == 0
              ? FutureBuilder<Map<String, dynamic>?>(
                future: AuthService().getCurrentUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!['role'] == 'admin') {
                    return Animate(
                      effects: [ScaleEffect(delay: 1.seconds)],
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminHomePage(),
                            ),
                          );
                        },
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        icon: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Admin",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
              : null,
    );
  }
}
