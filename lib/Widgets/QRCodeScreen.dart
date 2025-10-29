import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QRCodeScreen extends StatelessWidget {
  final String qrCodeBase64;

  QRCodeScreen(this.qrCodeBase64);

  @override
  Widget build(BuildContext context) {
    final qrSvg = base64Decode(qrCodeBase64);

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Center(
        child: SvgPicture.memory(qrSvg, width: 200, height: 200),
      ),
    );
  }
}
