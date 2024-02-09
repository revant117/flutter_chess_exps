import 'package:flutter_bloc/flutter_bloc.dart';

sealed class BoardStateEvent {}

class BoardState {
  String fen;
  int moveCount = 0;

  BoardState(this.fen, {this.moveCount = 0});

  void _move(String fen) {
    this.fen = fen;
    moveCount = moveCount + 1;
  }

  BoardState copyWith(String fen) {
    _move(fen);
    return BoardState(fen, moveCount: moveCount);
  }
}

class BoardStateChanged extends BoardStateEvent {
  String fen;
  BoardStateChanged(this.fen);
}

class BoardStateBloc extends Bloc<BoardStateEvent, BoardState> {
  BoardStateBloc(String fen) : super(BoardState(fen)) {
    on<BoardStateChanged>((event, emit) {
      emit(state.copyWith(event.fen));
    });
  }
}
