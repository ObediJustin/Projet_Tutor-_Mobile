import 'package:equatable/equatable.dart';

import '../../../biens/domain/entities/bien.dart';
import '../../../biens/domain/entities/bien_summary.dart';

abstract class BiensState extends Equatable {
  const BiensState();

  @override
  List<Object?> get props => [];
}

class BiensInitial extends BiensState {
  const BiensInitial();
}

class BiensLoading extends BiensState {
  const BiensLoading();
}

class BienDetailLoaded extends BiensState {
  final Bien bien;

  const BienDetailLoaded(this.bien);

  @override
  List<Object?> get props => [bien];
}

class ScanQrCodeLoaded extends BiensState {
  final BienSummary summary;

  const ScanQrCodeLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class BiensError extends BiensState {
  final String message;

  const BiensError(this.message);

  @override
  List<Object?> get props => [message];
}
