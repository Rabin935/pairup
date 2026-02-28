import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/widgets/homepage_widgets/Action_button.dart';
import 'package:pairup/core/widgets/homepage_widgets/discoverCard.dart';
import 'package:pairup/core/widgets/homepage_widgets/discover_app_bar.dart';
import 'package:pairup/features/sensor/presentation/view_model/motion_sensor_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<DiscoverCardState> _discoverKey =
      GlobalKey<DiscoverCardState>();
  int _lastHandledShakeCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(motionSensorViewModelProvider.notifier).startListening();
    });
  }

  @override
  void dispose() {
    ref.read(motionSensorViewModelProvider.notifier).stopListening();
    super.dispose();
  }

  Future<void> _refreshDeck() async {
    await _discoverKey.currentState?.refreshDeck();
  }

  @override
  Widget build(BuildContext context) {
    final sensorState = ref.watch(motionSensorViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(motionSensorViewModelProvider, (previous, next) async {
      final previousCount = previous?.shakeCount ?? 0;
      if (next.shakeCount <= previousCount) return;
      if (next.shakeCount == _lastHandledShakeCount) return;

      final messenger = ScaffoldMessenger.of(context);
      _lastHandledShakeCount = next.shakeCount;
      await _refreshDeck();

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 900),
          content: Text('Shake detected. Matches refreshed.'),
        ),
      );
    });

    final tiltX = (-sensorState.gyroscope.y * 6).clamp(-10.0, 10.0);
    final tiltY = (sensorState.gyroscope.x * 6).clamp(-10.0, 10.0);
    final tiltRotation = (sensorState.gyroscope.z * 0.025).clamp(-0.10, 0.10);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF14171D), Color(0xFF1C2028)]
                  : const [Color(0xFFEFF9FC), Color(0xFFF9F8FF)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                DiscoverAppBar(onRefresh: _refreshDeck),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(tiltX, tiltY),
                    child: Transform.rotate(
                      angle: tiltRotation,
                      child: DiscoverCard(key: _discoverKey),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -8),
                  child: ActionButton(
                    onPass: () {
                      _discoverKey.currentState?.triggerPass();
                    },
                    onLike: () {
                      _discoverKey.currentState?.triggerLike();
                    },
                    onDetails: () {
                      _discoverKey.currentState?.triggerDetails();
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
