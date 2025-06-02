import 'package:flutter/material.dart';

import '../Types/slotdata.dart';

class SlotProgress extends StatelessWidget {
  final ParkingDataState state;

  const SlotProgress({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Parking Availability",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text("Loading...", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Parking Availability",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  "Error",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final slotData = state.data;
    if (slotData == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Parking Availability",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text("No data", style: TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Parking Availability",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                "${slotData.avaliableSlots}/${slotData.totalSlots} available",
                style: TextStyle(
                  color:
                      slotData.avaliableSlots > 0 ? Colors.black : Colors.red,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: slotData.avaliableSlots / slotData.totalSlots,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                slotData.avaliableSlots > 0 ? Colors.blue : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
