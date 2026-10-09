import 'package:flutter/material.dart';
import 'package:parallax_mobile/config/theme.dart';

bool reducedMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Fade + rise entrance with an index-based delay for staggered lists/grids.
/// Renders immediately when the OS "remove animations" setting is on.
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  const StaggeredEntrance(
      {super.key, required this.index, required this.child});

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reducedMotion(context)) {
      _c.value = 1;
    } else {
      Future<void>.delayed(
        Duration(milliseconds: 50 * widget.index.clamp(0, 8)),
        () => mounted ? _c.forward() : null,
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: t,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - t.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Shimmering skeleton blocks (no extra dependency).
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducedMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        final dx = _c.value * 3 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment(dx - 1, -0.2),
            end: Alignment(dx + 1, 0.2),
            colors: const [
              AppTheme.cardDark,
              AppTheme.surfaceDark3,
              AppTheme.cardDark,
            ],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(r),
          child: child,
        );
      },
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Grid of card skeletons used while projects or media load.
class CardGridSkeleton extends StatelessWidget {
  final int count;
  final double aspectRatio;
  const CardGridSkeleton({super.key, this.count = 4, this.aspectRatio = 0.82});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
        padding: EdgeInsets.zero,
        children: List.generate(
          count,
          (_) => const SkeletonBox(height: double.infinity, radius: 16),
        ),
      ),
    );
  }
}

/// Stacked row skeletons for list screens (history, timeline loading).
class ListSkeleton extends StatelessWidget {
  final int rows;
  final double rowHeight;
  const ListSkeleton({super.key, this.rows = 5, this.rowHeight = 64});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < rows; i++) ...[
              SkeletonBox(height: rowHeight, radius: 14),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
