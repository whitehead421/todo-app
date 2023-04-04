import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/utils/dialog_box.dart';
import '../utils/todo_tile.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/utils/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('mybox');
  ToDoDatabase db = ToDoDatabase();
  var index = 0;

  @override
  void initState() {
    // if this is the 1st time ever opening the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();
  }

  // save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([
        _controller.text,
        false,
      ]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  // create a new task
  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  // delete a task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    _showSnackBar("Task Deleted");
    db.updateDatabase();
  }

  // edit a task
  void editTask(int index) {
    _controller.text = db.toDoList[index][0];
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: () {
              setState(() {
                db.toDoList[index][0] = _controller.text;
              });
              _controller.clear();
              Navigator.of(context).pop();
              db.updateDatabase();
            },
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  // change theme
  void changeTheme() {
    var colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    setState(() {
      index = (index + 1) % colors.length;
    });
    var theme = ThemeData(primarySwatch: colors[index]);
    Provider.of<ThemeProvider>(context, listen: false).setTheme(theme);

    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: changeTheme,
            icon: const Icon(Icons.color_lens),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('TO DO'),
            SizedBox(
              height: 5,
            ),
            Text('Track your tasks!', style: TextStyle(fontSize: 12)),
          ],
        ),
        elevation: 10,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add_task),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        separatorBuilder: (context, index) => const SizedBox(
          height: 10,
        ),
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.toDoList[index][0],
            taskCompleted: db.toDoList[index][1],
            onChanged: (value) {
              checkBoxChanged(value!, index);
            },
            deleteFunction: (context) => {deleteTask(index)},
            editFunction: (context) => {editTask(index)},
          );
        },
      ),
    );
  }
}
