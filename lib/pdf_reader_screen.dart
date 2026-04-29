import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfReaderScreen extends StatefulWidget {
  final String path;

  PdfReaderScreen({required this.path});

  @override
  _PdfReaderScreenState createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  bool isRTL = true; // 👈 RTL default

  late PDFViewController _pdfController;

  Future<void> saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(widget.path, currentPage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bookmark saved (Page ${currentPage + 1})")),
    );
  }

  Future<void> loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    int? page = prefs.getInt(widget.path);

    if (page != null) {
      currentPage = page;
    }
  }

  @override
  void initState() {
    super.initState();
    loadBookmark();
  }

  void nextPage() async {
    if (_pdfController != null && currentPage < totalPages - 1) {
      await _pdfController.setPage(currentPage + 1);
    }
  }

  void previousPage() async {
    if (_pdfController != null && currentPage > 0) {
      await _pdfController.setPage(currentPage - 1);
    }
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
                isRTL = !isRTL; // 👈 switch RTL/LTR
              });
            },
          ),
        ],
      ),

      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (isRTL) {
            // 🔥 RTL mode
            if (details.primaryVelocity! > 0) {
              nextPage(); // swipe right → next
            } else {
              previousPage(); // swipe left → prev
            }
          } else {
            // 🔥 LTR mode
            if (details.primaryVelocity! > 0) {
              previousPage();
            } else {
              nextPage();
            }
          }
        },

        child: Stack(
          children: [
            PDFView(
              filePath: widget.path,

              swipeHorizontal: false, // ❗ disable default swipe
              autoSpacing: false,
              pageFling: false,

              fitPolicy: FitPolicy.WIDTH,
              defaultPage: currentPage,

              onViewCreated: (controller) {
                _pdfController = controller;
              },

              onRender: (pages) {
                setState(() {
                  totalPages = pages!;
                  isReady = true;
                });
              },

              onPageChanged: (page, total) {
                setState(() {
                  currentPage = page!;
                });
              },
            ),

            if (!isReady)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}