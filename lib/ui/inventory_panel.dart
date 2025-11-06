import 'package:flutter/material.dart';
import '../state/inventory.dart';

class InventoryPanel extends StatelessWidget {
  final VoidCallback onClose;
  final int columns;
  final void Function(GameItem item)? onUseItem;

  const InventoryPanel({
    super.key,
    required this.onClose,
    this.columns = 6,
    this.onUseItem,
  });

  Future<void> _handleUseItem(BuildContext context, GameItem item) async {
    if (onUseItem == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sử dụng ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sử dụng')),
        ],
      ),
    );
    if (ok == true) {
      onUseItem!(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 700,
          height: 560,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Back_Pack_Nogrid.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    const Icon(
                      Icons.inventory_2,
                      size: 18,
                      color: Colors.brown,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Hành trang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClose,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Image.asset(
                          'assets/images/X_Button.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Inventory.instance,
                  builder: (context, _) {
                    final items = Inventory.instance.items;
                    const int rows = 4;
                    final int cols = columns;
                    const double gridLeftPct = 0.10;
                    const double gridTopPct = 0.20;
                    const double gridRightPct = 0.10;
                    const double gridBottomPct = 0.22;
                    const double spacingPx = 9.0;
                    const double inset = 2.0;
                    final int maxSlots = rows * cols;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final double w = constraints.maxWidth;
                        final double h = constraints.maxHeight;
                        final double left = w * gridLeftPct;
                        final double top = h * gridTopPct;
                        final double right = w * gridRightPct;
                        final double bottom = h * gridBottomPct;
                        final double gridW = w - left - right;
                        final double gridH = h - top - bottom;

                        final double cellWidth =
                            (gridW - spacingPx * (cols - 1)) / cols;
                        final double cellHeight =
                            (gridH - spacingPx * (rows - 1)) / rows;
                        final double cell =
                            cellWidth < cellHeight ? cellWidth : cellHeight;
                        final double totalW =
                            cell * cols + spacingPx * (cols - 1);
                        final double totalH =
                            cell * rows + spacingPx * (rows - 1);
                        final double startX = left + (gridW - totalW) / 2;
                        final double startY = top + (gridH - totalH) / 2;

                        final List<Widget> slotWidgets = [];
                        for (int index = 0; index < maxSlots; index++) {
                          final int row = index ~/ cols;
                          final int col = index % cols;
                          final double x =
                              startX + col * (cell + spacingPx) + inset;
                          final double y =
                              startY + row * (cell + spacingPx) + inset + 10;
                          final double renderSize =
                              (cell - 2.0).clamp(0, cell) - 2;
                          final GameItem? item =
                              index < items.length ? items[index] : null;

                          Widget tile = Container(
                            width: renderSize,
                            height: renderSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a1a2e),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.shade300,
                                  offset: const Offset(-1, -1),
                                ),
                                BoxShadow(
                                  color: Colors.brown.shade300,
                                  offset: const Offset(-2, -2),
                                ),
                                BoxShadow(
                                  color: Colors.brown.shade900.withOpacity(0.6),
                                  offset: const Offset(1, 1),
                                ),
                                BoxShadow(
                                  color: Colors.brown.shade900.withOpacity(0.6),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.brown.shade800,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            foregroundDecoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFB88A54),
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: item == null
                                ? const SizedBox.shrink()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Image.asset(
                                            item.imageAssetPath,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: renderSize * 0.22,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                          );

                          if (item != null && onUseItem != null) {
                            tile = GestureDetector(
                              onTap: () => _handleUseItem(context, item),
                              child: tile,
                            );
                          }

                          slotWidgets.add(
                            Positioned(
                              left: x,
                              top: y,
                              child: tile,
                            ),
                          );
                        }

                        return Stack(children: slotWidgets);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
