import 'tile.dart';

class Player {
  String name;
  List<List<Tile>> roundTiles; // List of lists to store tiles for each round
  List<int> roundScores; // List to store scores for each round
  int totalScore; // Total score across all rounds
  bool isATUChecked;
  bool isDoublePointsChecked;
  bool isQuadruplePointsChecked;
  bool isWonRoundChecked;
  int wonRoundValue;

  Player(this.name, this.roundTiles, this.roundScores, this.totalScore,this.wonRoundValue, {this.isATUChecked = false,this.isDoublePointsChecked = false,this.isWonRoundChecked = false,this.isQuadruplePointsChecked = false});

  factory Player.fromJson(String name, List<dynamic> json,int wonRoundValue, {bool isATUChecked = false,bool isDoublePointsChecked = false, bool isQuadruplePointsChecked = false, bool isWonRoundChecked = false}) {
    List<List<Tile>> roundTiles = [];
    List<int> roundScores = [];
    int totalScore = 0;

    List<Tile> tiles = json.map((tileData) => Tile.fromJson(tileData)).toList();
    int roundScore = _calculateRoundScore(tiles, isATUChecked, isDoublePointsChecked,isQuadruplePointsChecked,isWonRoundChecked,wonRoundValue);
    roundTiles.add(tiles);
    roundScores.add(roundScore);
    totalScore += roundScore;

    return Player(name, roundTiles, roundScores, totalScore, wonRoundValue, isATUChecked: isATUChecked, isDoublePointsChecked: isDoublePointsChecked , isQuadruplePointsChecked: isQuadruplePointsChecked,isWonRoundChecked: isWonRoundChecked);
  }

  static int _calculateRoundScore(List<Tile> tiles, bool isATUChecked, bool isDoublePointsChecked, bool isQuadruplePointsChecked,bool isWonRoundChecked, int wonRoundValue) {
    int score = 0;
    if (tiles.isEmpty) {
      score = -100;
    } else {
      score = tiles.fold(0, (sum, tile) {
        if (tile.number is int) {
          if (tile.number < 10) {
            return sum + 5;
          } else if (tile.number == 1) {
            return sum + 25;
          } else if (tile.number >= 10) {
            return sum + 10;
          }
        } else if (tile.number is String) {
          if (tile.number.toLowerCase() == 'jolly') {
            return sum + 50;
          }
        }
        return sum;
      });
    }
     if(isQuadruplePointsChecked)
    {
      score *=4;
    }

    if(isDoublePointsChecked)
    {
      score *=2;
    }
     if (isATUChecked) {
      score += 50;
    }
      if(isWonRoundChecked)
    { 
      if(isDoublePointsChecked) {
        score +=(wonRoundValue*2);
      }
       if(isQuadruplePointsChecked) {
        score +=(wonRoundValue*4);
      }
      else
      {
        score += wonRoundValue;
      }
    }
    return score;
  }

  void updateTileScore(int roundIndex, int tileIndex, String newValue) {
    if (roundIndex < roundTiles.length && tileIndex < roundTiles[roundIndex].length) {
      Tile tile = roundTiles[roundIndex][tileIndex];
      if (newValue.isEmpty) {
        tile.number = null;
      } else if (int.tryParse(newValue) != null) {
        tile.number = int.parse(newValue);
      } else {
        tile.number = newValue;
      }
      roundScores[roundIndex] = _calculateRoundScore(roundTiles[roundIndex], isATUChecked, isDoublePointsChecked,isQuadruplePointsChecked,isWonRoundChecked,wonRoundValue);
      totalScore = roundScores.fold(0, (sum, score) => sum + score);
    }
  }

  void toggleATU(bool value,int round) {
    isATUChecked = value;
    roundScores[round] =  _calculateRoundScore(roundTiles[round], isATUChecked ,isDoublePointsChecked,isQuadruplePointsChecked,isWonRoundChecked,wonRoundValue);
    totalScore = roundScores.fold(0, (sum, score) => sum + score);
  }
   void toggleDoublePoints(bool value,int round) {
    isDoublePointsChecked = value;
    roundScores[round] =  _calculateRoundScore(roundTiles[round], isATUChecked, isDoublePointsChecked,isQuadruplePointsChecked,isWonRoundChecked,wonRoundValue);
    totalScore = roundScores.fold(0, (sum, score) => sum + score);
  }
     void toggleQuadruplePoints(bool value,int round) {
    isQuadruplePointsChecked = value;
    roundScores[round] =  _calculateRoundScore(roundTiles[round], isATUChecked, isDoublePointsChecked,isQuadruplePointsChecked,isWonRoundChecked,wonRoundValue);
    totalScore = roundScores.fold(0, (sum, score) => sum + score);
  }
    void toggleWonRound(bool value,int round) {
    isWonRoundChecked = value;
    roundScores[round] =  _calculateRoundScore(roundTiles[round], isATUChecked, isDoublePointsChecked,isQuadruplePointsChecked,isWonRoundChecked,wonRoundValue);
    totalScore = roundScores.fold(0, (sum, score) => sum + score);
  }
  void changedWonRoundValue(int value , int round)
  {
    wonRoundValue = value;
    roundScores[round] =  _calculateRoundScore(roundTiles[round], isATUChecked, isDoublePointsChecked,isQuadruplePointsChecked,isWonRoundChecked,wonRoundValue);
    totalScore = roundScores.fold(0, (sum, score) => sum + score);

  }
  void setRoundScore(int value, int round)
  {
    roundScores[round] = value;
    totalScore = roundScores.fold(0, (sum, score) => sum + score);
  }

  void resetATU() {
    isATUChecked = false;
  }
  void resetDoublePoints()
  {
    isDoublePointsChecked = false;
  }
  void resetWonRound()
  {
    isWonRoundChecked = false;
  }
  void resetQuadruplePoints()
  {
    isQuadruplePointsChecked = false;
  }
}
