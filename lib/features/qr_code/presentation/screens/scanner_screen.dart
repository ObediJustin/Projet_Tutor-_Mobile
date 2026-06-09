import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../biens/presentation/bloc/biens_bloc.dart';
import '../../../biens/presentation/bloc/biens_event.dart';
import '../../../biens/presentation/bloc/biens_state.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    if (!mounted) return;
    context.read<BiensBloc>().add(ScanQrCode(rawValue));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scanner QR')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Le scanner QR nécessite un appareil mobile ou Windows desktop. '
              'Utilisez l\'application sur Android, iOS ou Windows.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: BlocListener<BiensBloc, BiensState>(
        listener: (context, state) {
          if (state is ScanQrCodeLoaded) {
            context.push(AppRouter.bienDetailPath(state.summary.idBien));
            setState(() => _isProcessing = false);
            _controller.start();
            context.read<BiensBloc>().add(const ResetScan());
          } else if (state is BiensError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.errorColor,
              ),
            );
            setState(() => _isProcessing = false);
            _controller.start();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black54,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _isProcessing
                      ? 'Recherche du bien...'
                      : 'Placez le QR code dans le cadre',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            if (_isProcessing)
              const ColoredBox(
                color: Colors.black38,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
