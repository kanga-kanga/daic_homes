import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Trouvez la maison parfaite",
      description:
          "Parcourez des milliers d'annonces pour trouver la maison qui correspond à vos besoins.",
      image: Icons.home_work_outlined,
      color: Colors.yellow.shade700,
      backgroundImage: "assets/images/boarding1.jpg",
    ),
    OnboardingItem(
      title: "Visites virtuelles",
      description:
          "Découvrez les propriétés avec des visites virtuelles avant de vous déplacer.",
      image: Icons.video_camera_back_outlined,
      color: Colors.green.shade700,
      backgroundImage: "assets/images/boarding2.jpg",
    ),
    OnboardingItem(
      title: "Réservation facile",
      description:
          "Réservez votre location en quelques clics, avec un processus sécurisé et transparent.",
      image: Icons.credit_card_outlined,
      color: Colors.orange.shade700,
      backgroundImage: "assets/images/boarding1.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingScreen(item: _onboardingItems[index]);
            },
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _onboardingItems.length,
                effect: WormEffect(
                  activeDotColor: _onboardingItems[_currentPage].color,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            left: 10,
            child: SizedBox(
              // width: double.infinity,
              width: MediaQuery.of(context).size.width * 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _onboardingItems[_currentPage].color,
                ),
                onPressed: () {
                  if (_currentPage == _onboardingItems.length - 1) {
                    // Naviguer vers la page de login
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
                child: Text(
                  _currentPage == _onboardingItems.length - 1
                      ? "Valider" //Icons.check
                      : "Suivant", //Icons.arrow_forward,
                  // color: Colors.white,
                  style: GoogleFonts.pacifico(
                    fontSize: 18, // Taille de la police
                    fontWeight: FontWeight.bold, // Gras
                    color: Colors.white, // Couleur du texte
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image en arrière-plan
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(item.backgroundImage), // Chemin de l'image
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Effet noirci sur l'image
        Container(color: Colors.black.withOpacity(0.5)),
        // Contenu (titre et description)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.image, size: 100, color: Colors.white),
                const SizedBox(height: 40),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  item.description,
                  style: GoogleFonts.pacifico(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData image;
  final Color color;
  final String backgroundImage;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    required this.backgroundImage,
  });
}
