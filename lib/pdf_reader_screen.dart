import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfReaderScreen extends StatefulWidget {
  final String path;

  PdfReaderScreen({required this.path});

  @override
  _PdfReaderScreenState createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _controller = PdfViewerController();
  bool isRTL = true;
  int currentPage = 1;

  Future<void> saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(widget.path, currentPage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bookmark saved (Page $currentPage)")),
    );
  }

  Future<void> loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    int? page = prefs.getInt(widget.path);

    if (page != null) {
      _controller.jumpToPage(page);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), loadBookmark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reader"),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: saveBookmark,
          ),
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                isRTL = !isRTL;
              });
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: SfPdfViewer.file(
          File(widget.path),

          controller: _controller,

          scrollDirection: PdfScrollDirection.horizontal,
          pageLayoutMode: PdfPageLayoutMode.single,

          initialZoomLevel: 1.0,

          onPageChanged: (details) {
            currentPage = details.newPageNumber;
          },
        ),
      ),
    );
  }
}