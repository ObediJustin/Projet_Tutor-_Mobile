import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/piece_rechange.dart';
import '../repositories/pieces_repository.dart';

@lazySingleton
class GetPieces {
  GetPieces(this.repository);

  final PiecesRepository repository;

  Future<Either<Failure, List<PieceRechange>>> call({
    bool fromCache = false,
    int skip = 0,
    int limit = 100,
    bool? estActive,
  }) {
    return repository.getPieces(
      fromCache: fromCache,
      skip: skip,
      limit: limit,
      estActive: estActive,
    );
  }
}

@lazySingleton
class GetPieceById {
  GetPieceById(this.repository);

  final PiecesRepository repository;

  Future<Either<Failure, PieceRechange>> call(int id) {
    return repository.getPieceById(id);
  }
}
