part of 'html_bloc.dart';

sealed class HtmlEvent extends Equatable {
  const HtmlEvent();

  @override
  List<Object?> get props => [];
}

class HtmlTextRequested extends HtmlEvent {
  final HtmlType htmlType;

  const HtmlTextRequested(this.htmlType);

  @override
  List<Object?> get props => [htmlType];
}
