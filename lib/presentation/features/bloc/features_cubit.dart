import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturesState extends Equatable {
  final int flippedCard;
  final bool visible;

  const FeaturesState({this.flippedCard = -1, this.visible = false});

  FeaturesState copyWith({int? flippedCard, bool? visible}) => FeaturesState(
        flippedCard: flippedCard ?? this.flippedCard,
        visible: visible ?? this.visible,
      );

  @override
  List<Object?> get props => [flippedCard, visible];
}

class FeaturesCubit extends Cubit<FeaturesState> {
  FeaturesCubit() : super(const FeaturesState());

  void flipCard(int index) {
    emit(state.copyWith(flippedCard: state.flippedCard == index ? -1 : index));
  }

  void setVisible() {
    if (!state.visible) emit(state.copyWith(visible: true));
  }
}
