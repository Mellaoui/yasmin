import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _winner = '';
  List<int> _winningCombination = [];

  void _handleTap(int index) {
    if (_board[index] == '' && _winner == '') {
      setState(() {
        _board[index] = _currentPlayer;
        _winner = _checkWinner();
        if (_winner == '' && _board.contains('')) {
          _currentPlayer = 'O'; // Switch to machine
          Future.delayed(const Duration(milliseconds: 500), _makeMachineMove);
        }
      });
    }
  }

  void _makeMachineMove() {
    if (_winner != '') return;

    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < _board.length; i++) {
      if (_board[i] == '') {
        _board[i] = 'O'; // Try the move
        int score = _minimax(_board, 0, false);
        _board[i] = ''; // Undo the move
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    if (bestMove != -1) {
      setState(() {
        _board[bestMove] = 'O';
        _winner = _checkWinner();
        _currentPlayer = 'X'; // Switch back to player
      });
    }
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    String result = _checkWinner();
    if (result != '') {
      if (result == 'O') return 10 - depth;
      if (result == 'X') return depth - 10;
      if (result == 'Draw') return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = 'O';
          int score = _minimax(board, depth + 1, false);
          board[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = 'X';
          int score = _minimax(board, depth + 1, true);
          board[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (List<int> combination in winningCombinations) {
      if (_board[combination[0]] != '' &&
          _board[combination[0]] == _board[combination[1]] &&
          _board[combination[1]] == _board[combination[2]]) {
        _winningCombination = combination;
        return _board[combination[0]];
      }
    }

    if (!_board.contains('')) {
      return 'Draw';
    }

    return '';
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = '';
      _winningCombination = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.title_tic_tac,
            style: const TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_winner != '')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                _winner == 'Draw'
                    ? localizations.draw
                    : localizations.player_wins(_winner),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            shrinkWrap: true,
            itemCount: 9,
            itemBuilder: (context, index) {
              bool isWinningCell = _winningCombination.contains(index);
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isWinningCell ? Colors.tealAccent : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.black12),
                  ),
                  margin: const EdgeInsets.all(4),
                  child: Center(
                    child: Text(
                      _board[index],
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _board[index] == 'X' ? Colors.teal : Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              localizations.reset_button,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
