import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/bien.dart';
import '../entities/bien_summary.dart';

abstract class BiensRepository {
  Future<Either<Failure, Bien>> getBienById(int id);

  Future<Either<Failure, BienSummary>> scanQrCode(String qrData);

  Future<Either<Failure, List<BienSummary>>> getRecentBiens();

  Future<Either<Failure, Unit>> saveRecentBien(BienSummary bien);
}
