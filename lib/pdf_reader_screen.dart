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
  bool isRTL = true;

  late PDFViewController _controller;

  // 🔖 Save Bookmark
  Future<void> saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(widget.path, currentPage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bookmark saved (Page ${currentPage + 1})")),
    );
  }

  // 🔖 Load Bookmark
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

  // 👉 RTL / LTR swipe control
  void nextPage() async {
    if (currentPage < totalPages - 1) {
      await _controller.setPage(currentPage + 1);
    }
  }

  void previousPage() async {
    if (currentPage > 0) {
      await _controller.setPage(currentPage - 1);
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
                isRTL = !isRTL;
              });
            },
          ),
        ],
      ),

      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (!isReady) return;

          if (isRTL) {
            // 👉 RTL (Quran style)
            if (details.primaryVelocity! > 0) {
              nextPage();
            } else {
              previousPage();
            }
          } else {
            // 👉 LTR
            if (details.primaryVelocity! > 0) {
              previousPage();
            } else {
              nextPage();
            }
          }
        },

        child: Container(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              PDFView(
                filePath: widget.path,

                // ❗ vertical mode = better full page fit
                swipeHorizontal: false,
                enableSwipe: true,
                pageFling: false,
                pageSnap: true,

                autoSpacing: false,
                fitPolicy: FitPolicy.WIDTH,

                defaultPage: currentPage,

                onViewCreated: (controller) {
                  _controller = controller;
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
      ),
    );
  }
}