import 'package:flutter/material.dart';
import 'package:nonna_app/core/utils/dynamic_type_handler.dart';
import 'package:nonna_app/core/utils/rtl_support_handler.dart';

/// Example demonstrating Phase 3 Dynamic Type & RTL Support integration.
///
/// This example shows how to create an accessible, internationalized
/// screen that adapts to both system font scaling and RTL languages.
///
/// Features demonstrated:
/// - Dynamic text scaling with WCAG compliance
/// - RTL layout mirroring
/// - Adaptive layouts based on text scale
/// - Icon mirroring for navigation
/// - Bidirectional content handling
///
/// To test:
/// 1. iOS: Settings → Accessibility → Display & Text Size → Larger Text
/// 2. Android: Settings → Accessibility → Font Size
/// 3. Change app locale to Arabic or Hebrew for RTL testing
class AccessibilityExample extends StatelessWidget {
  const AccessibilityExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Accessibility Demo',
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: const TextStyle(fontSize: 20),
          ),
        ),
        leading: IconButton(
          icon: RTLSupportHandler.mirrorInRTL(
            context: context,
            child: const Icon(Icons.arrow_back),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: DynamicTypeHandler.getScaledPadding(
            context,
            basePadding: const EdgeInsets.all(16),
          ),
          child: Column(
            crossAxisAlignment: RTLSupportHandler.getCrossAxisAlignment(
              context,
              logicalAlignment: CrossAxisAlignment.start,
            ),
            children: [
              _buildSection(
                context,
                title: 'Text Scaling',
                description: 'Text scales with system settings (80%-200%)',
                child: _TextScalingDemo(),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: 'RTL Support',
                description: 'Layout mirrors for right-to-left languages',
                child: _RTLSupportDemo(),
              ),
              const SizedBox(height: 24),
              _buildCurrentSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: DynamicTypeHandler.getScaledPadding(
          context,
          basePadding: const EdgeInsets.all(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: DynamicTypeHandler.scaledTextStyle(
                context,
                baseStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: DynamicTypeHandler.scaledTextStyle(
                context,
                baseStyle: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSettings(BuildContext context) {
    final textScale = DynamicTypeHandler.getTextScaleFactor(context);
    final isRTL = RTLSupportHandler.isRTL(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Settings',
              style: DynamicTypeHandler.scaledTextStyle(
                context,
                baseStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Text Scale: ${(textScale * 100).toStringAsFixed(0)}%',
              style: DynamicTypeHandler.scaledTextStyle(
                context,
                baseStyle: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              'RTL Mode: ${isRTL ? "Yes" : "No"}',
              style: DynamicTypeHandler.scaledTextStyle(
                context,
                baseStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextScalingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Small Text (12px)',
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Medium Text (16px)',
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Large Text (20px)',
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class _RTLSupportDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: RTLSupportHandler.getTextDirection(context),
      children: [
        RTLSupportHandler.mirrorInRTL(
          context: context,
          child: const Icon(Icons.arrow_forward),
        ),
        const SizedBox(width: 8),
        Text(
          'Forward Arrow (mirrors in RTL)',
          style: DynamicTypeHandler.scaledTextStyle(
            context,
            baseStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
