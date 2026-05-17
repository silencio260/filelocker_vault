import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../vault/domain/entities/vaulted_file_entity.dart';
import '../bloc/viewer_bloc/viewer_bloc.dart';
import '../bloc/viewer_bloc/viewer_event.dart';
import '../bloc/viewer_bloc/viewer_state.dart';
import '../widgets/image_viewer_widget.dart';
import '../widgets/video_player_widget.dart';

class MediaViewerArgs {
  final List<VaultedFileEntity> files;
  final int initialIndex;
  const MediaViewerArgs({required this.files, required this.initialIndex});
}

class MediaViewerPage extends StatefulWidget {
  final List<VaultedFileEntity> files;
  final int initialIndex;

  const MediaViewerPage({
    super.key,
    required this.files,
    required this.initialIndex,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() => _showAppBar = !_showAppBar);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = GetIt.I<ViewerBloc>();
        _loadCurrentFile(bloc);
        return bloc;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _showAppBar
            ? AppBar(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                title: Text(
                  widget.files[_currentIndex].originalName,
                  style: const TextStyle(fontSize: 14),
                ),
                actions: [
                  Text(
                    '${_currentIndex + 1} / ${widget.files.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                ],
              )
            : null,
        body: GestureDetector(
          onTap: _toggleAppBar,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.files.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              context
                  .read<ViewerBloc>()
                  .add(ViewerPageChangedEvent(index));
              _loadCurrentFile(context.read<ViewerBloc>());
            },
            itemBuilder: (context, index) {
              return BlocBuilder<ViewerBloc, ViewerState>(
                builder: (context, state) {
                  if (index != _currentIndex) {
                    return const SizedBox.shrink();
                  }
                  if (state is ViewerDecrypting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text('Decrypting...',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    );
                  }
                  if (state is ViewerImageReady) {
                    return Center(
                      child: ImageViewerWidget(bytes: state.bytes),
                    );
                  }
                  if (state is ViewerVideoReady) {
                    return Center(
                      child: VideoPlayerWidget(filePath: state.tempPath),
                    );
                  }
                  if (state is ViewerError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _loadCurrentFile(ViewerBloc bloc) {
    final file = widget.files[_currentIndex];
    if (file.isVideo) {
      bloc.add(ViewerLoadVideoEvent(file));
    } else {
      bloc.add(ViewerLoadImageEvent(file));
    }
  }
}
