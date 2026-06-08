import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/bien_summary.dart';
import '../repositories/biens_repository.dart';

@lazySingleton
class GetRecentBiensUseCase {
  GetRecentBiensUseCase(this._repository);

  final BiensRepository _repository;

  Future<Either<Failure, List<BienSummary>>> call() => _repository.getRecentBiens();
}
