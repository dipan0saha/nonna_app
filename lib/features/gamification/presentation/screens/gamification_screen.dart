import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/widgets/empty_state.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/features/home/presentation/providers/home_screen_provider.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart';
import 'package:nonna_app/features/gamification/presentation/providers/gamification_provider.dart';

/// Screen displaying gamification features: name suggestions and prediction votes.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({
    super.key,
    this.babyProfileId,
    this.userRole,
  });

  /// Optional baby profile ID. When null, falls back to [selectedBabyProfileProvider].
  final String? babyProfileId;

  /// Current user's role
  final UserRole? userRole;

  @override
  ConsumerState<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends ConsumerState<GamificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData({bool forceRefresh = false}) {
    final id =
        widget.babyProfileId ?? ref.read(selectedBabyProfileProvider) ?? '';
    final role = widget.userRole ??
        ref.read(homeScreenProvider).selectedRole ??
        UserRole.follower;

    if (id.isNotEmpty) {
      ref.read(gamificationProvider.notifier).load(
            babyProfileId: id,
            role: role,
            forceRefresh: forceRefresh,
          );
    }
  }

  Future<void> _onRefresh() async {
    _loadData(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the globally selected baby profile
    ref.listen<String?>(selectedBabyProfileProvider, (previous, next) {
      if (next != previous && next != null) {
        _loadData();
      }
    });

    final currentBabyProfileId =
        widget.babyProfileId ?? ref.watch(selectedBabyProfileProvider);

    if (currentBabyProfileId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fun & Games')),
        body: const Center(
          child: EmptyState(
            message: 'Select a baby profile to view games',
            icon: Icons.child_care,
          ),
        ),
      );
    }

    final state = ref.watch(gamificationProvider);

    return Scaffold(
      key: const Key('gamification_screen'),
      appBar: AppBar(
        title: const Text('Fun & Games'),
      ),
      body: TileListView(
        tiles: state.tiles,
        isLoading: state.isLoading,
        error: state.error,
        onRefresh: _onRefresh,
        onRetry: () => _loadData(forceRefresh: true),
        emptyWidget: const EmptyState(
          icon: Icons.sports_esports_outlined,
          title: 'Nothing here yet.',
          message: 'Add name suggestions or cast your predictions!',
        ),
      ),
    );
  }
}
