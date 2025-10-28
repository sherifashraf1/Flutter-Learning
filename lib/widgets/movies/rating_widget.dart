import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double? rating;
  final double maxRating;
  final int starCount;
  final double starSize;
  final Color filledStarColor;
  final Color emptyStarColor;
  final TextStyle? ratingTextStyle;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 10.0,
    this.starCount = 5,
    this.starSize = 16.0,
    this.filledStarColor = Colors.amber,
    this.emptyStarColor = Colors.grey,
    this.ratingTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Convert rating to 5-star scale
    final normalizedRating = ((rating ?? 0) / maxRating) * starCount;
    final filledStars = normalizedRating.floor();
    final hasHalfStar = normalizedRating - filledStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(starCount, (index) {
            if (index < filledStars) {
              // Filled star
              return Icon(
                Icons.star,
                color: filledStarColor,
                size: starSize,
              );
            } else if (index == filledStars && hasHalfStar) {
              // Half star
              return Icon(
                Icons.star_half,
                color: filledStarColor,
                size: starSize,
              );
            } else {
              // Empty star
              return Icon(
                Icons.star_border,
                color: emptyStarColor,
                size: starSize,
              );
            }
          }),
        ),
        const SizedBox(width: 6),
        // Rating number
        Text(
          rating?.toStringAsFixed(1) ?? "",
          style: ratingTextStyle ?? const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
