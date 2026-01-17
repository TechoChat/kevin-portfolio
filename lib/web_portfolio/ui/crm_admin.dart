import 'package:flutter/material.dart';

class CrmAdmin extends StatelessWidget {
  const CrmAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        cardColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Nexus CRM",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            const CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 16,
              child: Text(
                "JD",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard Overview",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Metrics Row
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive wrap
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MetricCard(
                        title: "Total Revenue",
                        value: "\$128,430",
                        trend: "+12.5%",
                        color: Colors.blue,
                      ),
                      _MetricCard(
                        title: "Active Users",
                        value: "2,543",
                        trend: "+3.2%",
                        color: Colors.green,
                      ),
                      _MetricCard(
                        title: "New Leads",
                        value: "432",
                        trend: "-0.8%",
                        color: Colors.orange,
                      ),
                      _MetricCard(
                        title: "Conversion",
                        value: "2.4%",
                        trend: "+0.1%",
                        color: Colors.purple,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Recent Transactions Table
              const Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                      title: Text("Company ${String.fromCharCode(65 + index)}"),
                      subtitle: Text(
                        "Invoice #${1000 + index} • Today, 12:30 PM",
                      ),
                      trailing: Text(
                        "\$${(100 + index * 50).toString()}.00",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.teal,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed width for metric cards or flexible? let's do fixed width constraint
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.trending_up, size: 16, color: color),
              ),
              const Spacer(),
              Text(
                trend,
                style: TextStyle(
                  color: trend.startsWith('-') ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
