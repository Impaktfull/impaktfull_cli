import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/integrations/appcenter/plugin/appcenter_plugin.dart';
import 'package:impaktfull_cli/src/integrations/apple_certificate/command/apple_certificate_root_command.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_parser_extensions.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/core/util/runner/runner.dart';
import 'package:impaktfull_cli/src/integrations/apple_certificate/plugin/mac_os_keychain_plugin.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/plugin/ci_cd_plugin.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/plugin/flutter_build_plugin.dart';
import 'package:impaktfull_cli/src/integrations/one_password/plugin/one_password_plugin.dart';
import 'package:impaktfull_cli/src/integrations/playstore/plugin/playstore_plugin.dart';
import 'package:impaktfull_cli/src/integrations/testflight/plugin/testflight_plugin.dart';

typedef ImpaktfullCliRunner<T extends ImpaktfullCli> = Future<void> Function(
    T cli);

class ImpaktfullCli {
  final ProcessRunner processRunner;

  late final Set<ImpaktfullPlugin> _defaultPlugins;
  late final Set<Command<dynamic>> _commands;

  ImpaktfullCli({
    this.processRunner = const CliProcessRunner(),
  });

  Set<Command<dynamic>> get commands => _commands;

  OnePasswordPlugin get onePasswordPlugin => _getPlugin();

  MacOsKeyChainPlugin get macOsKeyChainPlugin => _getPlugin();

  FlutterBuildPlugin get flutterBuildPlugin => _getPlugin();

  AppCenterPlugin get appCenterPlugin => _getPlugin();

  TestFlightPlugin get testflightPlugin => _getPlugin();

  PlayStorePlugin get playStorePlugin => _getPlugin();

  CiCdPlugin get ciCdPlugin => _getPlugin();

  Set<ImpaktfullPlugin> get plugins => {};

  T _getPlugin<T extends ImpaktfullPlugin>() {
    var plugin = _defaultPlugins.whereType<T>().firstOrNull;
    plugin ??= plugins.whereType<T>().firstOrNull;
    if (plugin == null) throw ImpaktfullCliError('$T not found in plugins');
    return plugin;
  }

  void init() {
    _initCommands();
    _initPlugins();
  }

  void _initCommands() {
    _commands = {
      AppleCertificateRootCommand(processRunner: processRunner),
    };
  }

  void _initPlugins() {
    final onePasswordPlugin = OnePasswordPlugin(processRunner: processRunner);
    final macOsKeyChainPlugin =
        MacOsKeyChainPlugin(processRunner: processRunner);
    final flutterBuildPlugin = FlutterBuildPlugin(processRunner: processRunner);
    final appCenterPlugin = AppCenterPlugin();
    final testflightPlugin = TestFlightPlugin(processRunner: processRunner);
    final playStorePlugin = PlayStorePlugin(processRunner: processRunner);
    _defaultPlugins = {
      onePasswordPlugin,
      macOsKeyChainPlugin,
      flutterBuildPlugin,
      appCenterPlugin,
      testflightPlugin,
      playStorePlugin,
      CiCdPlugin(
        onePasswordPlugin: onePasswordPlugin,
        macOsKeyChainPlugin: macOsKeyChainPlugin,
        flutterBuildPlugin: flutterBuildPlugin,
        appCenterPlugin: appCenterPlugin,
        testflightPlugin: testflightPlugin,
        playStorePlugin: playStorePlugin,
      ),
    };
  }

  Future<void> run(
    ImpaktfullCliRunner<ImpaktfullCli> runner, {
    bool isVerboseLoggingEnabled = false,
  }) async {
    init();
    await runImpaktfullCli(
      () => runner(this),
      isVerboseLoggingEnabled: isVerboseLoggingEnabled,
    );
  }

  Future<void> runCli(List<String> args) async {
    init();
    await runImpaktfullCli(() async {
      final runner = CommandRunner('impaktfull_cli',
          'A cli that replaces `fastlane` by simplifying the CI/CD process.');
      runner.argParser.addGlobalFlags();

      for (final command in commands) {
        runner.addCommand(command);
      }
      final argResults = runner.argParser.parse(args);
      ImpaktfullCliLogger.init(
          isVerboseLoggingEnabled: argResults.isVerboseLoggingEnabled());
      await runner.run(args);
    });
  }
}
