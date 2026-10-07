import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB0D7FE),
            Color(0xFFE8D8FD),
            Color(0xFFD3E1FD),
            Color(0xFFF5DFF0),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              /// =========================
              /// SHIMMER CONTENT
              /// =========================
              Expanded(
                child: Shimmer.fromColors(
                  // Light shimmer color
                  baseColor: const Color(0xFFE8EDF3),
                  highlightColor: const Color(0xFFFFFFFF),
                  period: const Duration(milliseconds: 1400),
                  direction: ShimmerDirection.ltr,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Top line
                        Container(
                          width: 150,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// Second line
                        Container(
                          width: 220,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// =========================
                        /// LARGE PROFILE / INFO CARD
                        /// =========================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              /// Profile circle
                              Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(height: 24),

                              /// Main text
                              Container(
                                width: double.infinity,
                                height: 22,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// Small text
                              Container(
                                width: 140,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// =========================
                        /// MIDDLE TWO ITEM CARD
                        /// =========================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSmallItemRow(),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: _buildSmallItemRow(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// =========================
                        /// 3 COLUMN GRID
                        /// =========================
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  /// Circle
                                  Container(
                                    width: 65,
                                    height: 65,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  /// Text
                                  Container(
                                    width: 90,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              /// =========================
              /// BOTTOM NAVBAR
              /// NO SHIMMER HERE
              /// =========================
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// SMALL ITEM
  /// =========================
  Widget _buildSmallItemRow() {
    return Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: 35,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// =========================
  /// STATIC NAVBAR ITEM
  /// NO SHIMMER
  /// =========================
  Widget _buildNavItem(
      IconData icon,
      String title,
      bool selected,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 32,
          color: selected
              ? const Color(0xFF4338CA)
              : const Color(0xFF94A3B8),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
            selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? const Color(0xFF4338CA)
                : const Color(0xFF94A3B8),
          ),
        ),

        if (selected) ...[
          const SizedBox(height: 6),
          Container(
            width: 35,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF4338CA),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ],
    );
  }
}