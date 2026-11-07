part of 'campaign_bloc.dart';

class CampaignState extends Equatable {
  final List<BasicCampaignModel>? basicCampaignList;
  final BasicCampaignModel? basicCampaign;
  final List<Item>? itemCampaignList;
  final int currentIndex;

  const CampaignState({
    this.basicCampaignList,
    this.basicCampaign,
    this.itemCampaignList,
    this.currentIndex = 0,
  });

  CampaignState copyWith({
    List<BasicCampaignModel>? basicCampaignList,
    BasicCampaignModel? basicCampaign,
    List<Item>? itemCampaignList,
    int? currentIndex,
    bool clearBasicCampaign = false,
    bool clearItemCampaignList = false,
  }) {
    return CampaignState(
      basicCampaignList: basicCampaignList ?? this.basicCampaignList,
      basicCampaign: clearBasicCampaign
          ? null
          : (basicCampaign ?? this.basicCampaign),
      itemCampaignList: clearItemCampaignList
          ? null
          : (itemCampaignList ?? this.itemCampaignList),
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [
    basicCampaignList,
    basicCampaign,
    itemCampaignList,
    currentIndex,
  ];
}
