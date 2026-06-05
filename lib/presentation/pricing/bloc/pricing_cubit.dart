import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PricingState extends Equatable {
  final bool isYearly;
  final bool visible;

  const PricingState({this.isYearly = false, this.visible = false});

  PricingState copyWith({bool? isYearly, bool? visible}) => PricingState(
        isYearly: isYearly ?? this.isYearly,
        visible: visible ?? this.visible,
      );

  @override
  List<Object?> get props => [isYearly, visible];
}

class PricingCubit extends Cubit<PricingState> {
  PricingCubit() : super(const PricingState());

  void toggleBilling() => emit(state.copyWith(isYearly: !state.isYearly));

  void setVisible() {
    if (!state.visible) emit(state.copyWith(visible: true));
  }
}
