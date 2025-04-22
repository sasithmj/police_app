import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioPlayerWidget extends StatefulWidget {
  final int ruleNumber;

  const AudioPlayerWidget({
    Key? key,
    required this.ruleNumber,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _progress = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<AudioFile> _audioFiles = [];
  AudioFile? _mainAudioFile;
  String? _currentlyPlayingFile; // Track which file is currently playing
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Base URL for your API - change this to your actual backend URL
  final String _baseUrl = 'http://172.20.10.9:3001';

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadAudioFiles();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing != _isPlaying) {
        setState(() {
          _isPlaying = state.playing;
          // If not playing anymore, clear the currently playing file
          if (!state.playing) {
            // Only clear if it's completed, not paused
            if (state.processingState == ProcessingState.completed) {
              _currentlyPlayingFile = null;
            }
          }
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
        if (_duration.inMilliseconds > 0) {
          _progress = _position.inMilliseconds / _duration.inMilliseconds;
        }
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _progress = 0.0;
          _currentlyPlayingFile =
              null; // Clear the currently playing file when completed
        });
      }
    });
  }

  Future<void> _loadAudioFiles() async {
    try {
      print('🔄 DEBUG: Starting _loadAudioFiles for rule ${widget.ruleNumber}');

      final response = await http
          .get(Uri.parse('$_baseUrl/api/tracks/${widget.ruleNumber}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['files'] != null) {
          List<AudioFile> audioFiles = [];

          for (var file in data['files']) {
            audioFiles.add(AudioFile(
              filename: file['filename'],
              url: file['url'],
              isMainFile: file['isMainFile'] ?? false,
            ));
          }

          print('📊 DEBUG: Found ${audioFiles.length} audio files from server');

          if (audioFiles.isNotEmpty) {
            // Find main file
            AudioFile? mainFile = audioFiles.firstWhere(
              (file) => file.isMainFile,
              orElse: () => audioFiles.first,
            );

            setState(() {
              _audioFiles = audioFiles;
              _mainAudioFile = mainFile;
              _isLoading = false;
            });

            // Pre-load the main audio file
            if (_mainAudioFile != null) {
              await _loadAndPrepareAudio(_mainAudioFile!.url);
            }
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = data['message'] ?? 'Failed to load audio files';
          });
        }
      } else if (response.statusCode == 404) {
        print('⚠️ DEBUG: No audio files found for rule ${widget.ruleNumber}');
        setState(() {
          _isLoading = false;
        });
      } else {
        print('❌ DEBUG: Error loading audio files: ${response.statusCode}');
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('❌❌ DEBUG: Error loading audio files: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Connection error: $e';
      });
    }
  }

  Future<void> _loadAndPrepareAudio(String url) async {
    print('🔄 DEBUG: Loading and preparing audio: $url');
    try {
      await _audioPlayer.setUrl(url);
      print('✅ DEBUG: Successfully loaded audio URL');
    } catch (e) {
      print('❌ DEBUG: Error loading audio: $e');
    }
  }

  void _togglePlay() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      // Set the currently playing file when play starts
      setState(() {
        _currentlyPlayingFile = _currentlyPlayingFile ?? _mainAudioFile?.url;
      });
      await _audioPlayer.play();
    }
  }

  void _rewind() {
    if (_position.inSeconds >= 10) {
      _audioPlayer.seek(_position - const Duration(seconds: 10));
    } else {
      _audioPlayer.seek(Duration.zero);
    }
  }

  void _forward() {
    if (_duration.inSeconds - _position.inSeconds > 10) {
      _audioPlayer.seek(_position + const Duration(seconds: 10));
    } else {
      _audioPlayer.seek(_duration);
    }
  }

  void _playAudioFile(AudioFile audioFile) async {
    await _audioPlayer.stop();
    await _loadAndPrepareAudio(audioFile.url);

    // Update the currently playing file
    setState(() {
      _currentlyPlayingFile = audioFile.url;
    });

    await _audioPlayer.play();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.error.withOpacity(0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Error loading audio files',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              Text(_errorMessage),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadAudioFiles();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_audioFiles.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No audio files available for Rule ${widget.ruleNumber}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main audio player section
        if (_mainAudioFile != null)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Listen to explanation for Rule ${widget.ruleNumber}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _mainAudioFile!.filename,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: _currentlyPlayingFile ==
                                        _mainAudioFile!.url
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                                fontWeight:
                                    _currentlyPlayingFile == _mainAudioFile!.url
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                        ),
                      ),
                      if (_currentlyPlayingFile == _mainAudioFile!.url &&
                          _isPlaying)
                        Icon(
                          Icons.volume_up,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(_formatDuration(_position)),
                      Expanded(
                        child: Slider(
                          value: _progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final position = Duration(
                                milliseconds:
                                    (value * _duration.inMilliseconds).round());
                            _audioPlayer.seek(position);
                          },
                        ),
                      ),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        onPressed: _rewind,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        onPressed: _togglePlay,
                        mini: false,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        onPressed: _forward,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Additional audio files section
        if (_audioFiles.length > 1) ...[
          const SizedBox(height: 24),
          Text(
            'Additional Audio Files',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _audioFiles.length,
            itemBuilder: (context, index) {
              final audioFile = _audioFiles[index];

              // Check if this is the currently playing file
              final isPlaying =
                  audioFile.url == _currentlyPlayingFile && _isPlaying;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                // Highlight the card if it's playing
                color: isPlaying
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3)
                    : null,
                child: ListTile(
                  leading: Icon(
                    isPlaying ? Icons.volume_up : Icons.audio_file,
                    color: isPlaying
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    audioFile.filename,
                    style: TextStyle(
                      fontWeight:
                          isPlaying ? FontWeight.bold : FontWeight.normal,
                      color: isPlaying
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: isPlaying
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        _audioPlayer.pause();
                      } else {
                        _playAudioFile(audioFile);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

// Model class for audio files
class AudioFile {
  final String filename;
  final String url;
  final bool isMainFile;

  AudioFile({
    required this.filename,
    required this.url,
    this.isMainFile = false,
  });
}
