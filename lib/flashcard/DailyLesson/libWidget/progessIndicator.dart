import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:vibration/vibration.dart';

class ProgressBar extends StatefulWidget {
  ProgressBar({super.key, required this.value, required this.inARow});
  double value;
  int inARow;
  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: (widget.value - 0.08).clamp(0, 1),
        end: widget.value.clamp(0, 1),
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth * value;
            final left = constraints.maxWidth < (width + 80)
                ? (width - 80).clamp(0.0, constraints.maxWidth - 40.0)
                : width;
            Color streakColor(int streak) {
              if (streak < 3) return AppColor.greenPrimary;
              if (streak < 6) return AppColor.yellowPrimary;
              if (streak < 9) return AppColor.primaryTeal;
              return AppColor.redPrimary;
            }

            Color sco = streakColor(widget.inARow);
            return Stack(
              children: [
                Container(
                  height: 23,
                  decoration: BoxDecoration(
                    color: AppColor.darkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  height: 23,
                  width: width,
                  decoration: BoxDecoration(
                    color: sco,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: (widget.inARow > 2)
                        ? [
                            BoxShadow(
                              color: streakColor(
                                widget.inARow,
                              ).withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [], // Use an empty list to represent 'no shadows'
                  ),
                ),
                if (widget.inARow > 2)
                  Positioned(
                    left: left,
                    child: Container(
                      width: 80,
                      height: 23,
                      child: TextAnime(streak: widget.inARow, co: sco),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class TextAnime extends StatefulWidget {
  TextAnime({super.key, required this.streak, required this.co});

  final streak;
  Color co;
  @override
  State<TextAnime> createState() => _TextAnimeState();
}

class _TextAnimeState extends State<TextAnime>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    HapticFeedback.lightImpact();
    HapticFeedback.mediumImpact();
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant TextAnime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streak != widget.streak) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Text(
        "${widget.streak} Streak",
        style: TextStyle(
          color: widget.co,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
