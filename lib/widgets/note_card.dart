import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String? timestamp;
  final bool showTitle;
  final bool showActions;
  final VoidCallback? onSend;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    this.timestamp,
    this.showTitle = false,
    this.showActions = false,
    this.onSend,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0A84FF).withOpacity(0.35),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.push_pin,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF0A84FF), size: 16),
                  ],
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      timestamp!,
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showActions) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onSend,
                  icon: const Icon(Icons.stop,
                      color: Color(0xFFFF453A), size: 16),
                  tooltip: 'إرسال',
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit,
                      color: Color(0xFFFFD60A), size: 16),
                  tooltip: 'تعديل',
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFFF453A), size: 16),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
