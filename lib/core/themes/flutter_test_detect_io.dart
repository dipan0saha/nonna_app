import 'dart:io';

bool get isRunningFlutterTest => Platform.environment['FLUTTER_TEST'] == 'true';
