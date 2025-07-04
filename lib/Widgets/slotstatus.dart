import 'package:flutter/material.dart';
import 'package:parking/Types/slotdata.dart';
import 'package:niku/namespace.dart' as n;

class SlotStatus extends StatelessWidget {
  const SlotStatus({super.key, required ParkingDataState state})
    : _state = state;

  final ParkingDataState _state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: n.GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          final occupied = _state.data!.slots[index];
          return Card(
            color: occupied ? Colors.red[100] : Colors.green[100],
            child:
                n.Column([
                    Expanded(child: n.Text('車位 #${index + 1}')..fontSize = 11),
                    const SizedBox(height: 2),
                    n.Icon(
                        occupied
                            ? Icons.directions_car
                            : Icons.check_box_outline_blank,
                      )
                      ..color = occupied ? Colors.red : Colors.green
                      ..size = 18,
                    const SizedBox(height: 2),
                    Expanded(
                      child: n.Text(occupied ? '有車' : '空位')..fontSize = 11,
                    ),
                  ])
                  ..mainCenter
                  ..mainAxisSize = MainAxisSize.min
                  ..center
                  ..padding = const EdgeInsets.all(4.0),
          );
        },
      )..itemCount = _state.data!.slots.length,
    );
  }
}
