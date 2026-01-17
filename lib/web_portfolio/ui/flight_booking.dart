import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/flight_service.dart';

class FlightBooking extends StatefulWidget {
  const FlightBooking({super.key});

  @override
  State<FlightBooking> createState() => _FlightBookingState();
}

class _FlightBookingState extends State<FlightBooking> {
  final FlightApiService _api = FlightApiService();

  // State
  bool _isLoading = false;
  List<Flight>? _flights;

  // Controllers
  final TextEditingController _fromController = TextEditingController(
    text: "NYC",
  );
  final TextEditingController _toController = TextEditingController(
    text: "LON",
  );
  final TextEditingController _dateController = TextEditingController(
    text: "12 May",
  );

  Future<void> _searchFlights() async {
    setState(() {
      _isLoading = true;
      _flights = null; // Clear previous
    });

    try {
      final results = await _api.searchFlights(
        _fromController.text,
        _toController.text,
        DateTime.now(), // Mock date for now
      );
      if (mounted) {
        setState(() {
          _flights = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _launchBooking(Flight flight) async {
    // Launch Kayak or generic search for these params
    final Uri url = Uri.https(
      'www.kayak.com',
      '/flights/${flight.departureCity}-${flight.arrivalCity}/2023-05-12',
      {'sort': 'price_a'},
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        body: Column(
          children: [
            // Header / Search Area
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Where to next?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _FlightInput(
                          icon: Icons.flight_takeoff,
                          hint: "From",
                          controller: _fromController,
                        ),
                        const Divider(),
                        _FlightInput(
                          icon: Icons.flight_land,
                          hint: "To",
                          controller: _toController,
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: _FlightInput(
                                icon: Icons.calendar_today,
                                hint: "Date",
                                controller: _dateController,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey[300],
                            ),
                            const Expanded(
                              child: _FlightStaticInput(
                                icon: Icons.person,
                                hint: "Passengers",
                                value: "2 Adults",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _searchFlights,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Search Flights",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Popular Destinations / List
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_flights == null) {
      // Show onboarding / popular
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Best Deals (Mock)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _FlightCardMock(
            from: "NYC",
            to: "LDN",
            price: "\$450",
            time: "6h 30m",
            airline: "Delta",
          ),
          const SizedBox(height: 12),
          _FlightCardMock(
            from: "NYC",
            to: "PAR",
            price: "\$420",
            time: "7h 15m",
            airline: "Air France",
          ),
        ],
      );
    }

    if (_flights!.isEmpty) {
      return const Center(child: Text("No flights found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _flights!.length,
      itemBuilder: (context, index) {
        final flight = _flights![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FlightCard(
            flight: flight,
            onBook: () => _launchBooking(flight),
          ),
        );
      },
    );
  }
}

class _FlightInput extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;

  const _FlightInput({
    required this.icon,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hint,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightStaticInput extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String value;

  const _FlightStaticInput({
    required this.icon,
    required this.hint,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback onBook;

  const _FlightCard({required this.flight, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                flight.airline,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              if (flight.isBestValue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Best Value",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flight.departureCity,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    flight.departureTime,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    flight.duration,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.lightBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(width: 60, height: 1, color: Colors.grey[300]),
                      const Icon(
                        Icons.flight_takeoff,
                        size: 16,
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    flight.arrivalCity,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    flight.arrivalTime,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Book Now"),
              ),
              Text(
                "\$${flight.price.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Temporary Mock Card for Initial State
class _FlightCardMock extends StatelessWidget {
  final String from;
  final String to;
  final String price;
  final String time;
  final String airline;

  const _FlightCardMock({
    required this.from,
    required this.to,
    required this.price,
    required this.time,
    required this.airline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                airline,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    from,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "10:00 AM",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.lightBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(width: 60, height: 1, color: Colors.grey[300]),
                      const Icon(
                        Icons.flight_takeoff,
                        size: 16,
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    to,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "04:30 PM",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
