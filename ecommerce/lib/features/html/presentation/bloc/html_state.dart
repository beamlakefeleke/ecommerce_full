part of 'html_bloc.dart';

class HtmlState extends Equatable {
  /// null = not yet loaded (UI shows a spinner).
  final String? htmlText;

  const HtmlState({this.htmlText});

  HtmlState copyWith({String? htmlText, bool clearHtmlText = false}) {
    return HtmlState(
      htmlText: clearHtmlText ? null : (htmlText ?? this.htmlText),
    );
  }

  @override
  List<Object?> get props => [htmlText];
}
