import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
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
  final Map<String, List<dynamic>> groupedSponsors = {};

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
          return Center(child: CircularProgressIndicator());
        } else if (value == ViewState.error) {
          return Center(
            child: ErrorView(errorMessage: widget.viewmodel.errorMessage),
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
                    Text(location.noSponsorsRegistered),
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

            return LayoutBuilder(
              builder: (context, constraints) {
                final raw = (constraints.maxWidth / 250).floor();
                final crossAxisCount = raw.clamp(1, 4).toInt();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: LayoutBuilder(
                        builder: (context, header) {
                          final isNarrow = header.maxWidth < 520;

                          final actions = Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final Sponsor? newSponsor = await AppRouter
                                      .router
                                      .push(
                                        AppRouter.sponsorFormPath,
                                        extra: {'eventId': widget.eventId},
                                      );
                                  if (newSponsor != null) {
                                    widget.viewmodel.addSponsor(
                                      newSponsor,
                                      widget.eventId,
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: Text(location.addSponsor),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF38B6FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                FutureBuilder<bool>(
                                  future: widget.viewmodel.checkToken(),
                                  builder: (context, snapshot) =>
                                      snapshot.data == true
                                      ? actions
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              FutureBuilder<bool>(
                                future: widget.viewmodel.checkToken(),
                                builder: (context, snapshot) =>
                                    snapshot.data == true
                                    ? actions
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    ...groupedSponsors.entries.map((entry) {
                      final type = entry.key;
                      final sponsorList = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: Text(
                              _getCategoryDisplayName(context, type),
                              style: TextStyle(
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
                                    onTap: sponsor.website != null
                                        ? () => context.openUrl(sponsor.website)
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // ⬇️ Sustituye el Container anterior por un Stack
                                          Expanded(
                                            child: Stack(
                                              clipBehavior: Clip.hardEdge,
                                              children: [
                                                // Fondo: el marco del logo
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
                                                  child: sponsor.logo != null
                                                      ? NetworkImageWidget(
                                                          imageUrl:
                                                              sponsor.logo,
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

                                                // ⬇️ Overlay: acciones, ahora relativas al logo
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
                                                              icon: Icons
                                                                  .delete_outlined,
                                                              onTap: () async {
                                                                await widget
                                                                    .viewmodel
                                                                    .removeSponsor(
                                                                      sponsor
                                                                          .uid,
                                                                    );
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

                                          // ⬆️ Fin de la parte cambiada
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

  String _getCategoryDisplayName(BuildContext context, String type) {
    final location = AppLocalizations.of(context)!;

    if (type == location.mainSponsor) return location.mainSponsor;
    if (type == location.goldSponsor) return location.goldSponsor;
    if (type == location.silverSponsor) return location.silverSponsor;
    if (type == location.bronzeSponsor) return location.bronzeSponsor;

    // For backwards compatibility, we check against the old hardcoded values
    switch (type) {
      case 'main':
        return location.mainSponsor;
      case 'gold':
        return location.goldSponsor;
      case 'silver':
        return location.silverSponsor;
      case 'bronze':
        return location.bronzeSponsor;
      default:
        return type;
    }
  }
}
