import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/piece_rechange.dart';
import '../../domain/repositories/pieces_repository.dart';
import '../datasources/pieces_local_data_source.dart';
import '../datasources/pieces_remote_data_source.dart';

@LazySingleton(as: PiecesRepository)
class PiecesRepositoryImpl implements PiecesRepository {
  PiecesRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  final PiecesRemoteDataSource remoteDataSource;
  final PiecesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<PieceRechange>>> getPieces({
    bool fromCache = false,
    int skip = 0,
    int limit = 100,
    bool? estActive,
  }) async {
    if (fromCache) {
      try {
        final localPieces = await localDataSource.getCachedPieces();
        return Right(localPieces);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final remotePieces = await remoteDataSource.getPieces(
          skip: skip,
          limit: limit,
          estActive: estActive,
        );
        localDataSource.cachePieces(remotePieces);
        return Right(remotePieces);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      try {
        final localPieces = await localDataSource.getCachedPieces();
        return Right(localPieces);
      } on CacheException {
        return const Left(NetworkFailure('Pas de connexion internet et aucun cache disponible.'));
      }
    }
  }

  @override
  Future<Either<Failure, PieceRechange>> getPieceById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePiece = await remoteDataSource.getPieceById(id);
        return Right(remotePiece);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }
  }
}
