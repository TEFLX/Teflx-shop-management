import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';

// ================= BACKUP =================
Future<String?> backupDatabase() async {
  try {
    // 🔹 DB PATH
    String dbPath = await getDatabasesPath();
    String originalPath = join(dbPath, 'shop.db');

    // 🔹 PUBLIC DOWNLOAD FOLDER
    Directory dir = Directory('/storage/emulated/0/Download');

    // 🔹 FILE NAME
    String backupPath = join(
      dir.path,
      "shop_backup_${DateTime.now().millisecondsSinceEpoch}.db",
    );

    // 🔹 COPY DATABASE
    File original = File(originalPath);
    await original.copy(backupPath);

    return backupPath;
  } catch (e) {
    print("❌ Backup Error: $e");
    return null;
  }
}

// ================= RESTORE =================
Future<bool> restoreDatabase() async {
  try {
    // 🔥 FORCE PICK FILE (IMPORTANT)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    // 🔴 IF USER DID NOT SELECT FILE
    if (result == null || result.files.single.path == null) {
      print("❌ No file selected");
      return false;
    }

    String backupPath = result.files.single.path!;

    print("📂 Selected file: $backupPath");

    // 🔹 ORIGINAL DB PATH
    String dbPath = await getDatabasesPath();
    String originalPath = join(dbPath, 'shop.db');

    File backup = File(backupPath);

    if (await backup.exists()) {
      await backup.copy(originalPath);
      print("✅ Restore success");
      return true;
    } else {
      print("❌ File not found");
      return false;
    }
  } catch (e) {
    print("❌ Restore Error: $e");
    return false;
  }
}