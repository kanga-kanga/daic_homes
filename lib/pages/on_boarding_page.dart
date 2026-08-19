import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          "Grâce à une recherche intelligente et optimisée, trouvez en clin d'œil, la maison faite pour vous",
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
            bottom: 30,
            right: 24,
            left: 24,
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _onboardingItems[_currentPage].color,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: _onboardingItems[_currentPage].color.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (_currentPage == _onboardingItems.length - 1) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutQuart,
                    );
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _currentPage == _onboardingItems.length - 1
                        ? "Commencer"
                        : "Suivant",
                    key: ValueKey<int>(_currentPage),
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
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
        // Effet dégradé sur l'image pour une meilleure lisibilité
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.9),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        // Contenu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Icon(
                item.image,
                size: 100,
                color: Colors.white,
              )
                  .animate(key: ValueKey('icon_${item.title}'))
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 48),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              )
                  .animate(key: ValueKey('title_${item.title}'))
                  .fadeIn(delay: 300.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),
              const SizedBox(height: 24),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              )
                  .animate(key: ValueKey('desc_${item.title}'))
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),
              const Spacer(flex: 2),
            ],
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
