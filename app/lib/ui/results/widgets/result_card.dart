import 'package:cached_network_image/cached_network_image.dart';
import 'package:compass_app/domain/models/destination/destination.dart';
import 'package:compass_app/ui/core/ui/tag_chip.dart';
import 'package:compass_app/utils/image_error_listener.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({required this.destination, required this.onTap, super.key});

  final Destination destination;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: destination.imageUrl,
            fit: BoxFit.fitHeight,
            errorWidget: (context, url, error) => const Icon(Icons.error),
            errorListener: imageErrorListener,
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(destination.name.toUpperCase(), style: _cardTitleStyle),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      destination.tags.map((e) => TagChip(tag: e)).toList(),
                ),
              ],
            ),
          ),
          // Handle taps
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

final TextStyle _cardTitleStyle = GoogleFonts.rubik(
  textStyle: const TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 15,
    color: Colors.white,
    letterSpacing: 1,
    shadows: [
      // Helps to read the text a bit better
      Shadow(blurRadius: 3),
    ],
  ),
);
