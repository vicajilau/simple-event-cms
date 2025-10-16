import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

/// Screen that displays event_collection sponsors in a responsive grid layout
/// Fetches sponsor data and displays logos with clickable links
class SponsorsScreen extends StatefulWidget {
  /// Data loader for fetching sponsor information
  final SponsorViewModel viewmodel = getIt<SponsorViewModel>();
  final String eventId;

  SponsorsScreen({super.key, required this.eventId});

  @override
  State<SponsorsScreen> createState() => _SponsorsScreenState();
}

class _SponsorsScreenState extends State<SponsorsScreen> {
  final Map<String, List<dynamic>> groupedSponsors = {};

  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup(widget.eventId);
  }

  void _editSponsor(Sponsor sponsor) async {
    final Sponsor? newSponsor = await AppRouter.router.push(
      AppRouter.sponsorFormPath,
      extra: {
        'sponsor': sponsor,
        'eventId': widget.eventId,
      },
    );

    if (newSponsor != null) {
      widget.viewmodel.addSponsor(newSponsor, widget.eventId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.viewmodel.viewState,
      builder: (context, value, child) {
        if (value == ViewState.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (value == ViewState.error) {
          return Center(
            child: ErrorView(errorType: widget.viewmodel.errorType),
          );
        }

        return ValueListenableBuilder(
          valueListenable: widget.viewmodel.sponsors,
          builder: (context, sponsors, child) {
            if (sponsors.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: sponsorList.length,
                      itemBuilder: (context, index) {
                        final sponsor = sponsorList[index];
                        return Card(
                          child: Stack(
                            children: [
                              InkWell(
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  errorWidget: Center(
                                                    child: Icon(
                                                      Icons.business,
                                                      size: 32,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                )
                                              : Center(
                                                  child: Icon(
                                                    Icons.business,
                                                    size: 32,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        sponsor.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: FutureBuilder<bool>(
                                  future: widget.viewmodel.checkToken(),
                                  builder: (context, snapshot) {
                                    return snapshot.data == true
                                        ? Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                ),
                                                onPressed: () async {
                                                  _editSponsor(sponsor);
                                                },
                                              ),

                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  widget.viewmodel
                                                      .removeSponsor(
                                                        sponsor.uid,
                                                      );
                                                },
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ],
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
      },
    );
  }
}
