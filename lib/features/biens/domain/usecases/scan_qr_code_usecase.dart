import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/bien_summary.dart';
import '../repositories/biens_repository.dart';

@lazySingleton
class ScanQrCodeUseCase {
  ScanQrCodeUseCase(this._repository);

  final BiensRepository _repository;

  Future<Either<Failure, BienSummary>> call(String qrData) =>
      _repository.scanQrCode(qrData);
}
