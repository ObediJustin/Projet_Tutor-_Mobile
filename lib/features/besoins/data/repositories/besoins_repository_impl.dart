import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/besoin.dart';
import '../../domain/repositories/besoins_repository.dart';
import '../datasources/besoins_local_data_source.dart';
import '../datasources/besoins_remote_data_source.dart';

@LazySingleton(as: BesoinsRepository)
class BesoinsRepositoryImpl implements BesoinsRepository {
  BesoinsRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  final BesoinsRemoteDataSource remoteDataSource;
  final BesoinsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Besoin>>> getBesoinsAValider({bool fromCache = false}) async {
    if (fromCache) {
      try {
        final localBesoins = await localDataSource.getCachedBesoinsAValider();
        return Right(localBesoins);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final remoteBesoins = await remoteDataSource.getBesoinsAValider();
        localDataSource.cacheBesoinsAValider(remoteBesoins);
        return Right(remoteBesoins);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      try {
        final localBesoins = await localDataSource.getCachedBesoinsAValider();
        return Right(localBesoins);
      } on CacheException {
        return const Left(NetworkFailure('Pas de connexion internet et aucun cache disponible.'));
      }
    }
  }

  @override
  Future<Either<Failure, Besoin>> getBesoinById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBesoin = await remoteDataSource.getBesoinById(id);
        return Right(remoteBesoin);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      return const Left(NetworkFailure('Pas de connexion internet.'));
    }
  }

  @override
  Future<Either<Failure, Besoin>> validerBesoin(int id, String decision, String? commentaire) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBesoin = await remoteDataSource.validerBesoin(id, decision, commentaire);
        return Right(remoteBesoin);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      return const Left(NetworkFailure('Pas de connexion internet. Impossible de valider un besoin hors-ligne.'));
    }
  }
}
