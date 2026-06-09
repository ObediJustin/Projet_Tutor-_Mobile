import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/piece_rechange.dart';

abstract class PiecesRepository {
  Future<Either<Failure, List<PieceRechange>>> getPieces({bool fromCache = false, int skip = 0, int limit = 100, bool? estActive});
  Future<Either<Failure, PieceRechange>> getPieceById(int id);
}
