import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/cloud_functions/cloud_functions.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_mux_broadcast.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'alerted_model.dart';
export 'alerted_model.dart';

class AlertedWidget extends StatefulWidget {
  const AlertedWidget({
    super.key,
    this.videoID,
  });

  final String? videoID;

  @override
  State<AlertedWidget> createState() => _AlertedWidgetState();
}

class _AlertedWidgetState extends State<AlertedWidget> {
  late AlertedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? muxBroadcastPlaybackUrl;
  bool muxBroadcastIsLive = false;
  LiveStreamController? muxBroadcastController;
  final _initialAudioConfig = AudioConfig(
    channel: Channel.stereo,
  );
  final _initialVideoConfig = VideoConfig.withDefaultBitrate(
    resolution: Resolution.RESOLUTION_720,
  );
  bool _isSupportedPlatform = false;
  // variables for managing camera states
  bool _isCameraInitialized = false;
  bool _isFrontCamSelected = false;
  final _stopwatch = Stopwatch();
  String? _durationString;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlertedModel());

    if (Platform.isAndroid || Platform.isIOS) {
      _isSupportedPlatform = true;
      _initCamera();
    }
  }

  @override
  void dispose() {
    _model.dispose();

    _stopwatch.stop();
    _timer?.cancel();
    WakelockPlus.disable();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).alternate,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: FlutterFlowIconButton(
            borderColor: FlutterFlowTheme.of(context).primary,
            borderRadius: 20.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            fillColor: FlutterFlowTheme.of(context).primary,
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).secondary,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Alerted',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).secondary,
                  fontSize: 24.0,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 4.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: 120.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Text(
                            'Alert Sent To:',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).alternate,
                                  fontSize: 28.0,
                                ),
                          ),
                        ),
                        Text(
                          '10',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Readex Pro',
                                color: FlutterFlowTheme.of(context).alternate,
                                fontSize: 30.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: 180.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Text(
                              'Video & Audio:',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    fontSize: 28.0,
                                  ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: const AlignmentDirectional(1.0, 0.0),
                            child: FlutterFlowMuxBroadcast(
                              isCameraInitialized: _isCameraInitialized,
                              isStreaming: muxBroadcastIsLive,
                              durationString: _durationString,
                              borderRadius: BorderRadius.circular(0.0),
                              controller: muxBroadcastController,
                              videoConfig: _initialVideoConfig,
                              onCameraRotateButtonTap: () async {
                                await switchCamera();
                                setState(() =>
                                    _isFrontCamSelected = !_isFrontCamSelected);
                              },
                              startButtonText: 'Manual',
                              startButtonIcon: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              startButtonOptions: FFButtonOptions(
                                width: 160.0,
                                height: 50.0,
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.white,
                                    ),
                                elevation: 0.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              liveIcon: const FaIcon(
                                FontAwesomeIcons.solidCircle,
                                color: Colors.red,
                                size: 10.0,
                              ),
                              liveText: 'Live',
                              liveTextStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.red,
                                  ),
                              liveTextBackgroundColor: const Color(0x8A000000),
                              durationTextStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.red,
                                  ),
                              durationTextBackgroundColor: const Color(0x8A000000),
                              liveContainerBorderRadius:
                                  BorderRadius.circular(8.0),
                              durationContainerBorderRadius:
                                  BorderRadius.circular(8.0),
                              rotateButtonColor: const Color(0x8A000000),
                              rotateButtonIcon: const Icon(
                                Icons.flip_camera_android,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              stopButtonIcon: const Icon(
                                Icons.stop_rounded,
                                color: Colors.white,
                                size: 30.0,
                              ),
                              stopButtonColor: Colors.red,
                              onStartButtonTap: () async {
                                await startStreaming();

                                var videoAlertRecordReference =
                                    VideoAlertRecord.collection.doc('device');
                                await videoAlertRecordReference
                                    .set(createVideoAlertRecordData(
                                  capturing: true,
                                  playbackName: widget.videoID,
                                  playbackUrl: muxBroadcastPlaybackUrl,
                                  timestamp: getCurrentTimestamp,
                                  uid: currentUserUid,
                                ));
                                _model.muxStreamOutput =
                                    VideoAlertRecord.getDocumentFromData(
                                        createVideoAlertRecordData(
                                          capturing: true,
                                          playbackName: widget.videoID,
                                          playbackUrl: muxBroadcastPlaybackUrl,
                                          timestamp: getCurrentTimestamp,
                                          uid: currentUserUid,
                                        ),
                                        videoAlertRecordReference);

                                await _model.muxStreamOutput!.reference
                                    .update(createVideoAlertRecordData(
                                  capturing: false,
                                ));
                                context.safePop();

                                setState(() {});
                              },
                              onStopButtonTap: () async {
                                stopStreaming();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: 120.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Text(
                            'Safe Location Nearby:',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).alternate,
                                  fontSize: 28.0,
                                ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(1.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 20.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed('SafeLoc');
                              },
                              text: 'Find >',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).tertiary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.white,
                                    ),
                                elevation: 3.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: 120.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Text(
                            'Call:',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).alternate,
                                  fontSize: 28.0,
                                ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 12.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: 'Home',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Colors.white,
                                        ),
                                    elevation: 3.0,
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: 'Police',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Colors.white,
                                        ),
                                    elevation: 3.0,
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _initCamera() async {
    muxBroadcastController = initLiveStreamController();
    await muxBroadcastController!.create(
      initialAudioConfig: _initialAudioConfig,
      initialVideoConfig: _initialVideoConfig,
    );
    setState(() => _isCameraInitialized = true);
  }

  LiveStreamController initLiveStreamController() {
    return LiveStreamController(
      onConnectionSuccess: () {
        print('Connection succeeded');
        setState(() => muxBroadcastIsLive = true);
        _startTimer();
      },
      onConnectionFailed: (error) {
        print('Connection failed: $error');
        if (mounted) setState(() {});
      },
      onDisconnection: () {
        print('Disconnected');
        if (mounted) setState(() => muxBroadcastIsLive = false);
        _stopTimer();
      },
    );
  }

  Future<void> switchCamera() async {
    final LiveStreamController? liveStreamController = muxBroadcastController;
    if (liveStreamController == null) return;
    try {
      liveStreamController.switchCamera();
    } catch (error) {
      if (error is PlatformException) {
        print('Failed to switch camera: ${error.message}');
      } else {
        print('Failed to switch camera: $error');
      }
    }
  }

  Future<void> startStreaming() async {
    final LiveStreamController? liveStreamController = muxBroadcastController;
    if (liveStreamController == null) return;
    const streamBaseURL = 'rtmps://global-live.mux.com:443/app/';
    const callName = 'createLiveStream';
    final response =
        await makeCloudCall(callName, {'latency_mode': 'standard'});
    final streamKey = response['stream_key'];
    final playbackId = response['playback_ids'][0]['id'];
    muxBroadcastPlaybackUrl = 'https://stream.mux.com/$playbackId.m3u8';
    if (streamKey != null) {
      try {
        WakelockPlus.enable();
        await liveStreamController.startStreaming(
          streamKey: streamKey,
          url: streamBaseURL,
        );
      } catch (error) {
        if (error is PlatformException) {
          print("Error: failed to start stream: ${error.message}");
        } else {
          print("Error: failed to start stream: $error");
        }
      }
    }
  }

  Future<void> stopStreaming() async {
    final LiveStreamController? liveStreamController = muxBroadcastController;
    if (liveStreamController == null) return;
    try {
      WakelockPlus.disable();
      liveStreamController.stopStreaming();
      if (mounted) setState(() => muxBroadcastIsLive = false);
      _stopTimer();
    } catch (error) {
      if (error is PlatformException) {
        print('Failed to stop stream: ${error.message}');
      } else {
        print('Failed to stop stream: $error');
      }
    }
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _durationString = _getDurationString(_stopwatch.elapsed);
        });
      }
    });
  }

  void _stopTimer() {
    _stopwatch
      ..stop()
      ..reset();
    _durationString = _getDurationString(_stopwatch.elapsed);
    _timer?.cancel();
  }

  String _getDurationString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
