import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/deliveryman_registration/domain/models/delivery_man_body.dart';
import 'package:ecommerce/interfaces/repository_interface.dart';

abstract class DeliverymanRegistrationRepositoryInterface extends RepositoryInterface{
  @override
  Future getList({int? offset, int? zoneId, bool isZone = true, bool isVehicle = false});
  Future<bool> registerDeliveryMan(DeliveryManBody deliveryManBody, List<MultipartBody> multiParts);
}
