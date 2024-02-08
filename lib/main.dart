import 'package:chess/chess.dart' as dc;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

void main() {
  runApp(
    const MaterialApp(home: Home()),
  );
}

const String startingFen = '7r/8/8/6n1/8/8/8/1R6 w - - 0 1';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChessBoard(initalFen: startingFen),
    );
  }
}

class ChessBoard extends StatefulWidget {
  const ChessBoard({Key? key, required this.initalFen}) : super(key: key);

  final String initalFen;

  @override
  State<ChessBoard> createState() => ChessBoardState();
}

class ChessBoardState extends State<ChessBoard> {
  String fen = '';
  final controller = WPChessboardController();
  dc.Chess chess = dc.Chess();

  // Customize the board
  Widget squareBuilder(SquareInfo info) {
    Color fieldColor = (info.index + info.rank) % 2 == 0
        ? Colors.grey.shade200
        : Colors.grey.shade600;
    Color overlayColor = Colors.transparent;

    // Add Algebraic notation in the board (a-h, 1-8)
    return Container(
        color: fieldColor,
        width: info.size,
        height: info.size,
        child: AnimatedContainer(
          color: overlayColor,
          width: info.size,
          height: info.size,
          duration: const Duration(milliseconds: 200),
        ));
  }

  void onPieceTap(SquareInfo square, String piece) {
    if (controller.hints.key == square.index.toString()) {
      controller.setHints(HintMap());
      return;
    }
    showHintFields(square, piece);
  }

  void showHintFields(SquareInfo square, String piece) {
    final moves = chess.generate_moves({'square': square.toString()});
    final hintMap = HintMap(key: square.index.toString());
    for (var move in moves) {
      String to = move.toAlgebraic;
      int rank = to.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
      int file = to.codeUnitAt(0) - "a".codeUnitAt(0) + 1;

      hintMap.set(
          rank,
          file,
          (size) => MoveHint(
                size: size,
                onPressed: () => doMove(move),
              ));
    }
    controller.setHints(hintMap);
  }

  void doMove(dc.Move move) {
    chess.move(move);
    update();
  }

  void update({bool animated = true}) {
    // We only want white's turn, so updating the turn part of the current fen
    final currentFen = turnWhite(chess.fen);
    controller.setFen(currentFen, animation: animated);
    chess.load(currentFen, check_validity: false);
  }

  void onEmptyFieldTap(SquareInfo square) {
    controller.setHints(HintMap());
  }

  void onPieceDrop(PieceDropEvent event) {
    chess.move({"from": event.from.toString(), "to": event.to.toString()});
    update(animated: false);
  }

  void onPieceStartDrag(SquareInfo square, String piece) {
    showHintFields(square, piece);
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      body: Center(
        child: WPChessboard(
            size: size,
            orientation: BoardOrientation.white,
            squareBuilder: squareBuilder,
            controller: controller,
            onPieceDrop: onPieceDrop,
            onPieceTap: onPieceTap,
            onPieceStartDrag: onPieceStartDrag,
            onEmptyFieldTap: onEmptyFieldTap,
            turnTopPlayerPieces: false,
            ghostOnDrag: true,
            dropIndicator: DropIndicatorArgs(
                size: size / 2, color: Colors.lightBlue.withOpacity(0.24)),
            pieceMap: PieceMap(
              K: (size) => WhiteKing(size: size),
              Q: (size) => WhiteQueen(size: size),
              B: (size) => WhiteBishop(size: size),
              N: (size) => WhiteKnight(size: size),
              R: (size) => WhiteRook(size: size),
              P: (size) => WhitePawn(size: size),
              k: (size) => BlackKing(size: size),
              q: (size) => BlackQueen(size: size),
              b: (size) => BlackBishop(size: size),
              // n: (size) => BlackKnight(size: size),
              // can Load custom wdgets for the piece
              n: (size) => const Icon(
                Icons.accessible,
                color: Colors.blue,
                size: 45,
              ),
              r: (size) => BlackRook(size: size),
              p: (size) => BlackPawn(size: size),
            )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fen = widget.initalFen;
    chess.load(fen, check_validity: false);
    controller.setFen(fen);
  }
}

// Utils
String turnBlack(String fen) {
  List<String> parts = fen.split(' ');
  if (parts.length != 6) {
    throw const FormatException('Invalid FEN string');
  }
  parts[1] = 'b'; // Set turn to Black
  return parts.join(' ');
}

String turnWhite(String fen) {
  List<String> parts = fen.split(' ');
  if (parts.length != 6) {
    throw const FormatException('Invalid FEN string');
  }
  parts[1] = 'w'; // Set turn to White
  return parts.join(' ');
}
