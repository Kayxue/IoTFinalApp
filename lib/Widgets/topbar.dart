import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:niku/namespace.dart' as n;

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
            MapsLauncher.launchCoordinates(25.04782398, 121.50525497, "洛陽停車場");
          },
          child: Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: n.Row([
              n.Column([
                  n.Text("洛陽停車場")
                    ..color = Colors.white
                    ..fontSize = 24
                    ..fontWeight = FontWeight.bold,
                  SizedBox(height: 4),
                  n.Text("台北市萬華區環河南路一段1號")
                    ..color = Colors.white
                    ..fontSize = 16
                    ..fontWeight = FontWeight.w500,
                ])
                ..mainCenter
                ..crossStart
                ..padding = const EdgeInsets.only(left: 16.0),
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/Parking_icon.png'),
                ),
              ),
            ])..mainBetween,
          ),
        ),
      ),
    );
  }
}
