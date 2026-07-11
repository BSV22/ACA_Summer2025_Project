import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Mock data for weekly chart
  final List<double> _weeklyVisits = [45, 80, 55, 120, 95, 150, 110];
  final List<String> _weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) {
    final headerColor = Theme.of(context).brightness == Brightness.dark ? Colors.blue[200] : Colors.blue[900];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Analytics Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
        builder: (context, ticketsSnapshot) {
          if (ticketsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ticketsSnapshot.hasError) {
            return Center(child: Text("Error loading tickets: ${ticketsSnapshot.error}"));
          }

          final ticketDocs = ticketsSnapshot.data?.docs ?? [];
          double totalRevenue = 0.0;
          int ticketsCount = 0;
          int scannedCount = 0;
          for (var doc in ticketDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final qty = (data['quantity'] as num?)?.toInt() ?? 1;
            ticketsCount += qty;
            totalRevenue += (data['price'] ?? 0.0);
            if (data['status'] == 'Scanned') {
              scannedCount += qty;
            }
          }
          double capacityPercent = 500 > 0 ? (scannedCount / 500.0) : 0.0;
          if (capacityPercent > 1.0) capacityPercent = 1.0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('logs').orderBy('timestamp', descending: true).limit(10).snapshots(),
            builder: (context, logsSnapshot) {
              final logDocs = logsSnapshot.data?.docs ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Text(
                      "Overview Metrics",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
                    ),
                    const SizedBox(height: 12),

                    // Grid of Stats Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard("Total Revenue", "\$${totalRevenue.toStringAsFixed(2)}", Icons.monetization_on, Colors.green),
                        _buildStatCard("Tickets Issued", "$ticketsCount", Icons.confirmation_number, Colors.blue),
                        _buildStatCard("Capacity Occupied", "${(capacityPercent * 100).toInt()}%", Icons.people_alt, Colors.orange),
                        _buildStatCard("Active Promos", "3", Icons.campaign, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly Visitors Chart Section
                    Text(
                      "Weekly Visitor Trends",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total visits this week: 655 visitors",
                            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          // Render the bars of the chart
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(_weeklyVisits.length, (idx) {
                              final double val = _weeklyVisits[idx];
                              final String day = _weekDays[idx];
                              // Normalize height against max value (150)
                              final double displayHeight = (val / 150) * 120;
                              return Column(
                                children: [
                                  Text(
                                    "${val.toInt()}",
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 22,
                                    height: displayHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blueAccent, Colors.blueAccent.withValues(alpha: 0.5)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    day,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Live Attendance Status Card
                    Text(
                      "Capacity Tracker",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Live Attendance",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$scannedCount visitors inside the park currently. Capacity limit is 500.",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Custom Circular indicator representation
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(
                                  value: capacityPercent,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                ),
                              ),
                              Text(
                                "${(capacityPercent * 100).toInt()}%",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent activity log list
                    Text(
                      "Recent Logs",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
                    ),
                    const SizedBox(height: 12),
                    logsSnapshot.hasError
                        ? Container(
                            height: 100,
                            alignment: Alignment.center,
                            child: Text(
                              "Error loading logs: ${logsSnapshot.error}",
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          )
                        : logsSnapshot.connectionState == ConnectionState.waiting
                            ? Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              )
                            : logDocs.isEmpty
                                ? Container(
                                    height: 100,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "No activity logs yet.",
                                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                    ),
                                  )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logDocs.length,
                            itemBuilder: (context, idx) {
                              final logData = logDocs[idx].data() as Map<String, dynamic>;
                              final title = logData['title'] ?? 'Activity';
                              final subtitle = logData['subtitle'] ?? '';
                              final type = logData['type'] ?? 'check_in';
                              final timestamp = logData['timestamp'] as Timestamp?;
                              
                              String timeText = "Just now";
                              if (timestamp != null) {
                                final diff = DateTime.now().difference(timestamp.toDate());
                                if (diff.inSeconds < 60) {
                                  timeText = "Just now";
                                } else if (diff.inMinutes < 60) {
                                  timeText = "${diff.inMinutes} mins ago";
                                } else if (diff.inHours < 24) {
                                  timeText = "${diff.inHours} hours ago";
                                } else {
                                  timeText = "${diff.inDays} days ago";
                                }
                              }

                              IconData getIcon(String type) {
                                switch (type) {
                                  case 'check_in':
                                    return Icons.check_circle;
                                    case 'issue':
                                    return Icons.add_circle;
                                  case 'error':
                                    return Icons.cancel;
                                  case 'promo':
                                    return Icons.campaign;
                                  default:
                                    return Icons.info;
                                }
                              }

                              Color getColor(String type) {
                                switch (type) {
                                  case 'check_in':
                                    return Colors.green;
                                  case 'issue':
                                    return Colors.blue;
                                  case 'error':
                                    return Colors.red;
                                  case 'promo':
                                    return Colors.purple;
                                  default:
                                    return Colors.grey;
                                }
                              }

                              return _buildActivityLog(title, "$subtitle • $timeText", getIcon(type), getColor(type));
                            },
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final headerColor = Theme.of(context).brightness == Brightness.dark ? Colors.blue[200] : Colors.blue[900];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500]),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: headerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        dense: true,
      ),
    );
  }
}