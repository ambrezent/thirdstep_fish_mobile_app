import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class _Offer {
  final String title;
  final String subtitle;
  final String badge;
  final String emoji;
  final Color bg;
  final Color badgeColor;

  const _Offer({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.emoji,
    required this.bg,
    required this.badgeColor,
  });
}

const _offers = [
  _Offer(
    title: 'Fresh Hammour',
    subtitle: 'Premium daily catch — cleaned & ready',
    badge: '20% OFF',
    emoji: '🦞',
    bg: Color(0xFF0A1628),
    badgeColor: Color(0xFFC9A84C),
  ),
  _Offer(
    title: 'Tiger Shrimp Deal',
    subtitle: 'Buy 2 kg, get free ice pack',
    badge: 'BUY 2 GET 1',
    emoji: '🦐',
    bg: Color(0xFF152840),
    badgeColor: Color(0xFF25D366),
  ),
  _Offer(
    title: 'Weekend Special',
    subtitle: 'King Crab — limited stock every Friday',
    badge: 'LIMITED',
    emoji: '🦀',
    bg: Color(0xFF1E3A57),
    badgeColor: Color(0xFFF97316),
  ),
  _Offer(
    title: 'Free Delivery',
    subtitle: 'On all orders above AED 150 today',
    badge: 'TODAY ONLY',
    emoji: '🐟',
    bg: Color(0xFF0A1628),
    badgeColor: Color(0xFFC9A84C),
  ),
];

class OfferBannerSlider extends StatefulWidget {
  const OfferBannerSlider({super.key});

  @override
  State<OfferBannerSlider> createState() => _OfferBannerSliderState();
}

class _OfferBannerSliderState extends State<OfferBannerSlider> {
  final _controller = PageController(viewportFraction: 0.88);
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_current + 1) % _offers.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _controller,
            itemCount: _offers.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _BannerCard(offer: _offers[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_offers.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _current == i ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: _current == i ? AppColors.navy : AppColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
          )),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _Offer offer;
  const _BannerCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: offer.bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Subtle circle decoration
          Positioned(
            right: -20, bottom: -20,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            right: 20, top: -30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: offer.badgeColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          offer.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        offer.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(offer.emoji, style: const TextStyle(fontSize: 56)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
