import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../app/theme/moci_colors.dart';

/// Ilustrasi SVG dari `assets/illustrations/<id>.svg` (dikompilasi ke
/// vector_graphics saat build). [silhouette] mewarnai seluruh gambar dengan
/// satu warna tinta, dipakai Tebak Bayangan.
class MociIllustration extends StatelessWidget {
  const MociIllustration(
    this.id, {
    super.key,
    this.size = 120,
    this.silhouette = false,
    this.semanticLabel,
  });

  final String id;
  final double size;
  final bool silhouette;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return VectorGraphic(
      loader: AssetBytesLoader('assets/illustrations/$id.svg'),
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      colorFilter: silhouette
          ? const ColorFilter.mode(MociColors.ink, BlendMode.srcIn)
          : null,
    );
  }
}
