class SlotData {
  List<bool> slots;
  int totalSlots;
  int avaliableSlots;
  bool gateOpen;
  bool systemReady;

  SlotData({
    required this.slots,
    required this.totalSlots,
    required this.avaliableSlots,
    required this.gateOpen,
    required this.systemReady,
  });

  factory SlotData.fromJson(Map<String, dynamic> json) {
    return SlotData(
      slots: List<bool>.from(json['slots'] ?? []),
      totalSlots: json['totalSlots'] ?? 0,
      avaliableSlots: json['avaliableSlots'] ?? 0,
      gateOpen: json['gateOpen'] ?? false,
      systemReady: json['systemReady'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slots': slots,
      'totalSlots': totalSlots,
      'avaliableSlots': avaliableSlots,
      'gateOpen': gateOpen,
      'systemReady': systemReady,
    };
  }
}

class ParkingDataState {
  final SlotData? data;
  final bool isLoading;
  final String? error;

  ParkingDataState({this.data, this.isLoading = false, this.error});

  factory ParkingDataState.loading() {
    return ParkingDataState(isLoading: true);
  }

  factory ParkingDataState.error(String error) {
    return ParkingDataState(error: error);
  }

  factory ParkingDataState.success(SlotData data) {
    return ParkingDataState(data: data);
  }
}
