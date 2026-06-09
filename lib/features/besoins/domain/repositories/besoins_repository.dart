import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/besoin.dart';

abstract class BesoinsRepository {
  Future<Either<Failure, List<Besoin>>> getBesoinsAValider({bool fromCache = false});
  Future<Either<Failure, Besoin>> getBesoinById(int id);
  Future<Either<Failure, Besoin>> validerBesoin(int id, String decision, String? commentaire);
}
