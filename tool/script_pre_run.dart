import 'dart:io';

import 'package:path/path.dart';

void main(List<String> args) {
  final fileName = 'example_config';
  final basePath = join('example', 'bin');
  final file = File(join(basePath, fileName));
  file.copySync(join(basePath, '$fileName.dart'));
}
