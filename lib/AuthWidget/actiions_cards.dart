import 'package:flutter/material.dart';

class ActionsCards extends StatefulWidget {
  const ActionsCards({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.ontap,
  });
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback ontap;

  // const DarshCards({Key? key, required this.title, this.ctrl}) : super(key: key);

  @override
  State<ActionsCards> createState() => _DarshCardsState();
}

class _DarshCardsState extends State<ActionsCards> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.ontap,
      // splashColor: Colors.blueAccent,
      // highlightColor: Colors.blueAccent.withOpacity(0.2),
      // borderRadius: BorderRadius.circular(16),
      // focusColor: Colors.blueAccent.withOpacity(0.2),
      // hoverColor: Colors.blueAccent.withOpacity(0.2),
      child: SizedBox(
        width: 160,
        height: 148,
        
      
        // margin: EdgeInsets.symmetric(horizontal: , vertical: 12),
        child: Card(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 50, color: widget.color),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
