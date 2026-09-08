import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/services/deep_link_service.dart';

/// Initializes [DeepLinkService] once the router is available.
class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  @override
  void initState() {
    super.initState();
    DeepLinkService.initialize(widget.router);
  }

  @override
  void dispose() {
    DeepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
