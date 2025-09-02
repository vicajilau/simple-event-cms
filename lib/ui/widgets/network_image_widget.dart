import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable widget that automatically detects and displays both SVG and raster images
/// from network URLs with proper loading states and error handling.
class NetworkImageWidget extends StatelessWidget {
  /// The URL of the image to display
  final String imageUrl;

  /// How to fit the image within its container
  final BoxFit fit;

  /// The width of the widget
  final double? width;

  /// The height of the widget
  final double? height;

  /// Widget to display while loading
  final Widget? placeholder;

  /// Widget to display on error
  final Widget? errorWidget;

  /// Border radius for the image
  final BorderRadius? borderRadius;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  /// Helper method to determine if a URL points to an SVG file
  bool _isSvgUrl(String url) {
    return url.toLowerCase().endsWith('.svg');
  }

  /// Default loading widget
  Widget _defaultLoadingWidget(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Default error widget
  Widget _defaultErrorWidget(BuildContext context) {
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_isSvgUrl(imageUrl)) {
      // Handle SVG images
      imageWidget = SvgPicture.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder: (context) =>
            placeholder ?? _defaultLoadingWidget(context),
      );
    } else {
      // Handle raster images (PNG, JPG, etc.)
      imageWidget = Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _defaultErrorWidget(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _defaultLoadingWidget(context);
        },
      );
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}
