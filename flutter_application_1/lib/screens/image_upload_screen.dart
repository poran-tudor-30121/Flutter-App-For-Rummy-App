import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/image_viewer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/player_info.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../widgets/manualInputDialog.dart';

class ImageUploadScreen extends StatefulWidget {
  final List<PlayerInfo> players;

  ImageUploadScreen({required this.players});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  final _picker = ImagePicker();
  bool _isUploading = false;
  Map<String, Player> _players = {};
  int _round = 0; // Start round from 0
  bool _gameEnded = false;
  String _serverResponse = '';
  int wonRoundValue = 100;
  List<Player> players = [];
  bool _showRetryButton = false;

     
    void _changeWonRoundValue(int value)
    {
        wonRoundValue = value;
    }

      void _retryUpload() {
    setState(() {
      // Remove scores added in the last round for each player
      _players.forEach((name, player) {
          player.roundScores.removeLast();
          player.totalScore = player.roundScores.fold(0, (sum, score) => sum + score);
      });

      // Decrement the round counter
      if (_round >= 1) {
        _round -= 1;
      }

      // Hide the "Retry" button after retrying
      _showRetryButton = false;
    });
  }

    void _uncheckOtherPlayersWonRound(Player currentPlayer) {
  _players.forEach((name, player) {
    if (player != currentPlayer && player.isWonRoundChecked) {
      player.toggleWonRound(false, _round - 1);
    }
  });
}

void _uncheckOtherPlayersATU(Player currentPlayer) {
  _players.forEach((name, player) {
    if (player != currentPlayer && player.isATUChecked) {
      player.toggleATU(false, _round - 1);
    }
  });
}

    Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

Future<void> _uploadImage() async {
  if (_image == null) return;

  setState(() {
    _isUploading = true;
  });

  final serverUrl = 'http://192.168.1.102:5000/'; // Replace with your server URL
  final request = http.MultipartRequest('POST', Uri.parse(serverUrl));
  request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
  request.fields['positions'] = json.encode(widget.players.map((p) => p.position).toList());

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);

      // Print the JSON data to the console to check its structure
      print('Received JSON response: $data');

      // Handle the received data based on your specific JSON structure
      if (data is Map<String, dynamic> && data.containsKey('result')){
        List<dynamic> playersData = data['result'];
        setState(() {
          _round += 1;
          playersData.asMap().forEach((index, playerData) {
            String playerName = widget.players[index].name; // Adjust based on your JSON structure
            if (_players.containsKey(playerName)) {
              // Update existing player's round data for the current round
              Player player = _players[playerName]!;
              player.wonRoundValue = wonRoundValue;
              player.resetATU(); // Automatically uncheck ATU before updating scores
              player.resetDoublePoints();
              player.resetWonRound();
              player.resetQuadruplePoints();
              player.roundTiles.add(Player.fromJson(playerName, playerData,wonRoundValue).roundTiles[0]);
              player.roundScores.add(Player.fromJson(playerName, playerData,wonRoundValue).roundScores[0]);
              // Accumulate scores across all rounds to update total score
              player.totalScore = player.roundScores.fold(0, (sum, score) => sum + score);
              // Print roundScores for debugging
              print('${playerName} - roundScores: ${player.roundScores}');
            } else {
              // Add new player for the current round
              _players[playerName] = Player.fromJson(playerName, playerData,wonRoundValue, isATUChecked: false,isDoublePointsChecked: false,isQuadruplePointsChecked: false, isWonRoundChecked: false); // Ensure ATU is unchecked for new players
              print('${playerName} - roundScores: ${_players[playerName]?.roundScores}');
            }
          });

           setState(() {
              _showRetryButton = true;
            });

        });
      } else {
        setState(() {
          // Handle error if the data format is invalid
          _serverResponse = 'Invalid data format received';
        });
      }
    } else {
      setState(() {
        // Handle error if the response status code is not 200
        _serverResponse = 'Image upload failed with status code: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      // Handle exception during image upload
      _serverResponse = 'Image upload failed with error: $e';
    });
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
}
void _resetState() {
    setState(() {
      _image = null;
      _players = {};
      _serverResponse = '';
      _round = -1; // Reset round to 0
      _gameEnded = false;
      _showRetryButton = false;
    });
  }

  void _endGame() {
    setState(() {
      _gameEnded = true;
    });
  }


   void _updateTileScore(Player player, int roundIndex, int tileIndex, String newValue) {
    setState(() {
      player.updateTileScore(roundIndex, tileIndex, newValue);
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_round > 0 ? 'Round $_round' : 'Game'),
      ),
      body: _gameEnded
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Game Over!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  ..._players.entries.map((entry) {
                    final player = entry.value;
                    return Text(
                      '${player.name} - Final Score: ${player.totalScore}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetState,
                    child: Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Adjust padding to center content better
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the buttons vertically
                  crossAxisAlignment: CrossAxisAlignment.center, // Center the buttons horizontally
                  children: [
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showImageSourceOptions(context),
                        icon: Icon(Icons.image),
                        label: Text('Pick Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                if (_image != null)
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(imageFile: _image!),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal, width: 2),
      ),
      child: Image.file(
        _image!,
        fit: BoxFit.contain,  // Changed to BoxFit.contain to ensure the image fits within the container
      ),
    ),
  ),
                    if (_image != null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _uploadImage,
                          icon: _isUploading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.upload),
                          label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                         if (_showRetryButton)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: _retryUpload,
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
     if (_image != null)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color:Color.fromRGBO(255, 99, 71, 1),
            borderRadius: BorderRadius.circular(15), // Adjust the radius as needed for a capsule shape
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Winning Round Bonus:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10), // Space between text and dropdown
              DropdownButton<int>(
                value: wonRoundValue,
                dropdownColor: Colors.teal,
                style: TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                onChanged: (value) {
                  setState(() {
                    wonRoundValue = value!;
                    _changeWonRoundValue(value);
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 50,
                    child: Text('50',
                     style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),
                  ),
                  DropdownMenuItem(
                    value: 100,
                    child: Text('100',
                     style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),
                  ),
                  DropdownMenuItem(
                    value: 250,
                    child: Text('250',
                     style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),
                  ),
                  DropdownMenuItem(
                    value: 500,
                    child: Text('500',
                     style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
               if(_round > 0)
..._players.entries.map((entry) {
  final player = entry.value;
  return Card(
    color: Color.fromARGB(220, 235, 247, 242),
    elevation: 2,
    child: ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              text: '${player.name}: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black), // Default text style
              children: <TextSpan>[
                TextSpan(
                  text: '${player.totalScore}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showTextInputDialog(context, player, _round - 1);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Won'),
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Color.fromRGBO(255, 99, 71, 1),
                    value: player.isWonRoundChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _uncheckOtherPlayersWonRound(player);
                        }
                        player.toggleWonRound(value ?? false, _round - 1);
                      });
                    },
                  ),
                  Text('X2'),
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Color.fromRGBO(255, 99, 71, 1),
                    value: player.isDoublePointsChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          player.resetQuadruplePoints();
                        }
                        player.toggleDoublePoints(value ?? false, _round - 1);
                      });
                    },
                  ),
                  Text('X4'),
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Color.fromRGBO(255, 99, 71, 1),
                    value: player.isQuadruplePointsChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          player.resetDoublePoints();
                        }
                        player.toggleQuadruplePoints(value ?? false, _round - 1);
                      });
                    },
                  ),
                  Text('ATU'),
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Color.fromRGBO(255, 99, 71, 1),
                    value: player.isATUChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _uncheckOtherPlayersATU(player);
                        }
                        player.toggleATU(value ?? false, _round - 1);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      subtitle: ExpansionTile(
        title: Text('Tiles - Round $_round'),
        children: [
          ...player.roundTiles[_round - 1].map((tile) {
            Color textColor;

            // Determine the text color based on tile.colorName
            switch (tile.colorName) {
              case 'Red':
                textColor = Colors.red;
                break;
              case 'Black':
                textColor = Colors.black;
                break;
              case 'Yellow':
                textColor = const Color.fromARGB(255, 224, 202, 0);
                break;
              case 'Blue':
                textColor = const Color.fromARGB(255, 13, 122, 211);
                break;
              default:
                textColor = Colors.black; // Default color if no match
            }
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              title: TextFormField(
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                initialValue: tile.number.toString(),
                onChanged: (newValue) {
                  _updateTileScore(player, _round - 1, player.roundTiles[_round - 1].indexOf(tile), newValue);
                },
                decoration: InputDecoration(
                  labelText: 'Number',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}).toList(),
if (_players.isNotEmpty)
  Center(
    child: ElevatedButton(
      onPressed: _endGame,
      child: Text('End Game'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    ),
  ),

                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _showImageSourceOptions(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );

    if (source != null) {
      await _pickImage(source);
    }
  }
}