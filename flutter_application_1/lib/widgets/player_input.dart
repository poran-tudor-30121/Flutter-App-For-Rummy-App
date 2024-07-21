import 'package:flutter/material.dart';
import '../models/player_info.dart';

class PlayerInput extends StatelessWidget {
  final int index;
  final PlayerInfo info;
  final ValueChanged<PlayerInfo> onChanged;

  PlayerInput({required this.index, required this.info, required this.onChanged});

  final List<String> positions = ['bottom', 'top', 'left', 'right'];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(220, 221, 228, 225),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Player ${index + 1}',style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                onChanged(PlayerInfo(name: value, position: info.position));
              },
            ),
            DropdownButton<String>(
              value: info.position,
              items: positions
                  .map((position) => DropdownMenuItem<String>(
                        value: position,
                        child: Text(position,style: TextStyle(fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
              onChanged: (value)
               {
                if (value != null) {
                  onChanged(PlayerInfo(name: info.name, position: value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}