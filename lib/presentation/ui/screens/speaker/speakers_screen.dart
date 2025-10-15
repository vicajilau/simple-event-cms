import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

/// Screen that displays a grid of speakers with their information and social links
/// Fetches speaker data from the configured data source and displays it in cards
class SpeakersScreen extends StatefulWidget {
  /// Data loader for fetching speaker information
  final SpeakerViewModel viewmodel = getIt<SpeakerViewModel>();
  final String eventId;
  SpeakersScreen({super.key,required this.eventId});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.viewmodel.viewState,
      builder: (context, value, child) {
        if (value == ViewState.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (value == ViewState.error) {
          ErrorView(errorType: widget.viewmodel.errorType);
        }

        return ValueListenableBuilder<List<Speaker>>(
          valueListenable: widget.viewmodel.speakers,
          builder: (context, speakers, child) {
            if (speakers.isEmpty) {
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
                    Text(AppLocalizations.of(context)!.noSpeakersRegistered),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: kIsWeb ? 400 : 350,
                    crossAxisCount: (constraints.maxWidth / 250).floor(),
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: speakers.length,
                  itemBuilder: (context, index) {
                    final speaker = speakers[index];
                    return Stack(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                    ),
                                    child: speaker.image != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              speaker.image!,
                                              fit: BoxFit.fill,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                  ),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: 32,
                                                          height: 32,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 3,
                                                            value:
                                                                loadingProgress
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                : null,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.loading,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                color: Theme.of(context)
                                                                    .colorScheme
                                                                    .onSurfaceVariant,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                debugPrint(
                                                  'Error loading image for ${speaker.name}: $error',
                                                );
                                                return Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        size: 48,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.errorLoadingImage,
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.bodySmall,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 48,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  speaker.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  speaker.bio,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                SocialIconsRow(social: speaker.social),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 30,
                          child: FutureBuilder<bool>(
                            future: widget.viewmodel.checkToken(),
                            builder: (context, snapshot) {
                              return snapshot.data == true
                                  ? Row(
                                      children: [
                                        IconWidget(
                                          icon: Icons.edit,
                                          onTap: () async {
                                            Map<String, dynamic> arguments  = {
                                              'speaker': speaker,
                                              'eventId': widget.eventId,
                                            };
                                            final Speaker? updatedSpeaker =
                                                await AppRouter.router.push(
                                                  AppRouter.speakerFormPath,
                                                  extra: arguments
                                                );

                                            if (updatedSpeaker != null) {
                                              widget.viewmodel.editSpeaker(
                                                updatedSpeaker,
                                                widget.eventId
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconWidget(
                                          icon: Icons.delete,
                                          onTap: () {
                                            widget.viewmodel.removeSpeaker(
                                              speaker.uid,
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
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /**/
}

class IconWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const IconWidget({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
