import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => QrScannerState();
}

class QrScannerState extends State<QrScanner> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _manualCodeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    // Bouncing animation for the laser line
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _manualCodeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _verifyTicket(String code) async {
    // Temporarily pause the scanner controller to avoid duplicate scans
    await _scannerController.stop();

    if (!mounted) return;

    // Show a loading indicator while fetching from Firestore
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final doc = await FirebaseFirestore.instance.collection('tickets').doc(code).get();
      
      if (!mounted) return;
      Navigator.pop(context); // Pop the loading indicator

      bool isValid = false;
      String visitorName = "N/A";
      String category = "N/A";
      String quantity = "N/A";
      String status = "Not Found";
      String errorMessage = "This ticket does not exist in the database.";

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        visitorName = data['customerName'] ?? 'Unknown';
        category = data['category'] ?? 'Adult';
        quantity = "${data['quantity'] ?? 1} Person(s)";
        status = data['status'] ?? 'Active';
        
        if (status == 'Active') {
          isValid = true;
        } else if (status == 'Scanned') {
          isValid = false;
          errorMessage = "This ticket has already been scanned and checked in.";
        } else if (status == 'Expired') {
          isValid = false;
          errorMessage = "This ticket has expired and is no longer valid.";
        }
      }

      final sheetResult = await showModalBottomSheet<bool>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  isValid ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
                  color: isValid ? Colors.green : Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  isValid ? "Ticket Verified Successfully!" : "Verification Failed!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isValid ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Code: $code",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(height: 24),
                if (doc.exists) ...[
                  _buildInfoRow("Visitor", visitorName),
                  _buildInfoRow("Category", category),
                  _buildInfoRow("Quantity", quantity),
                  _buildInfoRow("Status", status),
                ] else ...[
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
                if (!isValid && doc.exists && status != 'Active') ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: isValid ? Colors.green : Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isValid ? "Confirm" : "Reject",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

      if (sheetResult == true) {
        if (isValid) {
          // Update ticket status in Firestore
          await FirebaseFirestore.instance.collection('tickets').doc(code).update({
            'status': 'Scanned',
          });

          // Write check-in log
          await FirebaseFirestore.instance.collection('logs').add({
            'title': "Check-in: $visitorName scanned $category Ticket",
            'subtitle': "$quantity - Successful scan",
            'type': 'check_in',
            'timestamp': FieldValue.serverTimestamp(),
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Check-in completed successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Write failure log
          await FirebaseFirestore.instance.collection('logs').add({
            'title': "Check-in failed: Code $code ($status)",
            'subtitle': errorMessage,
            'type': 'error',
            'timestamp': FieldValue.serverTimestamp(),
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ticket check-in rejected!"),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Pop the QrScanner page on both outcomes
        if (mounted) {
          Navigator.of(context).pop();
        }
      }

    } catch (e) {
      if (!mounted) return;
      // Make sure loader is popped on error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying ticket: $e"), backgroundColor: Colors.red),
      );
    }

    // Resume scanning when sheet dismissed
    await _scannerController.start();
  }

  Widget _buildInfoRow(String label, String value) {
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
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.black87,
      appBar: AppBar(
        title: const Text("Scan QR Code", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (viewfinder and instructions) expands to center content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Header Instructions
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Align the ticket QR code within the frame to automatically scan and verify entry.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Animated Scanner Reticle Viewport
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4), width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              // Live Camera Viewfinder
                              Positioned.fill(
                                child: MobileScanner(
                                  controller: _scannerController,
                                  onDetect: (capture) {
                                    final List<Barcode> barcodes = capture.barcodes;
                                    if (barcodes.isNotEmpty) {
                                      final String? code = barcodes.first.rawValue;
                                      if (code != null) {
                                        _verifyTicket(code);
                                      }
                                    }
                                  },
                                ),
                              ),
                              // Corner Markers for scanner focus
                              ..._buildCornerMarkers(),
                              // Bouncing Laser Line
                              AnimatedBuilder(
                                animation: _animationController,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent.withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                builder: (context, child) {
                                  return Positioned(
                                    top: 15 + (_animationController.value * 210), // Bounce range
                                    left: 15,
                                    right: 15,
                                    child: child!,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Simulation Buttons Panel securely anchored at the bottom
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Scanner Simulations",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final activeTickets = await FirebaseFirestore.instance.collection('tickets').where('status', isEqualTo: 'Active').limit(1).get();
                            if (activeTickets.docs.isNotEmpty) {
                              _verifyTicket(activeTickets.docs.first.id);
                            } else {
                              _verifyTicket("AQF-DUMMY1");
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text("Valid Scan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final scannedTickets = await FirebaseFirestore.instance.collection('tickets').where('status', isEqualTo: 'Scanned').limit(1).get();
                            if (scannedTickets.docs.isNotEmpty) {
                              _verifyTicket(scannedTickets.docs.first.id);
                            } else {
                              _verifyTicket("AQF-DUMMY2");
                            }
                          },
                          icon: const Icon(Icons.highlight_off_rounded, color: Colors.white),
                          label: const Text("Invalid Scan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    "Or Enter Ticket Code Manually",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 14, 
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualCodeController,
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: "e.g. AQF-490321",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final code = _manualCodeController.text.trim();
                          if (code.isNotEmpty) {
                            _verifyTicket(code);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(80, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Verify", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Draw 4 aesthetic neon-like scanner corners
  List<Widget> _buildCornerMarkers() {
    const double size = 20;
    const double thickness = 4;
    final color = Colors.blueAccent.shade400;

    return [
      // Top Left
      Positioned(
        top: 10, left: 10,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Top Right
      Positioned(
        top: 10, right: 10,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom Left
      Positioned(
        bottom: 10, left: 10,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom Right
      Positioned(
        bottom: 10, right: 10,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }
}