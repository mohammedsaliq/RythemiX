import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/core/utils/dynamic_size.dart';
import 'package:music_app/presentation/provider/icon_provider.dart';
import 'package:music_app/presentation/provider/music_playingneed_provider.dart';
import 'package:music_app/presentation/provider/setaudiosource.dart';
import 'package:music_app/presentation/widget/app_title.dart';
import 'package:music_app/presentation/widget/musicplayingimage_widget.dart';
import 'package:music_app/presentation/widget/process_baar.dart';

final AudioPlayer player = AudioPlayer();

class SongPlayingPage extends ConsumerStatefulWidget {
  const SongPlayingPage({
    this.data,
    required this.index,
    super.key,
    required this.playlist,
  });
  final ConcatenatingAudioSource playlist;
  final List? data;
  final int index;

  @override
  ConsumerState<SongPlayingPage> createState() => _SongPlayingPageState();
}

StateProvider<bool> isPlaying = StateProvider<bool>((ref) => false);

class _SongPlayingPageState extends ConsumerState<SongPlayingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    playmusic(playlist: widget.playlist, index: widget.index);
  }

  String formatTime(int seconds) {
    return '${Duration(seconds: seconds)}'.split('.')[0].padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    player.positionStream.listen((_) {
      ref.invalidate(currentIndexProvider);
      ref.watch(currentIndexProvider);
      ref.invalidate(playStateProvider);
      ref.watch(playStateProvider);
    });

    return Scaffold(
      appBar: AppBar(
        title: AppTitle(
          image: "assets/image/music_img.png",
          titileText: "PLAYING FROM PLATLIST",
          imgwidth: context.w(35),
          fontsize: context.w(6),
          textstyle: TextStyle(fontSize: context.w(8 * 3)),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              player.pause();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: context.h(8 * 13),
              ),
              const MusicPlayingImage(
                musicplayingimage: 'assets/image/background_img.jpg',
              ),
              SizedBox(
                height: context.h(15),
              ),
              Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: context.w(32)),
                    child: Text(
                      widget.data![ref.watch(currentIndexProvider)!].title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(8 * 4),
                      vertical: context.h(8 * 3),
                    ),
                    child: processBar(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      player.seekToPrevious();
                      player.positionStream.listen((_) {
                        ref.invalidate(currentIndexProvider);
                        ref.invalidate(playStateProvider);
                      });
                    },
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 55,
                  ),
                  IconButton(
                      onPressed: () {
                        if (player.playing) {
                          player.pause();
                        } else {
                          player.play();
                        }
                        ref.read(iconsprovider.notifier).state =
                            !ref.watch(iconsprovider.notifier).state;
                      },
                      icon: ref.watch(iconsprovider)
                          ? Icon(
                              Icons.pause,
                              size: context.w(60),
                            )
                          : Icon(
                              Icons.play_arrow_outlined,
                              size: context.w(60),
                            )),
                  IconButton(
                    onPressed: () {
                      player.seekToNext();
                      player.positionStream.listen((_) {
                        ref.invalidate(currentIndexProvider);
                        ref.invalidate(playStateProvider);
                      });
                    },
                    icon: const Icon(Icons.skip_next),
                    iconSize: 55,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
