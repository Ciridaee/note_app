// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:note_app/models/category.dart';
import 'package:note_app/models/notes.dart';
import 'package:note_app/utils/database_helper.dart';

/*GlobalKey : Tüm uygulama boyunca benzersiz olan bir anahtar. GlobalKey öğeleri benzersiz şekilde anahtar atar.
FormState: Bir FormState nesnesi, ilişkili Form'un altındaki form alanlarını kaydetmek/save, sıfırlamak/reset ve doğrulamak/validate için kullanılabilir.
Herhangi bir zamanda form değerlerini kaydetmek, almak ve ayrıca doğrulama amacıyla GlobalKey bir anahtar oluşturmamız gerekir. */
class NoteDetail2 extends StatefulWidget {
  String header;
  Note updatedNote;
  NoteDetail2({Key? key, required this.header, required this.updatedNote})
      : super(key: key);

  @override
  State<NoteDetail2> createState() => _NoteDetailState2();
}

class _NoteDetailState2 extends State<NoteDetail2> {
  var formKey = GlobalKey<FormState>();
  late List<Category> allCategories;
  late DatabaseHelper databaseHelper;

  int? categoryID = 1;
  int? chosenPriority = 0;
  String? noteHeader, noteContent;
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
                initialValue: widget.updatedNote != null
                    ? widget.updatedNote.noteHeader
                    : '',
                validator: (text) {
                  if (text!.isEmpty) {
                    return 'Baslik adi bos olamaz';
                  }
                },
                onSaved: (text) {
                  noteHeader = text;
                },
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
                initialValue: widget.updatedNote != null
                    ? widget.updatedNote.noteContent
                    : '',
                onSaved: (text) {
                  noteContent = text;
                },
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('vazgec'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      var now = DateTime.now();
                      databaseHelper
                          .addNote(Note(
                              categoryID: categoryID,
                              noteHeader: noteHeader,
                              noteContent: noteContent,
                              noteDate: now.toString(),
                              notePriority: chosenPriority))
                          .then((savedNoteID) => Navigator.pop(context));
                    }
                  },
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
