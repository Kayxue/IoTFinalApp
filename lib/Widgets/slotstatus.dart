import 'package:flutter/material.dart';
import 'package:parking/Types/slotdata.dart';

class SlotStatus extends StatelessWidget {
  const SlotStatus({
    super.key,
    required ParkingDataState state,
  }) : _state = state;

  final ParkingDataState _state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
            ),
        itemCount: _state.data!.slots.length,
        itemBuilder: (context, index) {
          final occupied = _state.data!.slots[index];
          return Card(
            color:
                occupied ? Colors.red[100] : Colors.green[100],
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        '車位 #${index + 1}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      occupied
                          ? Icons.directions_car
                          : Icons.check_box_outline_blank,
                      color:
                          occupied ? Colors.red : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        occupied ? '有車' : '空位',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
