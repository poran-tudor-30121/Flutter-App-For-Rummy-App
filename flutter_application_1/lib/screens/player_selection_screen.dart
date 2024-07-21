import 'package:flutter/material.dart';
import '../models/player_info.dart';
import 'image_upload_screen.dart';
import '../widgets/player_input.dart';

class PlayerSelectionScreen extends StatefulWidget {
  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int _numberOfPlayers = 2; // Default to 2 players
  List<PlayerInfo> _players = [];

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  void _initializePlayers() {
    _players = List.generate(
      _numberOfPlayers,
      (index) => PlayerInfo(name: '', position: 'bottom'),
    );
  }

  void _updateNumberOfPlayers(int newCount) {
    setState(() {
      _numberOfPlayers = newCount;
      _initializePlayers();
    });
  }

  void _updatePlayerInfo(int index, PlayerInfo info) {
    setState(() {
      _players[index] = info;
    });
  }

void _startGame() {
  // Check for duplicate positions
  Set<String> positions = _players.map((player) => player.position).toSet();
  if (positions.length < _players.length) {
    // Duplicates found, show a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Positions'),
          content: Text('Two players cannot have the same position.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  } else {
    // No duplicates, navigate to ImageUploadScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageUploadScreen(
          players: _players,
        ),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Selection'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButton<int>(
                value: _numberOfPlayers,
                items: List.generate(3, (index) => index + 2)
                    .map((count) => DropdownMenuItem<int>(
                          value: count,
                          child: Text('$count Players'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateNumberOfPlayers(value);
                  }
                },
                style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold),
                dropdownColor: Colors.white,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _numberOfPlayers,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      color: Colors.teal,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PlayerInput(
                          index: index,
                          info: _players[index],
                          onChanged: (info) => _updatePlayerInfo(index, info),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _startGame,
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                textStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
