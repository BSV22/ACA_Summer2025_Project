import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();
  
  double _discountAmount = 0.0;
  String _appliedPromo = "";
  String _promoError = "";
  
  String _selectedCategory = "Adult"; // 'Adult', 'Child', 'VIP'
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();

  final Map<String, double> _prices = {
    "Adult": 25.0,
    "Child": 15.0,
    "VIP": 50.0,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double get _subtotalPrice => (_prices[_selectedCategory] ?? 0.0) * _quantity;
  double get _totalPrice => (_subtotalPrice - _discountAmount).clamp(0.0, double.infinity);

  void _recalculateDiscount() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _discountAmount = 0.0;
      _appliedPromo = "";
      _promoError = "";
      return;
    }
    
    if (code == "SPLASH20") {
      _discountAmount = _subtotalPrice * 0.20;
      _appliedPromo = "SPLASH20 (20% Off)";
      _promoError = "";
    } else if (code == "VIPCLUB") {
      if (_selectedCategory == "VIP") {
        _discountAmount = 10.0 * _quantity;
        _appliedPromo = "VIPCLUB (\$10 Off VIP)";
        _promoError = "";
      } else {
        _discountAmount = 0.0;
        _appliedPromo = "";
        _promoError = "Code only valid for VIP category!";
      }
    } else if (code == "FAMILYPACK") {
      _discountAmount = _subtotalPrice * 0.15;
      _appliedPromo = "FAMILYPACK (15% Off)";
      _promoError = "";
    } else {
      _discountAmount = 0.0;
      _appliedPromo = "";
      _promoError = "Invalid Promo Code!";
    }
  }

  void _applyPromoCode() {
    setState(() {
      _recalculateDiscount();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _generateTicket() {
    if (!_formKey.currentState!.validate()) return;
    
    final String ticketId = "AQF-${Random().nextInt(900000) + 100000}";
    _showPaymentSheet(ticketId);
  }

  void _showPaymentSheet(String ticketId) {
    final TextEditingController cardController = TextEditingController(text: "4242 4242 4242 4242");
    final TextEditingController expiryController = TextEditingController(text: "12/28");
    final TextEditingController cvvController = TextEditingController(text: "123");
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        bool processing = false;
        
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50, height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Stripe Checkout Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        "\$${_totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (processing) ...[
                    const SizedBox(height: 40),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16),
                    const Text(
                      "Authorizing Stripe Payment...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    TextField(
                      controller: cardController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Card Number",
                        prefixIcon: const Icon(Icons.credit_card_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryController,
                            decoration: InputDecoration(
                              labelText: "Expiry (MM/YY)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "CVV",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "Secured with Stripe payment gateway",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        setSheetState(() {
                          processing = true;
                        });
                        
                        // Simulate payment gateway response delay
                        await Future.delayed(const Duration(seconds: 2));
                        
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                          _generateTicketDoc(ticketId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Pay \$${_totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _generateTicketDoc(String ticketId) async {
    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final String stripeTxnId = "txn_stripe_${Random().nextInt(9000000) + 1000000}";
      
      // Save ticket to Firestore
      await FirebaseFirestore.instance.collection('tickets').doc(ticketId).set({
        'id': ticketId,
        'customerName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'quantity': _quantity,
        'date': dateStr,
        'status': 'Active',
        'price': _totalPrice,
        'paymentMethod': 'Stripe Card (Simulated)',
        'transactionId': stripeTxnId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Log payment success in logs collection
      await FirebaseFirestore.instance.collection('logs').add({
        'title': "Payment Processed: \$${_totalPrice.toStringAsFixed(2)}",
        'subtitle': "Stripe Card • TXN: $stripeTxnId",
        'type': 'check_in',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Log ticket issuance in logs collection
      await FirebaseFirestore.instance.collection('logs').add({
        'title': "New ticket issued: ${_nameController.text.trim()} ($_selectedCategory)",
        'subtitle': "${_quantity}x tickets - ID: $ticketId",
        'type': 'issue',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return;
      Navigator.pop(context); // Pop loading spinner

      _showSuccessDialog(ticketId);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading spinner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating ticket: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog(String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Ticket Generated!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                "The ticket has been successfully registered.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 20),
              // Simulated QR code
              Container(
                width: 140,
                height: 140,
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
                      final isBlack = (idx % 3 == 0 && idx % 2 != 0) ||
                          (idx < 8 && idx % 2 == 0) ||
                          (idx > 28 && idx % 3 != 0) ||
                          (idx % 6 == 1) ||
                          (idx % 6 == 4);
                      return Container(
                        color: isBlack ? Colors.black : Colors.white,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ticketId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow("Name", _nameController.text.trim()),
              _buildSummaryRow("Category", _selectedCategory),
              _buildSummaryRow("Quantity", "$_quantity"),
              _buildSummaryRow("Total Paid", "\$${_totalPrice.toStringAsFixed(2)}"),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to dashboard/tickets list
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    _recalculateDiscount();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("New Ticket", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                "Issue Park Ticket",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.blue[200] : Colors.blue[900],
                ),
              ),
              Text(
                "Fill in the visitor details to create a park entry ticket.",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Customer Name Input
              const Text("Visitor Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Enter full name",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number Input
              const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Enter mobile number",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selection Header
              const Text("Ticket Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              // Category Row (Selectable Cards)
              Row(
                children: [
                  _buildCategoryCard("Adult", "\$25", Icons.person_rounded),
                  const SizedBox(width: 10),
                  _buildCategoryCard("Child", "\$15", Icons.child_care_rounded),
                  const SizedBox(width: 10),
                  _buildCategoryCard("VIP", "\$50", Icons.star_rounded),
                ],
              ),
              const SizedBox(height: 20),

              // Quantity Selector and Date picker Row
              Row(
                children: [
                  // Quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.blueAccent),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                },
                              ),
                              Text(
                                "$_quantity",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.blueAccent),
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Date Picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Date of Visit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.calendar_month, color: Colors.blueAccent),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Promo Code Section
              const Text("Promo Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: InputDecoration(
                        hintText: "Enter promo code (e.g. SPLASH20)",
                        hintStyle: const TextStyle(color: Colors.grey),
                        errorText: _promoError.isNotEmpty ? _promoError : null,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyPromoCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(80, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Divider
              Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey[300]),
              const SizedBox(height: 16),

              // Pricing Breakdown and Action Button Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[900]?.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal ($_selectedCategory x $_quantity)",
                          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                        ),
                        Text(
                          "\$${_subtotalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (_discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Promo Discount (${_appliedPromo.split(' ').first})",
                            style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "-\$${_discountAmount.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${_totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _generateTicket,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Generate Ticket",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String price, IconData icon) {
    final isSelected = _selectedCategory == title;
    final color = title == "VIP"
        ? Colors.amber.shade800
        : (title == "Adult" ? Colors.teal : Colors.purple);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[500],
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color.withValues(alpha: 0.8) : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
