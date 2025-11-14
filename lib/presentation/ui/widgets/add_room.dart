import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/models/agenda.dart';

class AddRoom extends StatefulWidget {
  final List<Track> rooms;
  final void Function(List<Track>) editedRooms;
  final void Function(Track) removeRoom;
  final String eventUid;

  const AddRoom({
    super.key,
    required this.rooms,
    required this.editedRooms,
    required this.eventUid,
    required this.removeRoom,
  });

  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  List<Track> _tracks = [];
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _tracks = List.generate(widget.rooms.length, (index) {
      return widget.rooms[index];
    });
    _controllers = List.generate(_tracks.length, (index) {
      final controller = TextEditingController(text: _tracks[index].name);
      controller.addListener(() {
        _tracks[index].name = controller.text;
      });
      return controller;
    });
  }

  void _notifyCurrentRooms() {
    widget.editedRooms(
      _tracks.where((track) => track.name.isNotEmpty).toList(),
    );
  }

  void _addOption() {
    _notifyCurrentRooms();
    setState(() {
      final controller = TextEditingController();
      _tracks.add(
        Track(
          uid: 'Track_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
          name: controller.text,
          color: "",
          sessionUids: [],
          eventUid: widget.eventUid,
        ),
      );
      _controllers.add(controller);
    });
  }

  void _updateTrackName(int index, String value) {
    _tracks[index].name = value;
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
              onPressed: () async {
                widget.removeRoom(_tracks[index]);
                if (_tracks[index].sessionUids.isEmpty) {
                  setState(() {
                    _controllers[index].dispose();
                    _controllers.removeAt(index);
                    _tracks.removeAt(index);
                  });
                  widget.editedRooms(
                    _tracks.where((track) => track.name.isNotEmpty).toList(),
                  );
                }
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
      itemCount: _tracks.length + 1, // +1 para incluir el botón
      itemBuilder: (context, index) {
        if (index == _tracks.length) {
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
                  onEditingComplete: () {
                    _notifyCurrentRooms();
                  },
                  onChanged: (value) {
                    _updateTrackName(index, value);
                    _notifyCurrentRooms();
                  },
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
