part of 'campaign_bloc.dart';

sealed class CampaignEvent extends Equatable {
  const CampaignEvent();
  @override
  List<Object?> get props => [];
}

class BasicCampaignListRequested extends CampaignEvent {
  final bool reload;
  const BasicCampaignListRequested({this.reload = false});
  @override
  List<Object?> get props => [reload];
}

class CampaignDetailsRequested extends CampaignEvent {
  final int? campaignID;
  const CampaignDetailsRequested(this.campaignID);
  @override
  List<Object?> get props => [campaignID];
}

class ItemCampaignListRequested extends CampaignEvent {
  final bool reload;
  const ItemCampaignListRequested({this.reload = false});
  @override
  List<Object?> get props => [reload];
}

class CampaignCurrentIndexChanged extends CampaignEvent {
  final int index;
  const CampaignCurrentIndexChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class ItemCampaignCleared extends CampaignEvent {
  const ItemCampaignCleared();
}
