import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/widgets.dart';

/// Screen that displays event sponsors in a responsive grid layout
/// Fetches sponsor data and displays logos with clickable links
class SponsorsScreen extends StatelessWidget {
  /// Data loader for fetching sponsor information
  final List<Sponsor> sponsors;

  const SponsorsScreen({super.key, required this.sponsors});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.value(sponsors),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.loadingSponsors),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.errorLoadingSponsors),
              ],
            ),
          );
        }

        if (sponsors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.business_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.noSponsorsRegistered),
              ],
            ),
          );
        }

        // Group sponsors by type
        final Map<String, List<dynamic>> groupedSponsors = {};
        for (final sponsor in sponsors) {
          final type = sponsor.type;
          groupedSponsors.putIfAbsent(type, () => []).add(sponsor);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: groupedSponsors.entries.map((entry) {
            final type = entry.key;
            final sponsorList = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    type,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sponsorList.length,
                  itemBuilder: (context, index) {
                    final sponsor = sponsorList[index];
                    return Card(
                      child: InkWell(
                        onTap: sponsor.website != null
                            ? () => context.openUrl(sponsor.website)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: sponsor.logo != null
                                      ? NetworkImageWidget(
                                          imageUrl: sponsor.logo,
                                          fit: BoxFit.contain,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          errorWidget: Center(
                                            child: Icon(
                                              Icons.business,
                                              size: 32,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.business,
                                            size: 32,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sponsor.name,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
