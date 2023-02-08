import 'dart:core';

class Category {
  int? categoryID;
  late String categoryName;

  Category(
      this.categoryName); //kategori eklerken kullanilir cunku id db tarafindan olusturuluyor
  Category.withID(
      this.categoryID, this.categoryName); //kategorileri dbden okurken kullan

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['categoryID'] = categoryID;
    map['categoryName'] = categoryName;
    return map;
  }

  Category.fromMap(Map<String, dynamic> map) {
    categoryID = map['categoryID'];
    categoryName = map['categoryName'];
  }

  @override
  String toString() {
    return 'category{categoryID : $categoryID, categoryName : $categoryName}';
  }
}
