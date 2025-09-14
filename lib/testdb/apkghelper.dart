import 'package:file_picker/file_picker.dart';



Future<String?> pickApkgFile() async{
  FilePickerResult?result=await FilePicker.platform.pickFiles(
    type:FileType.custom,
    allowedExtensions: ['.apkg'],
  );
  if(result!=null)
  {
    return result.files.single.path;
  }else{
    return null;
  }
}