import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/besoin.dart';
import '../repositories/besoins_repository.dart';

@lazySingleton
class GetBesoinsAValider {
  GetBesoinsAValider(this.repository);

  final BesoinsRepository repository;

  Future<Either<Failure, List<Besoin>>> call({bool fromCache = false}) {
    return repository.getBesoinsAValider(fromCache: fromCache);
  }
}

@lazySingleton
class GetBesoinById {
  GetBesoinById(this.repository);

  final BesoinsRepository repository;

  Future<Either<Failure, Besoin>> call(int id) {
    return repository.getBesoinById(id);
  }
}

@lazySingleton
class ValiderBesoin {
  ValiderBesoin(this.repository);

  final BesoinsRepository repository;

  Future<Either<Failure, Besoin>> call(int id, String decision, String? commentaire) {
    return repository.validerBesoin(id, decision, commentaire);
  }
}
