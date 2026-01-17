import 'dart:math';

class Flight {
  final String id;
  final String airline;
  final String flightNumber;
  final String departureCity; // Code e.g. NYC
  final String departureTime;
  final String arrivalCity; // Code e.g. LON
  final String arrivalTime;
  final String duration;
  final double price;
  final bool isBestValue;

  Flight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.departureCity,
    required this.departureTime,
    required this.arrivalCity,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    this.isBestValue = false,
  });
}

class FlightApiService {
  // Simulate network delay
  Future<List<Flight>> searchFlights(
    String from,
    String to,
    DateTime date,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Fake API latency

    final Random rng = Random();
    final List<String> airlines = [
      "Delta",
      "United",
      "Emirates",
      "Air France",
      "British Airways",
      "Lufthansa",
    ];

    // Generate 5-10 random flight results
    int count = 5 + rng.nextInt(5);
    List<Flight> results = [];

    for (int i = 0; i < count; i++) {
      // Logic to create realistic-looking data
      String airline = airlines[rng.nextInt(airlines.length)];
      int infoBase = rng.nextInt(2000) + 100; // Flight Num

      // Time generation
      int depHour = 6 + rng.nextInt(16); // 06:00 to 22:00
      int depMin = rng.nextInt(4) * 15; // 00, 15, 30, 45
      int durationHours = 4 + rng.nextInt(10); // 4 to 14 hours

      // Calculate arrival
      int arrHour = (depHour + durationHours) % 24;

      double price = 300 + rng.nextDouble() * 1000;
      if (airline == "Emirates") price += 200; // Premium

      results.add(
        Flight(
          id: "FL-$infoBase-$i",
          airline: airline,
          flightNumber: "$airline ${rng.nextInt(900) + 100}",
          departureCity: from.toUpperCase(),
          departureTime:
              "${depHour.toString().padLeft(2, '0')}:${depMin.toString().padLeft(2, '0')}",
          arrivalCity: to.toUpperCase(),
          arrivalTime:
              "${arrHour.toString().padLeft(2, '0')}:${depMin.toString().padLeft(2, '0')}",
          duration: "${durationHours}h ${rng.nextInt(60)}m",
          price: price,
          isBestValue: price < 450,
        ),
      );
    }

    // Sort by price
    results.sort((a, b) => a.price.compareTo(b.price));

    return results;
  }
}
