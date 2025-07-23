import 'package:flutter/material.dart';

class DarshCards extends StatefulWidget {
  const DarshCards({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.ontap,
  });
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback ontap;

  // const DarshCards({Key? key, required this.title, this.ctrl}) : super(key: key);

  @override
  State<DarshCards> createState() => _DarshCardsState();
}

class _DarshCardsState extends State<DarshCards> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 143,

      // margin: EdgeInsets.symmetric(horizontal: , vertical: 12),
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 50, color: widget.color),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.desc,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
