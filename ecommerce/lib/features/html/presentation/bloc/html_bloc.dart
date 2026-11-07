import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/html/domain/usecases/get_html_text_usecase.dart';
import 'package:ecommerce/util/html_type.dart';

part 'html_event.dart';
part 'html_state.dart';

class HtmlBloc extends Bloc<HtmlEvent, HtmlState> {
  final GetHtmlTextUseCase getHtmlTextUseCase;

  HtmlBloc({required this.getHtmlTextUseCase}) : super(const HtmlState()) {
    on<HtmlTextRequested>(_onTextRequested);
  }

  Future<void> _onTextRequested(
    HtmlTextRequested event,
    Emitter<HtmlState> emit,
  ) async {
    emit(state.copyWith(clearHtmlText: true));
    final result = await getHtmlTextUseCase(GetHtmlTextParams(event.htmlType));
    result.fold(
      (failure) {},
      (htmlText) => emit(state.copyWith(htmlText: htmlText)),
    );
  }
}
