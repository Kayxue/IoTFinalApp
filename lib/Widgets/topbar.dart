import 'package:flutter/material.dart';
import 'package:parking/Utils/OpenMap.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),

      child: Card(
        color: Colors.blue,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.grey.withAlpha(40),
          onTap: () {
            MapUtils.openMap(25.048823984664, 121.506254973427);
          },
          child: Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    radius: 40,
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
