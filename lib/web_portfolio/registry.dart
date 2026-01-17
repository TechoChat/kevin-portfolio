import 'package:flutter/material.dart';
import 'ui/iot_dashboard.dart';
import 'ui/drone_controller.dart';
import 'ui/crm_admin.dart';
import 'ui/flight_booking.dart';

enum AppCategory { mechatronics, events, saas, journey, hobbies }

class PortfolioApp {
  final String id;
  final String name;
  final IconData icon;
  final AppCategory category;
  final WidgetBuilder appBuilder;
  final String? description;
  final Color color;
  final Color iconColor;

  const PortfolioApp({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.appBuilder,
    this.description,
    this.color = Colors.blue,
    this.iconColor = Colors.white,
  });
}

class PortfolioRegistry {
  static final List<PortfolioApp> apps = [
    // Category 1: Mechatronics & IoT
    PortfolioApp(
      id: 'iot_dashboard',
      name: 'Industrial IoT',
      icon: Icons.dashboard,
      category: AppCategory.mechatronics,
      appBuilder: (context) => const IotDashboard(),
      description: 'Factory sensors monitoring',
      color: Color(0xFF1E1E1E), // Dark Grey
      iconColor: Colors.amber,
    ),
    PortfolioApp(
      id: 'drone_controller',
      name: 'Drone Control',
      icon: Icons.flight_takeoff,
      category: AppCategory.mechatronics,
      appBuilder: (context) => const DroneController(),
      description: 'Mobile-style UI with joystick overlays',
      color: Colors.deepOrange,
      iconColor: Colors.white,
    ),
    // Category 2: Events & Community
    PortfolioApp(
      id: 'tech_fest',
      name: 'Tech Fest',
      icon: Icons.event,
      category: AppCategory.events,
      appBuilder: (context) =>
          const Center(child: Text("Tech Fest Landing Page Placeholder")),
      description: 'University hackathon landing page',
      color: Colors.deepPurple,
      iconColor: Colors.cyanAccent,
    ),
    PortfolioApp(
      id: 'esports_bracket',
      name: 'E-Sports',
      icon: Icons.sports_esports,
      category: AppCategory.events,
      appBuilder: (context) =>
          const Center(child: Text("E-Sports Bracket Placeholder")),
      color: Colors.indigo,
      iconColor: Colors.pinkAccent,
    ),

    // Category 3: SaaS
    PortfolioApp(
      id: 'crm_admin',
      name: 'CRM Admin',
      icon: Icons.analytics,
      category: AppCategory.saas,
      appBuilder: (context) => const CrmAdmin(),
      color: Colors.blueGrey,
      iconColor: Colors.tealAccent,
    ),

    // Category 4: Journey
    PortfolioApp(
      id: 'flight_booking',
      name: 'Flight Booking',
      icon: Icons.flight,
      category: AppCategory.journey,
      appBuilder: (context) => const FlightBooking(),
      color: Colors.lightBlue,
      iconColor: Colors.white,
    ),

    // Category 5: Hobbies
    PortfolioApp(
      id: 'crypto_exchange',
      name: 'Crypto Exchange',
      icon: Icons.currency_bitcoin,
      category: AppCategory.hobbies,
      appBuilder: (context) =>
          const Center(child: Text("Crypto Exchange Placeholder")),
      color: Colors.orange,
      iconColor: Colors.black,
    ),
  ];

  static List<PortfolioApp> getAppsByCategory(AppCategory category) {
    return apps.where((app) => app.category == category).toList();
  }

  static Map<String, List<PortfolioApp>> get groupedApps {
    return {
      'Mechatronics': getAppsByCategory(AppCategory.mechatronics),
      'Events': getAppsByCategory(AppCategory.events),
      'SaaS': getAppsByCategory(AppCategory.saas),
      'Journey': getAppsByCategory(AppCategory.journey),
      'Hobbies': getAppsByCategory(AppCategory.hobbies),
    };
  }
}
