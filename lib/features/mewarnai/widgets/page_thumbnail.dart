import 'package:flutter/widgets.dart';

import '../../../core/content/coloring.dart';
import '../mewarnai_model.dart';
import '../mewarnai_painter.dart';

/// Gambar kecil satu halaman untuk kartu Galeri dan pemilih halaman.
class PageThumbnail extends StatelessWidget {
  const PageThumbnail({
    super.key,
    required this.halaman,
    required this.data,
    this.width = 184,
    this.height = 138,
  });

  final ColoringPage halaman;
  final KaryaData data;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1EAD8), width: 2),
        ),
        child: RepaintBoundary(
          child: ColoringView(
            halaman: halaman,
            data: data,
            width: width - 4,
            height: height - 4,
            radius: 12,
          ),
        ),
      ),
    );
  }
}
