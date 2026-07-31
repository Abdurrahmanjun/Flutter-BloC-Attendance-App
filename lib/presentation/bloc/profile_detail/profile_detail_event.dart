part of 'profile_detail_bloc.dart';

abstract class ProfileDetailEvent extends Equatable {
  const ProfileDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileDetailEvent extends ProfileDetailEvent {}
