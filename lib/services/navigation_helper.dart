import 'package:daic_home/pages/aboutUs_page.dart';
import 'package:daic_home/pages/contactUs.dart';
import 'package:daic_home/pages/details_page.dart';
import 'package:daic_home/models/house.dart';
import 'package:daic_home/pages/editprofil_page.dart';
import 'package:daic_home/pages/help_page.dart';
import 'package:daic_home/pages/see_more_page.dart';
import 'package:flutter/material.dart';

class NavigatorHelper {
  static void toDetails({required context, required House house}) {
    final page = DetailsPage(house: house);
    final MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => page,
    );
    Navigator.push(context, route);
  }

  static void toAboutUs({required context}) {
    final page = AboutusPage();
    final MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => page,
    );
    Navigator.push(context, route);
  }

  static void toEditPage({required context}) {
    final page = EditprofilPage();
    final MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => page,
    );
    Navigator.push(context, route);
  }

  static void toHelpPage({required context}) {
    final page = HelpPage();
    final MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => page,
    );
    Navigator.push(context, route);
  }

  static void toContactPage({required context}) {
    final page = ContactusPage();
    final MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => page,
    );
    Navigator.push(context, route);
  }

  static void toSeeMore({required context}) {
    final page = SeeMorePage();
    final MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => page,
    );
    Navigator.push(context, route);
  }

  static void toLoginPage({required context}) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  static void toSignupPage({required context}) {
    Navigator.pushReplacementNamed(context, '/signup');
  }
}
