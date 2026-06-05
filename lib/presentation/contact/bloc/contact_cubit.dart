import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactState extends Equatable {
  final String name;
  final String email;
  final String message;
  final bool submitted;

  const ContactState({
    this.name = '',
    this.email = '',
    this.message = '',
    this.submitted = false,
  });

  ContactState copyWith({
    String? name,
    String? email,
    String? message,
    bool? submitted,
  }) =>
      ContactState(
        name: name ?? this.name,
        email: email ?? this.email,
        message: message ?? this.message,
        submitted: submitted ?? this.submitted,
      );

  @override
  List<Object?> get props => [name, email, message, submitted];
}

class ContactCubit extends Cubit<ContactState> {
  ContactCubit() : super(const ContactState());

  void updateName(String v) => emit(state.copyWith(name: v));
  void updateEmail(String v) => emit(state.copyWith(email: v));
  void updateMessage(String v) => emit(state.copyWith(message: v));

  void submit() {
    if (state.name.isNotEmpty && state.email.isNotEmpty) {
      emit(state.copyWith(submitted: true));
    }
  }

  void reset() => emit(const ContactState());
}
