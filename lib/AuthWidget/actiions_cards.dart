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
    return SizedBox(
      width: 160,
      height: 148,
      child: Card(
        color: Theme.of(context).cardColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.ontap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 44, color: widget.color),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
