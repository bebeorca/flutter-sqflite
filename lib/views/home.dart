// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sqf/helper/sql_helper.dart';
import 'package:sqf/models/data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _data = [];
  bool isLoading = true;

  void getData() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _data = data;
      isLoading = false;
    });
    print("..items: ${_data.length}");
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController angkController = TextEditingController();

  Future<void> _addItem() async {
    try {
      final parsedAngk = int.parse(angkController.text);
      final data = Data(Name: nameController.text, NIM: parsedAngk);
      await SQLHelper.createItem(data);
      getData();
      print("..items: ${_data.length}");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Inputan Tidak Valid!")));
    }
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, nameController.text, int.parse(angkController.text));
    getData();
  }

  Future<void> deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    getData();
  }

  void showForm(int? id) async {
    if (id != null) {
      final existingData = _data.firstWhere((element) => element['id'] == id);
      nameController.text = existingData['name'];
      angkController.text = existingData['nim'].toString();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Name",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: angkController,
              decoration: const InputDecoration(
                hintText: "NIM",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                }
                if (id != null) {
                  await _updateItem(id);
                }

                nameController.text = '';
                angkController.text = '';

                Navigator.of(context).pop();
              },
              child: Text(id == null ? "Create New" : "Update "),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) => Card(
          color: Colors.orange,
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(_data[index]["name"]),
            subtitle: Text(_data[index]["nim"].toString()),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showForm(_data[index]["id"]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItem(_data[index]["id"]),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showForm(null),
      ),
    );
  }
}
