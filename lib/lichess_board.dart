import 'package:flutter/material.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart'
    show IMap;
import 'package:chessground/chessground.dart'
    show Board, BoardData, InteractableSide, Side, ValidMoves, Move;
import 'package:dartchess/dartchess.dart' as dc;

const String emptyBoardWithWhiteRook = '8/8/8/8/8/8/8/1R6 w - - 0 1';

void main() {
  runApp(
    const MaterialApp(home: Home()),
  );
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // use Scaffold also in order to provide material app widgets
      body: ChessBoard(initalFen: emptyBoardWithWhiteRook),
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
  ValidMoves validMoves = IMap(const {});
  dc.Position<dc.Chess> position = dc.Chess.initial;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Board(
          size: screenWidth,
          data: BoardData(
            sideToMove: Side.white,
            interactableSide: InteractableSide.white,
            orientation: Side.white,
            fen: fen,
            // validMoves: validMoves,
          ),
          onMove: _onMove,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fen = widget.initalFen;
    final setup = dc.Setup.parseFen(fen);
    position = dc.Chess.fromSetup(setup);
    validMoves = dc.algebraicLegalMoves(position);
  }

  void _onMove(Move move, {bool? isDrop, bool? isPremove}) {
    final m = dc.Move.fromUci(move.uci)!;
    setState(() {
      position = position.playUnchecked(m);
      fen = position.fen;
      validMoves = dc.algebraicLegalMoves(position);
    });
  }
}
