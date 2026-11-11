import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:liquid_shockwave/liquid_shockwave.dart';

/// Demonstration screen showcasing Apple NameDrop / iOS Tap-to-Share liquid shockwave
/// distortion with a realistic contact card, directional triggers, and Light/Dark mode.
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final GlobalKey<LiquidShockwaveContainerState> _shockwaveKey =
      GlobalKey<LiquidShockwaveContainerState>();

  String _lastTriggerLabel = 'Tap a button below or touch anywhere on screen';
  bool _isAnimating = false;
  bool _isDarkMode = true;
  bool _liveSampling = false;
  Duration _currentDuration = const Duration(milliseconds: 1400);

  void _triggerSide(ShockwaveSide side, String label) {
    setState(() {
      _lastTriggerLabel = label;
    });
    _shockwaveKey.currentState?.triggerFromSide(side, _currentDuration);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.width < 600;

    // Theme tokens based on _isDarkMode
    final bgColor = _isDarkMode ? const Color(0xFF0A0C14) : const Color(0xFFF2F4F8);
    final bgGradientColors = _isDarkMode
        ? const [Color(0xFF1E2640), Color(0xFF0F1322), Color(0xFF07080D)]
        : const [Color(0xFFE5ECF6), Color(0xFFEFF3F9), Color(0xFFF7F9FC)];

    final cardBgColor = _isDarkMode
        ? const Color(0xFF141927).withValues(alpha: 0.70)
        : Colors.white;
    final cardBorderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.08);
    final cardShadow = _isDarkMode
        ? [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.12),
              blurRadius: 36,
              spreadRadius: 4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
        : [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ];

    final textColor = _isDarkMode ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFF3A3A3C);
    final captionColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.50)
        : const Color(0xFF8E8E93);

    final panelBgColor = _isDarkMode ? const Color(0xFF121624) : Colors.white;
    final panelBorderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.07);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Ambient background lighting
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.6),
                  radius: 1.2,
                  colors: bgGradientColors,
                ),
              ),
            ),
          ),

          // The LiquidShockwaveContainer wraps the entire interactive canvas
          Positioned.fill(
            child: LiquidShockwaveContainer(
              key: _shockwaveKey,
              triggerOnTap: true,
              defaultSide: ShockwaveSide.bottom,
              duration: _currentDuration,
              curve: Curves.easeOutCubic,
              liveSampling: _liveSampling,
              onAnimationStatusChanged: (status) {
                setState(() {
                  _isAnimating = status == AnimationStatus.forward;
                });
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 18.0 : 40.0,
                    vertical: 16.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top bar: NameDrop indicator + Theme Switcher
                          _buildTopBar(textColor),
                          const SizedBox(height: 16),

                          // Realistic iOS NameDrop Contact Card
                          _buildNameDropCard(
                            cardBgColor: cardBgColor,
                            cardBorderColor: cardBorderColor,
                            cardShadow: cardShadow,
                            textColor: textColor,
                            subtextColor: subtextColor,
                            captionColor: captionColor,
                          ),
                          const SizedBox(height: 18),

                          // Status Pill
                          _buildStatusPill(panelBgColor, panelBorderColor, textColor),
                          const SizedBox(height: 18),

                          // Directional Trigger Control Panel
                          _buildControlPanel(
                            panelBgColor: panelBgColor,
                            panelBorderColor: panelBorderColor,
                            textColor: textColor,
                            captionColor: captionColor,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top Bar with simulated NameDrop status & Theme Toggle
  Widget _buildTopBar(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // NameDrop Status Pill
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDarkMode
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isAnimating
                        ? const Color(0xFF007AFF)
                        : const Color(0xFF34C759),
                    boxShadow: [
                      BoxShadow(
                        color: (_isAnimating
                                ? const Color(0xFF007AFF)
                                : const Color(0xFF34C759))
                            .withValues(alpha: 0.7),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _isAnimating
                        ? '🌊 Shockwave Active'
                        : 'iOS 17 NameDrop',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Light / Dark Mode Toggle Switch
        GestureDetector(
          onTap: () {
            setState(() {
              _isDarkMode = !_isDarkMode;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? const Color(0xFF1E2640)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDarkMode
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.1),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDarkMode ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                  size: 15,
                  color: _isDarkMode ? const Color(0xFFFFD60A) : const Color(0xFF5856D6),
                ),
                const SizedBox(width: 6),
                Text(
                  _isDarkMode ? 'Light Mode' : 'Dark Mode',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Realistic Apple iOS NameDrop contact card with avatar, badges, QR, and actions
  Widget _buildNameDropCard({
    required Color cardBgColor,
    required Color cardBorderColor,
    required List<BoxShadow> cardShadow,
    required Color textColor,
    required Color subtextColor,
    required Color captionColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: cardBgColor,
        border: Border.all(
          color: cardBorderColor,
          width: 1.2,
        ),
        boxShadow: cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with glowing gradient rim
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFF007AFF),
                          Color(0xFF5856D6),
                          Color(0xFFAF52DE),
                          Color(0xFFFF2D55),
                          Color(0xFF007AFF),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isDarkMode ? const Color(0xFF0D111D) : Colors.white,
                    ),
                    child: Center(
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isDarkMode
                                ? const [Color(0xFF2C3E6B), Color(0xFF18223B)]
                                : const [Color(0xFFD3E0FA), Color(0xFFB5CDF8)],
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/fish-spinning.gif',
                            width: 82,
                            height: 82,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              CupertinoIcons.person_crop_circle_fill,
                              size: 72,
                              color: _isDarkMode
                                  ? const Color(0xFFE5ECFF)
                                  : const Color(0xFF2A5096),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF007AFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Contact Name & Title
              Text(
                'Alex Rivera',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Graphics Engineer & Tech Artist',
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Apple Ecosystem Labs • Cupertino, CA',
                style: TextStyle(
                  color: captionColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // Badges / Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _buildTagBadge('Impeller', const Color(0xFF007AFF)),
                  _buildTagBadge('FragmentShader', const Color(0xFFAF52DE)),
                  _buildTagBadge('Refraction', const Color(0xFF34C759)),
                  _buildTagBadge('NameDrop', const Color(0xFFFF9500)),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContactActionButton(
                    icon: CupertinoIcons.phone_fill,
                    label: 'Call',
                    color: const Color(0xFF30D158),
                  ),
                  _buildContactActionButton(
                    icon: CupertinoIcons.chat_bubble_fill,
                    label: 'Message',
                    color: const Color(0xFF0A84FF),
                  ),
                  _buildContactActionButton(
                    icon: CupertinoIcons.mail_solid,
                    label: 'Email',
                    color: const Color(0xFF5E5CE6),
                  ),
                  _buildContactActionButton(
                    icon: CupertinoIcons.share,
                    label: 'AirDrop',
                    color: const Color(0xFFFF375F),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live GIF Test Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF2F4F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 58,
                        height: 58,
                        color: _isDarkMode
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.white,
                        child: Image.asset(
                          'assets/fish-spinning.gif',
                          width: 58,
                          height: 58,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.animation,
                            size: 32,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Live Spinning Fish GIF',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Color(0xFF34C759),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Actively spinning. Notice how the wave ripples over it and the GIF continues smoothly!',
                            style: TextStyle(
                              color: captionColor,
                              fontSize: 10.5,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Mock Stylized QR Code Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF2F4F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    _buildMockQrCode(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital Business Card',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Scan with Camera or hold near top of iPhone to receive full contact vCard.',
                            style: TextStyle(
                              color: captionColor,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
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

  /// High-contrast mock QR code widget
  Widget _buildMockQrCode() {
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _MockQrPatternPainter(),
      ),
    );
  }

  Widget _buildTagBadge(String label, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: _isDarkMode ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tint.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tint,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContactActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: _isDarkMode ? 0.18 : 0.12),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: _isDarkMode ? Colors.white70 : const Color(0xFF3A3A3C),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Status info pill
  Widget _buildStatusPill(Color bgColor, Color borderColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: textColor.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _lastTriggerLabel,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Trigger control panel containing speed slider, bottom wave button, top NameDrop button, and directional triggers
  Widget _buildControlPanel({
    required Color panelBgColor,
    required Color panelBorderColor,
    required Color textColor,
    required Color captionColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panelBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: panelBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Shockwave Trigger Controls',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trigger from any screen edge or tap directly on the card',
            style: TextStyle(
              color: captionColor,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 14),

          // Speed & Duration Customization Section
          _buildSpeedControlSection(textColor),
          const SizedBox(height: 14),

          // Sampling Mode Section (Snapshot vs Live Stream)
          _buildSamplingModeSection(textColor, captionColor),
          const SizedBox(height: 14),

          // Primary bottom wave trigger button (requested by user)
          _buildSpecialTriggerButton(
            title: '🌊 Trigger From Bottom (螢幕底部波紋)',
            subtitle: 'Wave propagates upwards from the screen bottom edge',
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
            ),
            icon: Icons.arrow_upward_rounded,
            onPressed: () => _triggerSide(
              ShockwaveSide.bottom,
              'Triggered: Bottom Edge (螢幕底部) -> Ripple sweeps upwards',
            ),
          ),
          const SizedBox(height: 10),

          // Top edge contact button (simulating Apple NameDrop)
          _buildSpecialTriggerButton(
            title: '📱 Top-Edge NameDrop (螢幕頂部波紋)',
            subtitle: 'Simulates iOS 17 device contact from top edge',
            gradient: const LinearGradient(
              colors: [Color(0xFF5856D6), Color(0xFFAF52DE)],
            ),
            icon: Icons.arrow_downward_rounded,
            onPressed: () => _triggerSide(
              ShockwaveSide.top,
              'Triggered: Top Edge (iOS NameDrop contact) -> Ripple sweeps downwards',
            ),
          ),
          const SizedBox(height: 12),

          // Left, Right, Center quick buttons
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  label: '◀ Left Edge',
                  onPressed: () => _triggerSide(
                    ShockwaveSide.left,
                    'Triggered: Left Edge -> Ripple sweeps right',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryButton(
                  label: '⦿ Center',
                  onPressed: () => _triggerSide(
                    ShockwaveSide.center,
                    'Triggered: Center Origin -> Radial shockwave',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSecondaryButton(
                  label: 'Right Edge ▶',
                  onPressed: () => _triggerSide(
                    ShockwaveSide.right,
                    'Triggered: Right Edge -> Ripple sweeps left',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tap hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: Color(0xFF007AFF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Touch anywhere on the card or screen to trigger at exact coordinate',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : const Color(0xFF3A3A3C),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive duration and speed control section
  Widget _buildSpeedControlSection(Color textColor) {
    final currentMs = _currentDuration.inMilliseconds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 16,
                      color: Color(0xFF007AFF),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Speed (波紋速度)',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: _isDarkMode ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${(currentMs / 1000).toStringAsFixed(1)}s ($currentMs ms)',
                  style: const TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick preset buttons
          Row(
            children: [
              _buildSpeedPresetPill('⚡ 0.6s (Fast)', 600),
              const SizedBox(width: 6),
              _buildSpeedPresetPill('🌊 1.4s (Relaxed)', 1400),
              const SizedBox(width: 6),
              _buildSpeedPresetPill('🐢 2.5s (Slow-Mo)', 2500),
            ],
          ),
          const SizedBox(height: 6),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              activeTrackColor: const Color(0xFF007AFF),
              inactiveTrackColor: _isDarkMode
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.10),
              thumbColor: const Color(0xFF007AFF),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              overlayColor: const Color(0xFF007AFF).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: currentMs.toDouble().clamp(400.0, 3000.0),
              min: 400.0,
              max: 3000.0,
              divisions: 26,
              onChanged: (val) {
                setState(() {
                  _currentDuration = Duration(milliseconds: val.round());
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedPresetPill(String label, int ms) {
    final isSelected = _currentDuration.inMilliseconds == ms;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentDuration = Duration(milliseconds: ms);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF007AFF).withValues(alpha: _isDarkMode ? 0.25 : 0.15)
                : (_isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF007AFF)
                  : (_isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08)),
              width: 0.9,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF007AFF)
                  : (_isDarkMode ? Colors.white60 : const Color(0xFF636366)),
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSamplingModeSection(Color textColor, Color captionColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _liveSampling ? Icons.stream_rounded : Icons.camera_alt_outlined,
                      size: 16,
                      color: _liveSampling ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Sampling Mode (取樣模式)',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (_liveSampling ? const Color(0xFF34C759) : const Color(0xFF007AFF))
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _liveSampling ? '⚡ LIVE STREAM' : '📸 SNAPSHOT',
                  style: TextStyle(
                    color: _liveSampling ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _liveSampling = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_liveSampling
                          ? const Color(0xFF007AFF).withValues(alpha: 0.25)
                          : (_isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !_liveSampling
                            ? const Color(0xFF007AFF)
                            : (_isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
                        width: 0.9,
                      ),
                    ),
                    child: Text(
                      '📸 Snapshot',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_liveSampling ? const Color(0xFF007AFF) : (_isDarkMode ? Colors.white60 : const Color(0xFF636366)),
                        fontSize: 11,
                        fontWeight: !_liveSampling ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _liveSampling = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _liveSampling
                          ? const Color(0xFF34C759).withValues(alpha: 0.25)
                          : (_isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _liveSampling
                            ? const Color(0xFF34C759)
                            : (_isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
                        width: 0.9,
                      ),
                    ),
                    child: Text(
                      '⚡ Live Stream (GIF 轉動)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _liveSampling ? const Color(0xFF34C759) : (_isDarkMode ? Colors.white60 : const Color(0xFF636366)),
                        fontSize: 11,
                        fontWeight: _liveSampling ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _liveSampling
                ? '⚡ 即時取樣啟用：每幀動態捕捉最新畫面，小魚將「邊旋轉邊被水波折射」！'
                : '📸 快照模式：於觸發當下擷取 1 幀定格紋理，以極致效能 120 FPS 渲染。',
            style: TextStyle(
              color: captionColor,
              fontSize: 10,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialTriggerButton({
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDarkMode
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _isDarkMode ? Colors.white : const Color(0xFF1C1C1E),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for a crisp mock QR code pattern with corner finder squares
class _MockQrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111422)
      ..style = PaintingStyle.fill;

    const int gridSize = 17;
    final cellW = size.width / gridSize;
    final cellH = size.height / gridSize;

    void drawFinder(int startX, int startY) {
      canvas.drawRect(
        Rect.fromLTWH(startX * cellW, startY * cellH, 7 * cellW, 7 * cellH),
        paint,
      );
      final whitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(
          (startX + 1) * cellW,
          (startY + 1) * cellH,
          5 * cellW,
          5 * cellH,
        ),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          (startX + 2) * cellW,
          (startY + 2) * cellH,
          3 * cellW,
          3 * cellH,
        ),
        paint,
      );
    }

    drawFinder(0, 0);
    drawFinder(gridSize - 7, 0);
    drawFinder(0, gridSize - 7);

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final inTopLeft = x < 7 && y < 7;
        final inTopRight = x >= gridSize - 7 && y < 7;
        final inBottomLeft = x < 7 && y >= gridSize - 7;
        if (inTopLeft || inTopRight || inBottomLeft) continue;

        if (x == 6 || y == 6) {
          if ((x + y) % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(x * cellW, y * cellH, cellW * 0.9, cellH * 0.9),
              paint,
            );
          }
          continue;
        }

        final hash = (x * 37 + y * 19 + (x ^ y)) % 10;
        if (hash > 4) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * cellW, y * cellH, cellW * 0.9, cellH * 0.9),
              const Radius.circular(1.0),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
