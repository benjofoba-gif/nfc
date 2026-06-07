// Platform-aware export: re-exports the platform-specific implementation.
export 'log_storage_io.dart' if (dart.library.html) 'log_storage_web.dart';

