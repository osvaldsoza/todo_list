import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];

  final TextEditingController todoController = TextEditingController();

  final TodoRepository todoRepository = TodoRepository();

  Todo? deletedTodo;
  int? posicaoDeletedTodo;

  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
              child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: todoController,
                    decoration: InputDecoration(
                        labelText: "Adicionar uma tarefa",
                        labelStyle: const TextStyle(color: Colors.green),
                        border: const OutlineInputBorder(),
                        errorText: errorText,
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green))
                        // hintText: "ex: Estudar Flutter"
                        ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    String text = todoController.text;

                    if (text.isEmpty) {
                      setState(() {
                        errorText = "O título da tarefa é obrigatório.";
                      });
                      return;
                    }

                    setState(() {
                      Todo newTodo =
                          Todo(title: text, dateTime: DateTime.now());
                      todos.add(newTodo);
                      errorText = null;
                    });
                    todoController.clear();
                    todoRepository.saveTodoList(todos);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: const EdgeInsets.all(13.5)),
                  child: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (Todo todo in todos)
                    TodoListItem(todo: todo, onDelete: onDelete)
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                    child:
                        Text("Você possui ${todos.length} tarefas pendentes.")),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  onPressed: todos.isEmpty
                      ? null
                      : () {
                          showDeleteTodosConfirmationDialog();
                        },
                  child: const Text("Limpar"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: const EdgeInsets.all(13.5)),
                )
              ],
            )
          ],
        ),
      ))),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    posicaoDeletedTodo = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });

    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Tarefa ${todo.title} foi removida com sucesso"),
      backgroundColor: Colors.orangeAccent,
      action: SnackBarAction(
        label: "Desfazer",
        textColor: Colors.white,
        onPressed: () {
          setState(() {
            todos.insert(posicaoDeletedTodo!, deletedTodo!);
          });
        },
      ),
      duration: const Duration(seconds: 5),
    ));
  }

  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Limpar tudo?"),
          content: const Text(
              "Você tem certeza que deseja apagar todas as tarefas?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(primary: Colors.orange),
                child: const Text("Cancelar")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteAllTodos();
                },
                style: TextButton.styleFrom(primary: Colors.red),
                child: const Text("Limpar Tudo")),
          ]),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
