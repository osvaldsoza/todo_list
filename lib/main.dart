import 'package:flutter/material.dart';
import 'package:todo_list/pages/todo_list_page.dart';

void main(){
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}


