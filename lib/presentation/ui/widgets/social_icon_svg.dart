import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/widgets/widget_extensions.dart';

/// Reusable widget for displaying social media SVG icons with links
/// Supports customizable colors, sizes, and tooltips
class SocialIconSvg extends StatelessWidget {
  /// Path to the SVG asset file
  final String svgPath;

  /// URL that the icon links to
  final String url;

  /// Color for the icon and background styling
  final Color color;

  /// Tooltip text displayed on hover
  final String tooltip;

  /// Whether to apply color tinting to the SVG
  final bool tint;

  /// Size of the icon in logical pixels (default: 18)
  final double iconSize;

  /// Internal padding of the container (default: 8)
  final double padding;
  const SocialIconSvg({
    super.key,
    required this.svgPath,
    required this.url,
    required this.color,
    required this.tooltip,
    this.tint = false,
    this.iconSize = 18,
    this.padding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => context.openUrl(url),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: tint
              ? SvgPicture.asset(
                  svgPath,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                )
              : SvgPicture.asset(svgPath, width: iconSize, height: iconSize),
        ),
      ),
    );
  }
}

/// Widget for displaying a row of social media icons
/// Automatically generates icons based on available social media data
class SocialIconsRow extends StatelessWidget {
  /// Social media information object (Map with keys like 'twitter', 'linkedin', etc.)
  final Social social;

  /// Horizontal spacing between icons (default: 4)
  final double spacing;

  /// Size of the icons in logical pixels (default: 18)
  final double iconSize;
  const SocialIconsRow({
    super.key,
    required this.social,
    this.spacing = 4,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> socialIcons = [];

    // Twitter/X using SVG
    if (social.twitter != null && social.twitter!.isNotEmpty) {
      socialIcons.add(
        SocialIconSvg(
          svgPath: 'assets/X_icon.svg',
          url: social.twitter!,
          color: const Color(0xFF000000),

          tooltip: 'Twitter/X',
          tint: true,
          iconSize: iconSize,
        ),
      );
    } else {
      SizedBox.shrink();
    }

    // LinkedIn using SVG
    if (social.linkedin != null && social.linkedin!.isNotEmpty) {
      socialIcons.add(
        SocialIconSvg(
          svgPath: 'assets/LinkedIn_icon.svg',
          url: social.linkedin!,
          color: const Color(0xFF000000),
          tooltip: 'LinkedIn',
          iconSize: iconSize,
        ),
      );
    } else {
      SizedBox.shrink();
    }

    // GitHub using SVG
    if (social.github != null && social.github!.isNotEmpty) {
      socialIcons.add(
        SocialIconSvg(
          svgPath: 'assets/GitHub_icon.svg',
          url: social.github!,
          color: const Color(0xFF000000),
          tooltip: 'GitHub',
          tint: true,
          iconSize: iconSize,
        ),
      );
    } else {
      SizedBox.shrink();
    }

    // Website using SVG
    if (social.website != null && social.website!.isNotEmpty) {
      socialIcons.add(
        SocialIconSvg(
          svgPath: 'assets/Website_icon.svg',
          url: social.website!,
          color: const Color(0xFF000000),
          tooltip: 'Website',
          tint: true,
          iconSize: iconSize,
        ),
      );
    } else {
      SizedBox.shrink();
    }

    if (socialIcons.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: spacing,
      children: socialIcons
          .map(
            (icon) => Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: icon,
            ),
          )
          .toList(),
    );
  }
}
