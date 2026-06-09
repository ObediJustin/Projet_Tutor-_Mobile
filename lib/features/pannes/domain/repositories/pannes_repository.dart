import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/panne.dart';

abstract class PannesRepository {
  Future<Either<Failure, List<Panne>>> getMesPannes({String? statut});
  
  Future<Either<Failure, Panne>> getPanneDetail(int id);
  
  Future<Either<Failure, Panne>> declarerPanne({
    required int idBien,
    required String typePanne,
    required String priorite,
    required String description,
  });
  
  Future<Either<Failure, Panne>> changerStatutPanne(int id, String statut);
  
  Future<Either<Failure, List<Panne>>> getRecentPannesLocal();
}
