import 'package:flutter/material.dart';

class AddRoom extends StatefulWidget {
  const AddRoom({super.key});

  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _addOption();
  }

  void _addOption() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _confirmRemoveOption(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("¿Deseas eliminar esta opción?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _controllers[index].dispose();
                  _controllers.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _controllers.length + 1, // +1 para incluir el botón
      itemBuilder: (context, index) {
        if (index == _controllers.length) {
          // El último item será el botón
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, color: Colors.purple),
              label: const Text(
                "Add Option",
                style: TextStyle(color: Colors.purple),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllers[index],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Option ${index + 1}",
                    hintStyle: const TextStyle(color: Colors.black),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _confirmRemoveOption(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
