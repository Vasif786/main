import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pdf_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> pdfList = [];

  @override
  void initState() {
    super.initState();
    loadPDFs();
  }

  Future<void> loadPDFs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pdfList = prefs.getStringList('pdfs') ?? [];
    });
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String path = result.files.single.path!;
      pdfList.add(path);

      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('pdfs', pdfList);

      setState(() {});
    }
  }

  void openPDF(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfReaderScreen(path: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My PDFs")),
      floatingActionButton: FloatingActionButton(
        onPressed: pickPDF,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: pdfList.length,
        itemBuilder: (context, index) {
          String path = pdfList[index];
          return ListTile(
            title: Text(path.split('/').last),
            onTap: () => openPDF(path),
          );
        },
      ),
    );
  }
}