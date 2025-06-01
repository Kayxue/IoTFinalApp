import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

import '../Types/slotdata.dart';

class SlotDataWidget extends StatelessWidget {
  final SlotData? slotData;

  const SlotDataWidget({super.key, this.slotData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
        ),
        physics: NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total Spots",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    (slotData != null
                        ? AnimatedFlipCounter(
                          value: slotData!.totalSlots,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                        )
                        : Text(
                          "Loading",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Remaining Spots",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    (slotData != null
                        ? AnimatedFlipCounter(
                          value: slotData!.avaliableSlots,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                        )
                        : Text(
                          "Loading",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color:
                                ((slotData != null
                                    ? (slotData!.avaliableSlots > 0
                                        ? Colors.black
                                        : Colors.red)
                                    : Colors.black)),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
