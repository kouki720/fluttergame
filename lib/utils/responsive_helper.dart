import 'package:flutter/widgets.dart';

class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    return getScreenWidth(context) >= 600 && getScreenWidth(context) < 1200;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 1200;
  }

  // Taille de texte responsive
  static double getResponsiveTextSize(BuildContext context,
      {double small = 12, double medium = 14, double large = 16}) {
    final width = getScreenWidth(context);

    if (width < 400) return small;
    if (width < 800) return medium;
    return large;
  }

  // Nombre de colonnes responsive
  static int getResponsiveColumnCount(BuildContext context) {
    final width = getScreenWidth(context);

    if (width < 600) return 2;   // Mobile portrait
    if (width < 900) return 3;   // Tablet portrait / mobile landscape
    if (width < 1200) return 4;  // Tablet landscape
    return 5;                    // Desktop
  }
}