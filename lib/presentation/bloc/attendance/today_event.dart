part of 'today_bloc.dart';

abstract class TodayEvent extends Equatable {
  const TodayEvent();

  @override
  List<Object> get props => [];
}

class LoadTodayEvent extends TodayEvent {}

class CheckInEvent extends TodayEvent {}

class CheckOutEvent extends TodayEvent {}
