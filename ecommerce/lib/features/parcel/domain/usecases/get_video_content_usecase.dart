import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/entities/video_content.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class GetVideoContentUseCase {
  final ParcelRepositoryInterface repository;

  GetVideoContentUseCase(this.repository);

  Future<Either<Failure, VideoContent>> call() async {
    return await repository.getVideoContentDetails();
  }
}
