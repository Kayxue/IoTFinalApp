import 'package:flutter/material.dart';

import '../Types/slotdata.dart';

class SlotProgress extends StatelessWidget {
  final SlotData? slotData;

  const SlotProgress({super.key, this.slotData});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              Text(
                (slotData != null
                    ? "${slotData?.avaliableSlots ?? 0}/${slotData?.totalSlots ?? 0} available"
                    : "Loading"),
                style: TextStyle(
                  color:
                      ((slotData != null
                          ? (slotData!.avaliableSlots > 0
                              ? Colors.black
                              : Colors.red)
                          : Colors.black)),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value:
                  (slotData != null
                      ? slotData!.avaliableSlots / slotData!.totalSlots
                      : 0),
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
