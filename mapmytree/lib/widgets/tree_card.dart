import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/tree_model.dart';

class TreeCard extends StatelessWidget {
  final TreeModel tree;
  final VoidCallback onTap;

  const TreeCard({super.key, required this.tree, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Tree icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    tree.iconEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Tree info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tree.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        Icon(
                          tree.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: tree.isFavorite
                              ? Colors.redAccent
                              : AppTheme.textLight,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tree.species,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _tag(Icons.location_on_rounded, tree.location, AppTheme.primary),
                        const SizedBox(width: 8),
                        _healthBadge(tree.healthScore),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _infoChip('${tree.height}m', Icons.height_rounded),
                        const SizedBox(width: 10),
                        _infoChip('${tree.co2} kg CO₂', Icons.eco_rounded),
                        const SizedBox(width: 10),
                        _infoChip(tree.age, Icons.schedule_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label.length > 18 ? '${label.substring(0, 18)}…' : label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _healthBadge(double score) {
    final color = score >= 90
        ? AppTheme.primary
        : score >= 75
            ? AppTheme.accent
            : AppTheme.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${score.toInt()}% Health',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 11, color: AppTheme.textLight),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
