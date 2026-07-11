import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int _userPoints = 150;
  final int _targetPoints = 200;
  final String _referralCode = "AQUAFUN150";
  final _claimController = TextEditingController();
  bool _isClaiming = false;
  bool _hasClaimed = false;

  void _redeemFreePass() async {
    setState(() {
      _isClaiming = true;
    });
    
    final String ticketId = "AQF-FREE-${Random().nextInt(900000) + 100000}";
    final dateStr = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    
    try {
      // Save free ticket to Firestore
      await FirebaseFirestore.instance.collection('tickets').doc(ticketId).set({
        'id': ticketId,
        'customerName': 'Reward Visitor',
        'phone': 'N/A',
        'category': 'VIP',
        'quantity': 1,
        'date': dateStr,
        'status': 'Active',
        'price': 0.0,
        'paymentMethod': 'Reward Points Redemption',
        'transactionId': 'txn_redeem_points',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Log redemption
      await FirebaseFirestore.instance.collection('logs').add({
        'title': "Redeemed Free Pass: VIP Ticket",
        'subtitle': "Ticket ID: $ticketId (200 pts used)",
        'type': 'promo',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _userPoints -= 200;
        _isClaiming = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Pass Redeemed!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: Text("Your Free VIP Pass ($ticketId) has been issued successfully. You can find it in the Tickets list!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isClaiming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Redemption error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void dispose() {
    _claimController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard!"),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _claimReferral() async {
    final code = _claimController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == _referralCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot claim your own referral code!"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isClaiming = true;
    });

    // Simulate database lookup
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      // Log successful referral code claim in Firestore logs collection to sync with dashboard
      await FirebaseFirestore.instance.collection('logs').add({
        'title': "Referral Claimed: Code $code",
        'subtitle': "Claimant received 50 Reward Points",
        'type': 'promo',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _userPoints += 50;
        _isClaiming = false;
        _hasClaimed = true;
        _claimController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Referral code claimed successfully! +50 points added!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isClaiming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error claiming code: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? Colors.blue[200] : Colors.blue[900];
    final progressVal = (_userPoints / _targetPoints).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Offers & Rewards", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Points Milestone
            Text(
              "Your Rewards Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)] 
                      : [Colors.blueAccent, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Points Balance",
                        style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$_userPoints / $_targetPoints PTS",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$_userPoints Reward Points",
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressVal,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _userPoints >= _targetPoints 
                              ? "Milestone achieved! Redeem your FREE VIP Pass now."
                              : "Just ${( _targetPoints - _userPoints )} points away from a FREE VIP Pass!",
                          style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (_userPoints >= _targetPoints) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isClaiming ? null : _redeemFreePass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: _isClaiming
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                          : const Text("Redeem Free VIP Pass", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Refer & Earn Program
            Text(
              "Refer & Earn Program",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Share the AquaFun experience! When a friend books tickets using your code, they get 15% off and you receive 50 Reward Points.",
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "YOUR REFERRAL CODE",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _referralCode,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(_referralCode, "Referral code"),
                          icon: const Icon(Icons.copy_rounded, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    "Received a Code? Claim Points",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _claimController,
                          enabled: !_hasClaimed,
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: _hasClaimed ? "Points Claimed!" : "Enter friend's code...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: (_isClaiming || _hasClaimed) ? null : _claimReferral,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(90, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isClaiming
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_hasClaimed ? "Claimed" : "Claim", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Promos Vault
            Text(
              "Promo Code Vault",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
            ),
            const SizedBox(height: 12),
            _buildPromoCard("SPLASH20", "20% off all bookings.", Icons.water_drop, Colors.blue),
            _buildPromoCard("VIPCLUB", "\$10 off VIP Access passes.", Icons.card_membership, Colors.amber),
            _buildPromoCard("FAMILYPACK", "15% off when booking 3 or more tickets.", Icons.family_restroom, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(String code, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.1, color: Colors.blueAccent),
                    ),
                    InkWell(
                      onTap: () => _copyToClipboard(code, "Promo code"),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Copy",
                          style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
