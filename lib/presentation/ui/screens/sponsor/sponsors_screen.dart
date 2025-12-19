import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/no_data/no_data_screen.dart';
import 'package:sec/presentation/ui/screens/speaker/speakers_screen.dart';
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
  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup(widget.eventId);
  }

  void _editSponsor(Sponsor sponsor) async {
    final Sponsor? newSponsor = await AppRouter.router.push(
      AppRouter.sponsorFormPath,
      extra: {'sponsor': sponsor, 'eventId': widget.eventId},
    );

    if (newSponsor != null) {
      widget.viewmodel.addSponsor(newSponsor, widget.eventId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
      valueListenable: widget.viewmodel.viewState,
      builder: (context, value, child) {
        if (value == ViewState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (value == ViewState.error) {
          return Center(
            child: ErrorView(errorMessage: widget.viewmodel.errorMessage),
          );
        }

        return ValueListenableBuilder<List<Sponsor>>(
          valueListenable: widget.viewmodel.sponsors,
          builder: (context, sponsors, child) {
            if (sponsors.isEmpty) {
              return NoDataScreen(
                message: location.noSponsorsRegistered,
                icon: Icons.people_outline,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final raw = (constraints.maxWidth / 250).floor();
                final crossAxisCount = raw.clamp(1, 4).toInt();

                final handler = _SponsorsDataHandler(
                  sponsors: sponsors,
                  localizations: location,
                );

                final groups = handler.groupSponsors();
                final orderedKeys = handler.getOrderedKeys(groups.keys.toList());


                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 16),

                    //Each category becomes its own section
                    //Using ValueKey prevents Flutter from “losing” state when the list changes
                    ...orderedKeys.map((type) {
                      final sponsorList = groups[type]!;
                      return Column(
                        key: ValueKey('section_$type'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: Text(
                              handler.getCategoryDisplayName(type),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 1.2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: sponsorList.length,
                            itemBuilder: (context, index) {
                              final sponsor = sponsorList[index];
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: const BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: sponsor.website.isNotEmpty
                                        ? () => context.openUrl(sponsor.website)
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              clipBehavior: Clip.hardEdge,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outline
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                    ),
                                                  ),
                                                  child: NetworkImageWidget(
                                                    imageUrl: sponsor.logo,
                                                    fit: BoxFit.contain,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    errorWidget: Center(
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

                                                Positioned(
                                                  bottom: 8,
                                                  left: 8,
                                                  child: FutureBuilder<bool>(
                                                    future: widget.viewmodel
                                                        .checkToken(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.data ==
                                                          true) {
                                                        return Row(
                                                          children: [
                                                            IconWidget(
                                                              key: Key("icon_button_sponsor_edit"),
                                                              icon: Icons
                                                                  .edit_outlined,
                                                              onTap: () =>
                                                                  _editSponsor(
                                                                    sponsor,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            IconWidget(
                                                              key: Key("icon_button_sponsor_delete"),
                                                              icon: Icons
                                                                  .delete_outlined,
                                                              onTap: () async {
                                                                final bool?
                                                                shouldDelete = await showDialog<bool>(
                                                                  context:
                                                                      context,
                                                                  builder: (context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                        location
                                                                            .deleteSponsorTitle,
                                                                      ),
                                                                      content: Text(
                                                                        location.confirmDeleteSponsor(
                                                                          sponsor
                                                                              .name,
                                                                        ),
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () =>
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop(
                                                                                false,
                                                                              ),
                                                                          child: Text(
                                                                            location.cancel,
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          key: Key("button_delete"),
                                                                          onPressed: () =>
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop(
                                                                                true,
                                                                              ),
                                                                          child: Text(
                                                                            location.accept,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                                if (shouldDelete ==
                                                                    true) {
                                                                  await widget
                                                                      .viewmodel
                                                                      .removeSponsor(
                                                                        sponsor
                                                                            .uid,
                                                                      );
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      return const SizedBox.shrink();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            sponsor.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
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
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Handles the business logic for grouping and sorting sponsors.
/// This class is separated to improve testability.
class _SponsorsDataHandler {
  final List<Sponsor> sponsors;
  final AppLocalizations localizations;

  _SponsorsDataHandler({required this.sponsors, required this.localizations});

  static const _knownOrder = <String>['main', 'gold', 'silver', 'bronze'];

  /// Groups sponsors by their normalized type.
  Map<String, List<Sponsor>> groupSponsors() {
    final groups = <String, List<Sponsor>>{};
    for (final sponsor in sponsors) {
      final key = _normalizeType(sponsor.type);
      (groups[key] ??= <Sponsor>[]).add(sponsor);
    }
    return groups;
  }

  /// Returns a sorted list of category keys.
  /// Known categories are placed first, followed by other categories sorted alphabetically.
  List<String> getOrderedKeys(List<String> keys) {
    return <String>[
      ..._knownOrder.where(keys.contains),
      ...keys.where((k) => !_knownOrder.contains(k)).toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
    ];
  }

  String _normalizeType(String type) {
    final normalizedType = type.toLowerCase();
    if (normalizedType == 'main' || normalizedType == localizations.mainSponsor.toLowerCase()) return 'main';
    if (normalizedType == 'gold' || normalizedType == localizations.goldSponsor.toLowerCase()) return 'gold';
    if (normalizedType == 'silver' || normalizedType == localizations.silverSponsor.toLowerCase()) return 'silver';
    if (normalizedType == 'bronze' || normalizedType == localizations.bronzeSponsor.toLowerCase()) return 'bronze';
    return type;
  }

  String getCategoryDisplayName(String type) {
    switch (type) {
      case 'main':
        return localizations.mainSponsor;
      case 'gold':
        return localizations.goldSponsor;
      case 'silver':
        return localizations.silverSponsor;
      case 'bronze':
        return localizations.bronzeSponsor;
      default:
    return type;
    }
  }
}
