import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/location/domain/models/zone_data_model.dart';
import 'package:ecommerce/features/store_registration/domain/models/store_body_model.dart';

abstract class StoreRegistrationServiceInterface{
  Future<List<ZoneDataModel>?> getZoneList();
  int? prepareSelectedZoneIndex(List<int>? zoneIds, List<ZoneDataModel>? zoneList);
  Future<List<ModuleModel>?> getModules(int? zoneId);
  Future<void> registerStore(StoreBodyModel store, XFile? logo, XFile? cover);
}
