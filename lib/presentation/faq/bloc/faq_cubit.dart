import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FAQState extends Equatable {
  final int expandedIndex;
  final bool visible;

  const FAQState({this.expandedIndex = -1, this.visible = false});

  FAQState copyWith({int? expandedIndex, bool? visible}) => FAQState(
        expandedIndex: expandedIndex ?? this.expandedIndex,
        visible: visible ?? this.visible,
      );

  @override
  List<Object?> get props => [expandedIndex, visible];
}

class FAQCubit extends Cubit<FAQState> {
  FAQCubit() : super(const FAQState());

  void toggle(int index) => emit(state.copyWith(
        expandedIndex: state.expandedIndex == index ? -1 : index,
      ));

  void setVisible() {
    if (!state.visible) emit(state.copyWith(visible: true));
  }
}
