import 'package:flutter/material.dart';
import 'package:parking/Utils/OpenMap.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onTap;
  const TopBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
      child: Card(
        color: Colors.blue,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.grey.withAlpha(40),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "洛陽停車場",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/Parking_icon.png'),
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
