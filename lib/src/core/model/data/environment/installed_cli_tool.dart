import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';

class InstalledCliTool {
  final CliTool cliTool;
  final String? _path;
  final bool isInstalled;

  String get path => isInstalled
      ? _path!
      : throw ImpaktfullCliError(
          '${cliTool.commandName} (${cliTool.name}) is not available, so not possible to fetch path');

  const InstalledCliTool.installed({
    required this.cliTool,
    required String path,
  })  : isInstalled = true,
        _path = path;

  const InstalledCliTool.notInstalled({
    required this.cliTool,
  })  : isInstalled = false,
        _path = null;
}
