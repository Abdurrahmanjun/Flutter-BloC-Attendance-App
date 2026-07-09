part of 'announcement_bloc.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> announcements;

  const AnnouncementLoaded(this.announcements);

  @override
  List<Object?> get props => [announcements.map((a) => a.id).toList()];
}

class AnnouncementFailure extends AnnouncementState {
  final String message;

  const AnnouncementFailure(this.message);

  @override
  List<Object?> get props => [message];
}
