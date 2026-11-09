import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../widgets/categories_section.dart';
import '../widgets/community_impact_section.dart';
import '../widgets/explore_workers_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/landing_footer.dart';
import '../widgets/landing_header.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/why_choose_section.dart';
import '../widgets/worker_opportunities_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _whyChooseKey = GlobalKey();
  final GlobalKey _categoriesKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      endDrawer: _buildMobileDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            LandingHeader(
              onHowItWorksTap: () => _scrollToKey(_howItWorksKey),
              onAboutTap: () => _scrollToKey(_whyChooseKey),
              onFindWorkersTap: () => context.go(RouteNames.customerFindWorkers),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    const HeroSection(),
                    Container(key: _categoriesKey, child: const CategoriesSection()),
                    Container(key: _howItWorksKey, child: const HowItWorksSection()),
                    Container(key: _whyChooseKey, child: const WhyChooseSection()),
                    const ExploreWorkersSection(),
                    const WorkerOpportunitiesSection(),
                    const CommunityImpactSection(),
                    const TestimonialsSection(),
                    const FinalCtaSection(),
                    const LandingFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.warmCream,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.handshake_rounded, color: AppColors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepForestTeal,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: AppColors.primaryTeal),
              title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _scrollToTop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded, color: AppColors.primaryTeal),
              title: const Text('Find Workers', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                context.go(RouteNames.customerFindWorkers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: AppColors.primaryTeal),
              title: const Text('How It Works', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _scrollToKey(_howItWorksKey);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal),
              title: const Text('About Skill-Link', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _scrollToKey(_whyChooseKey);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(RouteNames.login);
                },
                child: const Text('Sign In'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(RouteNames.register);
                },
                child: const Text('Get Started'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
