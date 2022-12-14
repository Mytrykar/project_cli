part of 'cli.dart';

/// Thrown when `flutter packages get` or `flutter pub get`
/// is executed without a `pubspec.yaml`.
class PubspecNotFound implements Exception {}

// void main(List<String> args) {
//   print(FlutterCli.isFlutterProject(Directory.current.path));
// }

class FlutterCli {
  static final PubspecYaml yaml =
      File("${Directory.current.path}/pubspec.yaml").existsSync()
          ? File("${Directory.current.path}/pubspec.yaml")
              .readAsStringSync()
              .toPubspecYaml()
          : throw PubspecNotFound;
  static String get projectName => yaml.name;

  static Future<bool> isFlutterProject(String path) async {
    if (!File("$path/pubspec.yaml").existsSync()) return false;
    final yaml = File("$path/pubspec.yaml").readAsStringSync().toPubspecYaml();
    return yaml.customFields.containsKey("flutter");
  }

  static Future<void> pubAdd(String package, path) async {
    try {
      await Cli.run("flutter", ["pub", "add", package], workingDirectory: path);
    } finally {
      Logger().info(package);
    }
  }

  static Future<void> pubAddDEVDed(String package, path) async {
    try {
      await Cli.run("flutter", ["pub", "add", package, "--dev"],
          workingDirectory: path);
    } finally {
      Logger().info(package);
    }
  }

  static Future<void> create(Logger logger,
      {required ProjectType projectType,
      required String projectName,
      required String dir,
      required String platforms}) async {
    assert(projectType == ProjectType.app);
    try {
      await Cli.run(
        'flutter',
        [
          'create',
          dir,
          "--project-name",
          projectName.toLowerCase(),
          "--platforms=$platforms",
          "--no-pub"
        ],
      );
      logger.info("""
Create flutter App
""");
    } catch (e) {
      logger.err("An error occurred while creating Flutter App");
      rethrow;
    }
  }

  /// Determine whether flutter is installed.
  static Future<bool> get installed async {
    try {
      await Cli.run('flutter', ['--version']);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Install dart dependencies (`flutter pub get`).
  static Future<void> pubGet({
    String cwd = '.',
  }) async {
    await Cli.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: cwd,
    );
  }

  /// run generators (`flutter pub run build_runner build --delete-conflicting-outputs`).
  static Future<void> runBuildRunner({
    String cwd = '.',
    bool recursive = false,
  }) async {
    await Cli.start(
      'flutter',
      ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: cwd,
    );
  }
}
