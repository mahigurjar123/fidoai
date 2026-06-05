import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeState extends Equatable {
  final bool countersActive;
  final bool heroVisible;

  const HomeState({this.countersActive = false, this.heroVisible = false});

  HomeState copyWith({bool? countersActive, bool? heroVisible}) => HomeState(
        countersActive: countersActive ?? this.countersActive,
        heroVisible: heroVisible ?? this.heroVisible,
      );

  @override
  List<Object?> get props => [countersActive, heroVisible];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void activateCounters() {
    if (!state.countersActive) emit(state.copyWith(countersActive: true));
  }

  void setHeroVisible() {
    if (!state.heroVisible) emit(state.copyWith(heroVisible: true));
  }
}
