import 'package:equatable/equatable.dart';

abstract class BiensEvent extends Equatable {
  const BiensEvent();

  @override
  List<Object?> get props => [];
}

class LoadBienDetail extends BiensEvent {
  final int bienId;

  const LoadBienDetail(this.bienId);

  @override
  List<Object?> get props => [bienId];
}

class ScanQrCode extends BiensEvent {
  final String qrData;

  const ScanQrCode(this.qrData);

  @override
  List<Object?> get props => [qrData];
}

class ResetScan extends BiensEvent {
  const ResetScan();
}
