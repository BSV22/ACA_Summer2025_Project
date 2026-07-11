import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String customerName;
  final String phone;
  final String category;
  final int quantity;
  final String date;
  final String status; // 'Active', 'Scanned', 'Expired'

  TicketModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.category,
    required this.quantity,
    required this.date,
    required this.status,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      phone: data['phone'] ?? '',
      category: data['category'] ?? 'Adult',
      quantity: data['quantity'] ?? 1,
      date: data['date'] ?? '',
      status: data['status'] ?? 'Active',
    );
  }
}

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  String _searchQuery = "";
  String _selectedFilter = "All"; // 'All', 'Active', 'Scanned', 'Expired'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("AquaFun Tickets", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading tickets: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];
          final ticketsList = docs.map((doc) => TicketModel.fromFirestore(doc)).toList();

          final filteredTickets = ticketsList.where((ticket) {
            final matchesSearch = ticket.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                ticket.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                ticket.phone.contains(_searchQuery);

            final matchesFilter = _selectedFilter == "All" || ticket.status == _selectedFilter;

            return matchesSearch && matchesFilter;
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search by ticket ID, name, or phone...",
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                    ),
                    constraints: const BoxConstraints(maxHeight: 50),
                  ),
                ),
              ),

              // Filters Selection Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Row(
                  children: ["All", "Active", "Scanned", "Expired"].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }
                        },
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.blueAccent.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Tickets List
              Expanded(
                child: filteredTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              "No tickets found",
                              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = filteredTickets[index];
                          return _buildTicketCard(ticket);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/addTicket');
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Ticket", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTicketCard(TicketModel ticket) {
    Color statusColor;
    switch (ticket.status) {
      case "Active":
        statusColor = Colors.green;
        break;
      case "Scanned":
        statusColor = Colors.blue;
        break;
      case "Expired":
      default:
        statusColor = Colors.red;
    }

    Color categoryColor;
    switch (ticket.category) {
      case "VIP":
        categoryColor = Colors.amber.shade800;
        break;
      case "Adult":
        categoryColor = Colors.teal;
        break;
      case "Child":
      default:
        categoryColor = Colors.purple;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTicketDetailsDialog(ticket),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ticket Icon Left Box
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.confirmation_number_rounded, color: categoryColor, size: 30),
              ),
              const SizedBox(width: 16),
              // Content Middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticket.id,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ticket.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ticket.customerName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.category,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Qty: ${ticket.quantity}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Text(
                          ticket.date,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Trailing QR code trigger
              IconButton(
                icon: const Icon(Icons.qr_code_2_rounded, color: Colors.blueAccent, size: 28),
                onPressed: () => _showTicketDetailsDialog(ticket),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketDetailsDialog(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Ticket Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
              const SizedBox(height: 16),
              // Simulated QR code using Grid
              Container(
                width: 160,
                height: 160,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                    ),
                    itemCount: 36,
                    itemBuilder: (context, idx) {
                      // Generate a mock QR-like pattern
                      final isBlack = (idx % 2 == 0 && idx % 3 != 0) ||
                          (idx < 6 && idx % 2 == 0) ||
                          (idx > 30 && idx % 2 != 0) ||
                          (idx % 6 == 0) ||
                          (idx % 6 == 5);
                      return Container(
                        color: isBlack ? Colors.black : Colors.white,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ticket.id,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
              ),
              const SizedBox(height: 16),
              _buildDetailRow("Name", ticket.customerName),
              _buildDetailRow("Phone", ticket.phone),
              _buildDetailRow("Category", ticket.category),
              _buildDetailRow("Quantity", "${ticket.quantity}"),
              _buildDetailRow("Visit Date", ticket.date),
              _buildDetailRow("Status", ticket.status),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
