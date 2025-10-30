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
          ErrorView(errorMessage: widget.viewmodel.errorMessage);
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
                    Text(location.noSpeakersRegistered),
                  ],
                ),
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
                                    final Speaker? newSpeaker = await AppRouter
                                        .router
                                        .push(
                                          AppRouter.speakerFormPath,
                                          extra: {'eventId': widget.eventId},
                                        );
                                    if (newSpeaker != null) {
                                      widget.viewmodel.addSpeaker(
                                        newSpeaker,
                                        widget.eventId,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  label: const Text('Agregar Ponente'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF38B6FF),
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
                                  const Text(
                                    'Ponentes',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                                const Expanded(
                                  child: Text(
                                    'Ponentes',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                            return Stack(
                              children: [
                                Card(
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
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                                ),
                                                child: speaker.image != null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.network(
                                                          speaker.image!,
                                                          fit: BoxFit.fill,
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
                                                                return Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).colorScheme.surfaceContainerHighest,
                                                                  ),
                                                                  child: Center(
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              32,
                                                                          height:
                                                                              32,
                                                                          child: CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                3,
                                                                            value:
                                                                                loadingProgress.expectedTotalBytes !=
                                                                                    null
                                                                                ? loadingProgress.cumulativeBytesLoaded /
                                                                                      loadingProgress.expectedTotalBytes!
                                                                                : null,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        Text(
                                                                          location
                                                                              .loading,
                                                                          style:
                                                                              Theme.of(
                                                                                context,
                                                                              ).textTheme.bodySmall?.copyWith(
                                                                                color: Theme.of(
                                                                                  context,
                                                                                ).colorScheme.onSurfaceVariant,
                                                                              ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
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
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            48,
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).colorScheme.onSurfaceVariant,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            4,
                                                                      ),
                                                                      Text(
                                                                        location
                                                                            .errorLoadingImage,
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
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                ),
                                Positioned(
                                  top: 210,
                                  left: 45,
                                  child: FutureBuilder<bool>(
                                    future: widget.viewmodel.checkToken(),
                                    builder: (context, snapshot) {
                                      return snapshot.data == true
                                          ? Row(
                                              children: [
                                                IconWidget(
                                                  icon: Icons.edit_outlined,
                                                  onTap: () async {
                                                    Map<String, dynamic>
                                                    arguments = {
                                                      'speaker': speaker,
                                                      'eventId': widget.eventId,
                                                    };
                                                    final Speaker?
                                                    updatedSpeaker =
                                                        await AppRouter.router
                                                            .push(
                                                              AppRouter
                                                                  .speakerFormPath,
                                                              extra: arguments,
                                                            );

                                                    if (updatedSpeaker !=
                                                        null) {
                                                      widget.viewmodel
                                                          .editSpeaker(
                                                            updatedSpeaker,
                                                            widget.eventId,
                                                          );
                                                    }
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                IconWidget(
                                                  icon: Icons.delete_outlined,
                                                  onTap: () {
                                                    widget.viewmodel
                                                        .removeSpeaker(
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
