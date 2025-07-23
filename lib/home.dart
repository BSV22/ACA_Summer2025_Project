import 'package:appp/AuthWidget/actiions_cards.dart';
import 'package:appp/AuthWidget/dashboard_cards.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87,
      appBar: AppBar(
        //  automaticallyImplyLeading: false,
        title: Text("Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Refreshed')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          // width: double.infinity,
          // height: double.infinity,
          // singleChildScrollView: true,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 360,
                height: 100,

                // margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'admin@waterpark.com',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DarshCards(
                    icon: Icons.confirmation_num,
                    color: Colors.green,
                    title: "0",
                    desc: "Todays tickets",
                    ontap: () {
                      Navigator.pushNamed(context, '/tickets');
                    },
                  ),
                  DarshCards(
                    icon: Icons.attach_money_rounded,
                    color: Colors.orange,
                    title: "\$0.00",
                    desc: "Total revenue",
                    ontap: () {
                      Navigator.pushNamed(context, '/tickets');
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DarshCards(
                    icon: Icons.local_offer,
                    color: Colors.purple,
                    title: "0",
                    desc: "Active offers",
                    ontap: () {
                      Navigator.pushNamed(context, '/tickets');
                    },
                  ),
                  DarshCards(
                    icon: Icons.qr_code_scanner_rounded,
                    color: Colors.blue,
                    title: "Quick Access",
                    desc: "Scan QR Code",
                    ontap: () {
                      Navigator.pushNamed(context, '/tickets');
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionsCards(
                    icon: Icons.edit_note_rounded,
                    color: Colors.blue,
                    title: "Manage Ticket",
                    ontap: () {
                      Navigator.pushNamed(context, '/addTicket');
                    },
                  ),
                  ActionsCards(
                    icon: Icons.campaign_rounded,
                    color: Colors.orange,
                    title: "Offers & Notifications",
                    ontap: () {
                      Navigator.pushNamed(context, '/addTicket');
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionsCards(
                    icon: Icons.analytics_rounded,
                    color: Colors.green,
                    title: "Analytics",
                    ontap: () {
                      Navigator.pushNamed(context, '/qrScanner');
                    },
                  ),
                  ActionsCards(
                    icon: Icons.settings,
                    color: Colors.grey,
                    title: "Settings",
                    ontap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/addTicket');
      //   },
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.blueAccent,
      // ),
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
        //     items: [
        //   BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        //   BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
        //   BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        //   BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        // ],
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/qrScanner');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/analytics');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/settings');
          }
          // Handle navigation based on index
        },
      ),
    );
  }
}
