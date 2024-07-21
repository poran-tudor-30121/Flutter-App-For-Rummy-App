import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/player.dart';

Future<void> showTextInputDialog(BuildContext context, Player player,int _round) async {
  TextEditingController textController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to close dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Score for this Round'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('(Include Bonuses/Multipliers)'),
              TextField(
                controller: textController,
                decoration: InputDecoration(hintText: 'Enter score here'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
                {
                try {
                  // Parse the text to an integer
                  int value = int.parse(textController.text);
                  // Call setRoundScore with the parsed value and the current round
                  player.setRoundScore(value, _round);
                } catch (e) {
                  // Handle parsing error, e.g., show an error message
                  print('Invalid input: $e');
                }
              };
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
