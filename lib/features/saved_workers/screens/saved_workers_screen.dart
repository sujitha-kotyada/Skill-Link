import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../worker_directory/widgets/worker_card.dart';

class SavedWorkersScreen extends StatefulWidget {
  const SavedWorkersScreen({super.key});

  @override
  State<SavedWorkersScreen> createState() => _SavedWorkersScreenState();
}

class _SavedWorkersScreenState extends State<SavedWorkersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<CustomerProvider>().loadSavedWorkers(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final saved = customerProvider.savedWorkers;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Saved Workers', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: customerProvider.isLoadingSavedWorkers
              ? const LoadingIndicator(message: 'Loading saved professionals...')
              : saved.isEmpty
                  ? EmptyStateView(
                      icon: Icons.bookmark_border_rounded,
                      title: 'No Saved Workers Yet',
                      description: 'Bookmark skilled professionals while searching to easily access their profiles here.',
                      buttonLabel: 'Explore Workers Directory',
                      onButtonPressed: () => context.go(RouteNames.customerFindWorkers),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: crossAxisCount == 1 ? 1.5 : 1.35,
                          ),
                          itemCount: saved.length,
                          itemBuilder: (context, index) {
                            return WorkerCard(worker: saved[index]);
                          },
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

