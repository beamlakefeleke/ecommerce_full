import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_instruction.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class GetParcelInstructionUseCase {
  final ParcelRepositoryInterface repository;

  GetParcelInstructionUseCase(this.repository);

  Future<Either<Failure, List<ParcelInstruction>>> call(int offset) async {
    return await repository.getParcelInstructionList(offset: offset);
  }
}
