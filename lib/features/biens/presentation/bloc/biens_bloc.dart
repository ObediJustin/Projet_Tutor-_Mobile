import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_bien_by_id_usecase.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import 'biens_event.dart';
import 'biens_state.dart';

@injectable
class BiensBloc extends Bloc<BiensEvent, BiensState> {
  final GetBienByIdUseCase _getBienByIdUseCase;
  final ScanQrCodeUseCase _scanQrCodeUseCase;

  BiensBloc(
    this._getBienByIdUseCase,
    this._scanQrCodeUseCase,
  ) : super(const BiensInitial()) {
    on<LoadBienDetail>(_onLoadBienDetail);
    on<ScanQrCode>(_onScanQrCode);
    on<ResetScan>(_onResetScan);
  }

  Future<void> _onLoadBienDetail(LoadBienDetail event, Emitter<BiensState> emit) async {
    emit(const BiensLoading());
    final result = await _getBienByIdUseCase(event.bienId);
    result.fold(
      (failure) => emit(BiensError(failure.message)),
      (bien) => emit(BienDetailLoaded(bien)),
    );
  }

  Future<void> _onScanQrCode(ScanQrCode event, Emitter<BiensState> emit) async {
    emit(const BiensLoading());
    final result = await _scanQrCodeUseCase(event.qrData);
    result.fold(
      (failure) => emit(BiensError(failure.message)),
      (summary) => emit(ScanQrCodeLoaded(summary)),
    );
  }

  void _onResetScan(ResetScan event, Emitter<BiensState> emit) {
    emit(const BiensInitial());
  }
}
