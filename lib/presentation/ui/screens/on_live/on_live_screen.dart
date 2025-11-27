import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
import 'package:sec/presentation/ui/widgets/form_screen_wrapper.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class OnLiveData {
  final String youtubeUrl;

  OnLiveData({required this.youtubeUrl});
}

class OnLiveScreen extends StatefulWidget {
  final OnLiveData? data;
  final OnLiveViewModel viewmodel = getIt<OnLiveViewModel>();

  OnLiveScreen({super.key, this.data});

  @override
  State<OnLiveScreen> createState() => _OnLiveScreenState();
}

class _OnLiveScreenState extends State<OnLiveScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    widget.viewmodel.setup();
    final videoId = YoutubePlayer.convertUrlToId(widget.data!.youtubeUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    } else {
      // Handle invalid URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    return ValueListenableBuilder<ViewState>(
      valueListenable: widget.viewmodel.viewState,
      builder: (context, viewState, child) {
        if (viewState == ViewState.isLoading) {
          return FormScreenWrapper(
            pageTitle: location.loadingTitle,
            widgetFormChild: const Center(child: CircularProgressIndicator()),
          );
        }

        return FormScreenWrapper(
          pageTitle: location.onLive,
          widgetFormChild: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              bottomActions: [
                FullScreenButton(),
              ],
            ),
            builder: (context, player) {
              return Column(
                children: [
                  // some widgets
                  player,
                  //some other widgets
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
