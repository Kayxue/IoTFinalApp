class SlotData {
  List<bool> slots = List.filled(10, false);
  int totalSlots = 6;
  int avaliableSlots = 6;
  bool gateOpen = false;
  bool systemReady = false;

  SlotData({
    required this.slots,
    required this.totalSlots,
    required this.avaliableSlots,
    required this.gateOpen,
    required this.systemReady,
  });
}
