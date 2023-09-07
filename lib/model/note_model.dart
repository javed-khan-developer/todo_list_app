class Note {
  int? id;
  String? title;
  String? priority;
  DateTime? date;
  int? status;
// Constructor for creating a new note
  Note({
    this.title,
    this.priority,
    this.date,
    this.status,
  });

  // Constructor for creating a new note with an ID
  Note.withId({
    this.id,
    this.title,
    this.priority,
    this.date,
    this.status,
  });

  // Convert the Note object to a Map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['priority'] = priority;
    map['date'] =
        date!.toIso8601String(); // Convert DateTime to ISO 8601 string
    map['status'] = status;
    return map;
  }

  // method to create a Note object from a Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note.withId(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']), // Parse ISO 8601 string to DateTime
      priority: map['priority'],
      status: map['status'],
    );
  }
}
