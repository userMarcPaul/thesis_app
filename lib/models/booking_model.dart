class BookingModel {
  final String bookingId;
  final String creativeId;
  final String clientId;
  final String creativeName;
  final String clientName;
  final DateTime date;
  final String time;
  final String status;
  final String details;

  BookingModel({
    required this.bookingId,
    required this.creativeId,
    required this.clientId,
    required this.creativeName,
    required this.clientName,
    required this.date,
    required this.time,
    required this.status,
    required this.details,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'],
      creativeId: map['creativeId'],
      clientId: map['clientId'],
      creativeName: map['creativeName'],
      clientName: map['clientName'],
      date: (map['date'] as dynamic).toDate(),
      time: map['time'],
      status: map['status'],
      details: map['details'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'creativeId': creativeId,
      'clientId': clientId,
      'creativeName': creativeName,
      'clientName': clientName,
      'date': date,
      'time': time,
      'status': status,
      'details': details,
    };
  }
}
