import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models.dart';

class TestimonialsState extends Equatable {
  final int currentIndex;

  const TestimonialsState({this.currentIndex = 0});

  TestimonialsState copyWith({int? currentIndex}) =>
      TestimonialsState(currentIndex: currentIndex ?? this.currentIndex);

  @override
  List<Object?> get props => [currentIndex];
}

class TestimonialsCubit extends Cubit<TestimonialsState> {
  TestimonialsCubit() : super(const TestimonialsState());

  void next() => emit(state.copyWith(
        currentIndex: (state.currentIndex + 1) % testimonials.length,
      ));

  void prev() => emit(state.copyWith(
        currentIndex:
            (state.currentIndex - 1 + testimonials.length) % testimonials.length,
      ));

  void goTo(int index) => emit(state.copyWith(currentIndex: index));
}
