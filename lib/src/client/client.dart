import 'package:logging/logging.dart';

final class Client {
  static final Logger logger = Logger("Client");

  static Future<void> initialize() async {
    logger.level = Level.ALL;
    logger.onRecord.listen((LogRecord record) {
      final String built =
          "GAME___[${record.level.name.padRight(7)}]: ${record.time.year}-${record.time.month}-${record.time.day}, ${record.time.hour}:${record.time.minute}:${record.time.millisecond}: ${record.message}";
      print(built);
    });
    logger.info("Initalized all client resources.");
  }
}
