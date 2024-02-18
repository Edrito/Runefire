import 'dart:io';
import 'package:image_size_getter/file_input.dart';
import 'package:recase/recase.dart';
import 'package:image_size_getter/image_size_getter.dart';

main(List<String> params) async {
  final assetsFolder = Directory('assets');
  await parseFolder(assetsFolder, null);

  const newDirectory = r'lib\resources\assets';
  await Directory(newDirectory).create();

  var gigaFile =
      "// ignore_for_file: library_private_types_in_public_api, unused_field \nimport 'package:flame/components.dart';\n";

  gigaFile +=
      r'extension Vector2Extension on (double, double)? {Vector2 get asVector2 => this == null ? Vector2.zero() : Vector2(this!.$1, this!.$2);}';
  gigaFile += '\n';
  gigaFile +=
      'typedef FileDataClass = ({  String path,  String flamePath,  (double, double)? size,int? potentialFrameCount} );';
  gigaFile += '\n';

  for (final element in filesToSave.values) {
    gigaFile += element;
  }
  await File('$newDirectory\\assets.dart').writeAsString(gigaFile);
}

Map<String, String> filesToSave = {};

String generateClassName(String directory, String? leading) {
  final directoryName = directory.split(r'\').last;
  var className = directoryName.pascalCase;
  if (leading != null) {
    className = '${leading.pascalCase}Assets$className';
  }
  return className;
}

Future<void> parseFolder(Directory directory, String? leading) async {
  // final directoryName = directory.path.split('/').last;
  filesToSave[directory.path] = '';
  var dartFile = '';
  final createLeading = leading == null;
  final className = generateClassName(directory.path, leading);
  dartFile += 'class $className {\n';
  // dartFile += "const $className();\n";

  final fileList = await directory.list().toList();
  final containsFile = fileList.any((element) => element is File);

  final stringNames = <String>[];
  final pngSizes = <String, (double, double)>{};
  for (final element in fileList) {
    if (element is Directory) {
      print("    - ${element.path.replaceAll(r"\", "/")}/");
      if (createLeading) {
        leading = element.path.split(r'\').last;
      }
      await parseFolder(element, leading);
      // String newClassName = generateClassName(element.path);
      // dartFile +=
      //     "static const $newClassName ${newClassName.substring(1).camelCase}Folder = $newClassName(); \n";
    } else if (element is File) {
      final fileName = element.path.split(r'\').last;
      final fileNameWithoutExtension = fileName.split('.').first;
      final stringPath = element.path.replaceAll(r'\', '/');
      dartFile += '///$fileName\n';
      (double, double)? size;
      if (element.path.split('.').last == 'png') {
        final pngSize = ImageSizeGetter.getSize(FileInput(element));
        // ignore: unnecessary_string_interpolations
        // pngSizes["${fileNameWithoutExtension.camelCase}"] =
        //     (pngSize.width.toDouble(), pngSize.height.toDouble());
        size = (pngSize.width.toDouble(), pngSize.height.toDouble());
        // dartFile += "/// ${pngSize.width}x${pngSize.height} \n";
      }
      // dartFile +=
      //     "static const String ${fileNameWithoutExtension.camelCase} = \"$stringPath\";\n";

      dartFile +=
          'static const FileDataClass ${fileNameWithoutExtension.camelCase} = \n';
      dartFile +=
          '(path:"$stringPath",flamePath:"${stringPath.split('/').skip(2).join('/')}",'
          ' size:${size != null ? "(${size.$1},${size.$2})" : "null"},\n'
          ' potentialFrameCount:${size != null ? "${(size.$1 / size.$2).round()}" : "null"}   );';

      stringNames.add(fileNameWithoutExtension.camelCase);
    }
  }

  dartFile += 'static  List<String> allFiles = [';
  for (final element in stringNames) {
    dartFile += '$element.path,\n';
  }
  dartFile += '];\n';

  dartFile += 'static  List<String> allFilesFlame = [';
  for (final element in stringNames) {
    dartFile += '$element.flamePath,\n';
  }
  dartFile += '];\n';

  // dartFile += "static  Map<String, Vector2> pngSizes = {";
  // for (var element in pngSizes.entries) {
  //   dartFile +=
  //       "${element.key}: Vector2(${element.value.$1}, ${element.value.$2}),\n";
  // }
  // dartFile += "};\n";

  dartFile += '}\n';
  if (containsFile) {
    filesToSave[directory.path] = dartFile;
  }
}
