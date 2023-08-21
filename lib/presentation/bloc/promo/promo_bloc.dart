import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otaqu/common/utils/constants.dart';

part 'promo_event.dart';
part 'promo_state.dart';

class PromoBloc extends Bloc<PromoEvent, PromoState> {
  PromoBloc() : super(PromoInitial()) {
    on<PromoEvent>((event, emit) {
      if (event is RunSliderEvent) {
        emit(LoadedSliderState(
          id: event.id > promoImagePaths.length - 1 ? 0 : event.id,
        ));
      }
    });
  }
}
