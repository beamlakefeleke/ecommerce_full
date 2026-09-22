import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/store_registration/domain/models/store_body_model.dart';
import 'package:ecommerce/interfaces/repository_interface.dart';

abstract class StoreRegistrationRepositoryInterface extends RepositoryInterface{
  Future<bool> registerStore(StoreBodyModel store, XFile? logo, XFile? cover);
}
