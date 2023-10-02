import 'dart:io';
import 'package:image_size_getter/file_input.dart';
import 'package:recase/recase.dart';
import 'package:image_size_getter/image_size_getter.dart';

main(List<String> params) async {
  final Directory assetsFolder = Directory('assets');

  await parseFolder(assetsFolder, null);

  const String newDirectory = "lib\\resources\\assets";
  await Directory(newDirectory).create();

  String gigaFile =
      "// ignore_for_file: library_private_types_in_public_api, unused_field \n";

  gigaFile +=
      "extension StringExtension on String {String get flamePath => split('/').skip(2).join('/');}";
  gigaFile += "\n";

  for (var element in filesToSave.values) {
    gigaFile += element;
  }
  await File("$newDirectory\\assets.dart").writeAsString(gigaFile);
}

Map<String, String> filesToSave = {};

String generateClassName(String directory, String? leading) {
  final directoryName = directory.split('\\').last;
  String className = directoryName.pascalCase;
  if (leading != null) {
    className = "${leading.pascalCase}Assets$className";
  }
  return className;
}

Future<void> parseFolder(Directory directory, String? leading) async {
  // final directoryName = directory.path.split('/').last;
  filesToSave[directory.path] = "";
  String dartFile = "";
  bool createLeading = leading == null;
  final className = generateClassName(directory.path, leading);
  dartFile += "class $className {\n";
  // dartFile += "const $className();\n";

  final fileList = await directory.list(recursive: false).toList();
  bool containsFile = fileList.any((element) => element is File);

  List<String> stringNames = [];

  for (var element in fileList) {
    if (element is Directory) {
      print("    - ${element.path.replaceAll("\\", "/")}/");
      if (createLeading) {
        leading = element.path.split('\\').last;
      }
      await parseFolder(element, leading);
      // String newClassName = generateClassName(element.path);
      // dartFile +=
      //     "static const $newClassName ${newClassName.substring(1).camelCase}Folder = $newClassName(); \n";
    } else if (element is File) {
      final fileName = element.path.split('\\').last;
      final fileNameWithoutExtension = fileName.split('.').first;

      dartFile += "///$fileName\n";
      if (element.path.split('.').last == "png") {
        final pngSize = ImageSizeGetter.getSize(FileInput(element));

        dartFile += "/// ${pngSize.width}x${pngSize.height} \n";
      }
      dartFile +=
          "static const String ${fileNameWithoutExtension.camelCase} = \"${element.path.replaceAll('\\', '/')}\";\n";
      stringNames.add(fileNameWithoutExtension.camelCase);
    }
  }

  dartFile += "static const List<String> allFiles = [";
  for (var element in stringNames) {
    dartFile += "$element,\n";
  }
  dartFile += "];\n";

  dartFile += "static  List<String> allFilesFlame = [";
  for (var element in stringNames) {
    dartFile += "$element.flamePath,\n";
  }
  dartFile += "];\n";

  dartFile += "}\n";
  if (containsFile) {
    filesToSave[directory.path] = dartFile;
  }
}
