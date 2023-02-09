// ignore_for_file: public_member_api_docs, sort_constructors_first
class Note {
  late int? noteID;
  late int? categoryID;
  late String categoryName;
  late String? noteHeader;
  late String? noteContent;
  late String? noteDate;
  late int? notePriority;
  Note({
    required this.categoryID,
    required this.noteHeader,
    required this.noteContent,
    required this.noteDate,
    required this.notePriority,
  }); //verileri yazarken
  Note.withID({
    required this.noteID,
    required this.categoryID,
    required this.noteHeader,
    required this.noteContent,
    required this.noteDate,
    required this.notePriority,
  }); //verileri okurken

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['categoryID'] = categoryID;
    map['noteHeader'] = noteHeader;
    map['noteContent'] = noteContent;
    map['noteDate'] = noteDate;
    map['notePriority'] = notePriority;
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.categoryName = map['categoryName'];
    this.noteID = map['noteID'];
    this.categoryID = map['categoryID'];
    this.noteHeader = map['noteHeader'];
    this.noteContent = map['noteContent'];
    this.noteDate = map['noteDate'];
    this.notePriority = map['notePriority'];
  }

  @override
  String toString() {
    return 'Note(noteID: $noteID, categoryID: $categoryID, noteHeader: $noteHeader, noteContent: $noteContent, noteDate: $noteDate, notePriority: $notePriority)';
  }
}
