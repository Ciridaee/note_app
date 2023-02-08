// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:note_app/models/category.dart';
import 'package:note_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  String header;
  NoteDetail({
    Key? key,
    required this.header,
  }) : super(key: key);

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formKey = GlobalKey<FormState>();
  late List<Category> allCategories;
  late DatabaseHelper databaseHelper;
  int? categoryID = 1;
  int? chosenPriority;
  var _priority = ['Dusuk', 'Orta', 'Yuksek'];
  @override
  void initState() {
    super.initState();

    allCategories = <Category>[];
    databaseHelper = DatabaseHelper();
    databaseHelper.getCategories().then((mapListWithCategories) {
      for (Map<String, dynamic> readMap in mapListWithCategories) {
        allCategories.add(Category.fromMap(readMap));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.header),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  child: Text(
                    'Kategori:',
                    style: TextStyle(fontSize: 20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                Container(
                  child: DropdownButtonHideUnderline(
                    child: allCategories.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : DropdownButton<int>(
                            items: createCategoryItems(),
                            alignment: Alignment.center,
                            value: categoryID,
                            onChanged: (chosenCategoryID) {
                              setState(() {
                                categoryID = chosenCategoryID;
                              });
                            },
                          ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                  margin: EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey, width: 1.5),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 11),
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Notun basligini giriniz',
                  labelText: 'baslik',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17)),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 11),
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Notun icerigini giriniz',
                  labelText: 'icerik',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17)),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  child: Text(
                    'oncelik:',
                    style: TextStyle(fontSize: 20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                Container(
                  // ignore: sort_child_properties_last
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      items: _priority
                          .map((priority) => DropdownMenuItem<int>(
                                value: _priority.indexOf(priority),
                                child: Text(priority),
                              ))
                          .toList(),
                      alignment: Alignment.center,
                      onChanged: ((s) {
                        setState(() {
                          chosenPriority = s;
                        });
                      }),
                      value: chosenPriority,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                  margin: EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey, width: 1.5),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('vazgec'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('kaydet'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> createCategoryItems() {
    return allCategories
        .map((category) => DropdownMenuItem<int>(
              value: category.categoryID,
              child: Text(category.categoryName),
            ))
        .toList();
  }
}
