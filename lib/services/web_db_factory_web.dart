import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web build: returns the WASM-backed database factory which persists
/// data inside the browser via IndexedDB.
DatabaseFactory? getWebDatabaseFactory() => databaseFactoryFfiWeb;
