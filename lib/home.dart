import 'package:appp/AuthWidget/actiions_cards.dart';
import 'package:appp/AuthWidget/dashboard_cards.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'admin@waterpark.com';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerTextColor = isDark ? Colors.blue[200] : Colors.blue[900];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dashboard stats updated!'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
        builder: (context, snapshot) {
          int todaysTicketsCount = 0;
          double totalRevenue = 0.0;

          if (snapshot.hasData) {
            final now = DateTime.now();
            final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final ticketDate = data['date'] as String?;
              final price = (data['price'] as num?)?.toDouble() ?? 0.0;

              if (ticketDate == todayStr) {
                todaysTicketsCount += (data['quantity'] as num?)?.toInt() ?? 1;
              }
              totalRevenue += price;
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Banner Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                            ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)] 
                            : [Colors.blue.shade700, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            userEmail,
                            style: const TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row 1
                  Row(
                    children: [
                      Expanded(
                        child: DarshCards(
                          icon: Icons.confirmation_num,
                          color: Colors.green,
                          title: "$todaysTicketsCount",
                          desc: "Today's tickets",
                          ontap: () {
                            Navigator.pushNamed(context, '/tickets');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DarshCards(
                          icon: Icons.attach_money_rounded,
                          color: Colors.orange,
                          title: "\$${totalRevenue.toStringAsFixed(2)}",
                          desc: "Total revenue",
                          ontap: () {
                            Navigator.pushNamed(context, '/analytics');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats Row 2
                  Row(
                    children: [
                      Expanded(
                        child: DarshCards(
                          icon: Icons.local_offer,
                          color: Colors.purple,
                          title: "3",
                          desc: "Active offers",
                          ontap: () {
                            Navigator.pushNamed(context, '/rewards');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DarshCards(
                          icon: Icons.qr_code_scanner_rounded,
                          color: Colors.blue,
                          title: "Quick Scan",
                          desc: "Verify QR Code",
                          ontap: () {
                            Navigator.pushNamed(context, '/qrScanner');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section Title
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: headerTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions Row 1
                  Row(
                    children: [
                      Expanded(
                        child: ActionsCards(
                          icon: Icons.edit_note_rounded,
                          color: Colors.blue,
                          title: "Manage Ticket",
                          ontap: () {
                            Navigator.pushNamed(context, '/addTicket');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionsCards(
                          icon: Icons.campaign_rounded,
                          color: Colors.orange,
                          title: "Offers & Rewards",
                          ontap: () {
                            Navigator.pushNamed(context, '/rewards');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Actions Row 2
                  Row(
                    children: [
                      Expanded(
                        child: ActionsCards(
                          icon: Icons.analytics_rounded,
                          color: Colors.green,
                          title: "Analytics",
                          ontap: () {
                            Navigator.pushNamed(context, '/analytics');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionsCards(
                          icon: Icons.settings,
                          color: Colors.grey,
                          title: "Settings",
                          ontap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        onTap: (index) {
          if (index == 0) {
            // Already on Dashboard, do nothing
          } else if (index == 1) {
            Navigator.pushNamed(context, '/qrScanner');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/analytics');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }
}
