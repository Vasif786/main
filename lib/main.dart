import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PdfHomePage(),
    );
  }
}

class PdfHomePage extends StatefulWidget {
  @override
  _PdfHomePageState createState() => _PdfHomePageState();
}

class _PdfHomePageState extends State<PdfHomePage> {
  File? pdfFile;

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        pdfFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Reader App"),
      ),
      body: pdfFile == null
          ? Center(
              child: Text("No PDF Selected"),
            )
          : SfPdfViewer.file(
              pdfFile!,
              pageLayoutMode: PdfPageLayoutMode.continuous,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickPDF,
        child: Icon(Icons.upload_file),
      ),
    );
  }
}
