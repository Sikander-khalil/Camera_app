import 'package:camera/camera.dart';
import 'package:develope_someting/main.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScannerScreen extends StatefulWidget {
  final CameraDescription camera;
  const QrScannerScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  CameraController? _cameraController;
  QRViewController? _qrViewController;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool _isCameraInitialized = false;

  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _qrViewController!.dispose();
    _cameraController?.dispose();

    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    if (status.isGranted) {
      _initializedCamera();
    }
  }

  void _initializedCamera() {
    availableCameras().then((cameras) {
      final rearCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first);

      _cameraController = CameraController(rearCamera, ResolutionPreset.max);
      _cameraController!.initialize().then((value) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isCameraInitialized = true;
        });
      });
    });
  }

  void _onQrViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });

    _qrViewController!.scannedDataStream.listen((scanData) async {
      if (await canLaunch(scanData.code!)) {
        await launch(scanData.code!);
      } else {
        print("Scaan not lauch");
      }
    });

    _qrViewController!.toggleFlash();
    _setCameraMode(FocusMode.auto);

    _cameraController!.startImageStream((cameraImage) {
      if (_qrViewController != null) {
        final qrCode = _decodedQrCode(cameraImage);
        if (qrCode != null) {
          _qrViewController!.pauseCamera();
        }
      }
    });
  }

  Future<void> _setCameraMode(FocusMode focusMode) async {
    final currentFocusMode = _cameraController!.value.focusMode;
    if (currentFocusMode == focusMode) {
      return;
    }
    await _cameraController!.setFocusMode(focusMode);
  }

  String? _decodedQrCode(CameraImage cameraImage) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("QrScanner"),
          actions: [Text("")],
        ),
        body: Column(
          children: [
            Expanded(
                child: _isCameraInitialized
                    ? QRView(
                        key: qrKey,
                        onQRViewCreated: _onQrViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderRadius: 10,
                          borderColor: Colors.white,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 300,
                        ),
                      )
                    : Container())
          ],
        ),
      ),
    );
  }
}
