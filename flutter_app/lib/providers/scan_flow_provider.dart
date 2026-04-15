import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanFlowRequest {
  const ScanFlowRequest({
    required this.imageFile,
    required this.fieldId,
    required this.state,
    required this.district,
    required this.season,
    required this.crop,
    required this.language,
  });

  final File imageFile;
  final String fieldId;
  final String state;
  final String district;
  final String season;
  final String crop;
  final String language;
}

final scanFlowRequestProvider = StateProvider<ScanFlowRequest?>((ref) => null);
