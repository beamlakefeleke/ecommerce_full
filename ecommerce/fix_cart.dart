import 'dart:io';

void main() {
  final file = File('lib/features/cart/screens/cart_screen.dart');
  var content = file.readAsStringSync();
  
  final searchStr = '''  void _loadStoreData(List<Cart> cartList) {
    if(cartList.isNotEmpty){
      Get.find<StoreController>().getCartStoreSuggestedItemList(cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: cartList[0].item!.storeId, name: null), false, fromCart: true);
    }
            WebScreenTitleWidget(title: 'cart_list'.tr),''';

  final replaceStr = '''  void _loadStoreData(List<Cart> cartList) {
    if(cartList.isNotEmpty){
      Get.find<StoreController>().getCartStoreSuggestedItemList(cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: cartList[0].item!.storeId, name: null), false, fromCart: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_cart'.tr, backButton: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(), builder: (context, cartState) {
        return cartState.cartList.isNotEmpty ? Column(
          children: [
            WebScreenTitleWidget(title: 'cart_list'.tr),''';

  content = content.replaceAll(searchStr, replaceStr);
  file.writeAsStringSync(content);
}
