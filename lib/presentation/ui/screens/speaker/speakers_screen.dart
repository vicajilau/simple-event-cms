import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/app_router.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/no_data/no_data_screen.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../widgets/custom_error_dialog.dart';

/// Screen that displays a grid of speakers with their information and social links
/// Fetches speaker data from the configured data source and displays it in cards
class SpeakersScreen extends StatefulWidget {
  /// Data loader for fetching speaker information
  final SpeakerViewModel viewmodel = getIt<SpeakerViewModel>();
  final String eventId;
  SpeakersScreen({super.key, required this.eventId});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup(widget.eventId);
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
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => CustomErrorDialog(
                errorMessage: widget.viewmodel.errorMessage,
                onCancel: () => {
                  widget.viewmodel.viewState.value = ViewState.loadFinished,
                  Navigator.of(context).pop()
                },
                buttonText: location.closeButton,
              ),
            );
          });
        }

        return ValueListenableBuilder<List<Speaker>>(
          valueListenable: widget.viewmodel.speakers,
          builder: (context, speakers, child) {
            if (speakers.isEmpty) {
              return NoDataScreen(
                message: location.noSpeakersRegistered,
                icon: Icons.people_outline,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final raw = (constraints.maxWidth / 250).floor();
                final crossAxisCount = raw.clamp(1, 3).toInt();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: kIsWeb ? 400 : 350,
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: speakers.length,
                          itemBuilder: (context, index) {
                            final speaker = speakers[index];
                            // Dentro de itemBuilder(...)
                            return Card(
                              // Inside itemBuilder(...)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // ⬇️ This part changes
                                    Expanded(
                                      child: Stack(
                                        clipBehavior: Clip.hardEdge,
                                        children: [
                                          // Background: the photo
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              child: speaker.image != null
                                                  ? Image.network(
                                                      speaker.image!,
                                                      fit: BoxFit
                                                          .cover, // usually better than fill
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 32,
                                                                    height: 32,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          3,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Text(
                                                                    location
                                                                        .loading,
                                                                    style: Theme.of(context)
                                                                        .textTheme
                                                                        .bodySmall
                                                                        ?.copyWith(
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).colorScheme.onSurfaceVariant,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                      errorBuilder: (context, error, stack) {
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
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                location
                                                                    .errorLoadingImage,
                                                                style: Theme.of(
                                                                  context,
                                                                ).textTheme.bodySmall,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 48,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          // ⬇️ Overlay: your actions, now relative to the image
                                          Positioned(
                                            // choose the corner/position you want
                                            bottom: 8,
                                            left: 8,
                                            child: FutureBuilder<bool>(
                                              future: widget.viewmodel
                                                  .checkToken(),
                                              builder: (context, snapshot) {
                                                if (snapshot.data == true) {
                                                  return Row(
                                                    children: [
                                                      IconWidget(
                                                        icon:
                                                            Icons.edit_outlined,
                                                        onTap: () async {
                                                          final args = {
                                                            'speaker': speaker,
                                                            'eventId':
                                                                widget.eventId,
                                                          };
                                                          final Speaker?
                                                          updated = await AppRouter
                                                              .router
                                                              .push(
                                                                AppRouter
                                                                    .speakerFormPath,
                                                                extra: args,
                                                              );
                                                          if (updated != null) {
                                                            await widget
                                                                .viewmodel
                                                                .editSpeaker(
                                                                  updated,
                                                                  widget
                                                                      .eventId,
                                                                );
                                                          }
                                                        },
                                                      ),
                                                      const SizedBox(width: 8),
                                                      IconWidget(
                                                        icon: Icons
                                                            .delete_outlined,
                                                        onTap: () async {
                                                          final bool?
                                                          shouldDelete = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: Text(
                                                                location
                                                                    .deleteSpeaker,
                                                              ),
                                                              content: Text(
                                                                location
                                                                    .confirmDeleteSpeaker(
                                                                      speaker
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
                                                                    location
                                                                        .cancel,
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop(
                                                                        true,
                                                                      ),
                                                                  child: Text(
                                                                    location
                                                                        .accept,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                          if (shouldDelete ==
                                                              true) {
                                                            await widget
                                                                .viewmodel
                                                                .removeSpeaker(
                                                                  speaker.uid,
                                                                  widget
                                                                      .eventId,
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

                                    // ⬆️ End of the changed part
                                    const SizedBox(height: 16),
                                    Text(
                                      speaker.name,
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
                                    const SizedBox(height: 16),
                                    Text(
                                      speaker.bio,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 24),
                                    SocialIconsRow(social: speaker.social),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class IconWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  final Color color;
  final double iconSize;
  final double padding;

  const IconWidget({
    super.key,
    required this.icon,
    this.onTap,
    this.color = Colors.black,
    this.iconSize = 14,
    this.padding = 5,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: iconSize, color: Colors.black),
      ),
    );
  }
}
