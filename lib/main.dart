import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:note_app/models/category.dart';
import 'package:note_app/models/notes.dart';
import 'package:note_app/utils/database_helper.dart';
import 'package:note_app/utils/noteDetails.dart';
import 'package:note_app/utils/noteDetailsUpdate.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: NoteList(),
    );
  }
}

class NoteList extends StatefulWidget {
  NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text('Note App'),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'kategori ekle',
            heroTag: 'kategoriEkle',
            onPressed: () {
              addCategoryDialog(context);
            },
            child: Icon(
              Icons.add_circle,
            ),
            mini: true,
          ),
          FloatingActionButton(
            tooltip: 'not ekle',
            heroTag: 'notEkle',
            onPressed: () {
              _goDetailPage(context);
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Notes(),
    );
  }

  Future<dynamic> addCategoryDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    var newCategoryName;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Kategori ekle',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextFormField(
                    onSaved: (newValue) {
                      newCategoryName = newValue;
                    },
                    decoration: InputDecoration(
                        labelText: 'kategori adi',
                        border: OutlineInputBorder()),
                    validator: (enteredCategoryName) {
                      if (enteredCategoryName!.length < 1) {
                        return 'kategori adi bos birakilamaz';
                      }
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'vazgec',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        databaseHelper
                            .addCategory(Category(newCategoryName))
                            .then((categoryID) {
                          if (categoryID > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('kategori eklendi'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: Text(
                      'kaydet',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  _goDetailPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(
                  header: 'new note',
                ))).then((value) => setState(() {}));
  }
}

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late List<Note> allNotes;
  late DatabaseHelper databaseHelper;
  @override
  void initState() {
    super.initState();
    allNotes = <Note>[];
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper.getNoteList(),
      //databasehelperdan note listesini getirdikten sonra builderi calistirir
      builder: (BuildContext context, AsyncSnapshot<List<Note>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          allNotes = snapShot.data!;
          sleep(Duration(milliseconds: 200));
          return ListView.builder(
            itemCount: allNotes.length,
            itemBuilder: (BuildContext context, int index) {
              return ExpansionTile(
                title: Text(
                  allNotes[index].noteHeader.toString(),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kategori: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          allNotes[index].categoryName,
                          style: TextStyle(color: Colors.blueGrey),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Olusturulma Tarihi: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          databaseHelper.dateFormat(
                            DateTime.parse(
                              allNotes[index].noteDate.toString(),
                            ),
                          ),
                          style: TextStyle(color: Colors.blueGrey),
                        )
                      ],
                    ),
                  ),
                  Text(allNotes[index].noteContent.toString()),
                  ButtonBar(
                    children: [
                      TextButton(
                        onPressed: () {
                          _deleteNote(allNotes[index].noteID);
                        },
                        child: Text(
                          'Sil',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _goDetailPage(context, allNotes[index]);
                        },
                        child: Text(
                          'Guncelle',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  )
                ],
                subtitle: Text(allNotes[index].categoryName),
              );
            },
          );
        } else {
          return Center(child: Text('yukleniyor..'));
        }
      },
    );
  }

  _goDetailPage(BuildContext context, Note note) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail2(
                  header: 'notu duzenle',
                  updatedNote: note,
                ))).then((value) => setState(() {}));
  }

  _deleteNote(int? noteID) {
    databaseHelper.deleteNote(noteID!.toInt()).then((deletedID) {
      if (deletedID != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('not silindi'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
    setState(() {});
  }
}
