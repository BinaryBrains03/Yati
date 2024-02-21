import '/flutter_flow/flutter_flow_util.dart';
import 'buzzer_widget.dart' show BuzzerWidget;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BuzzerModel extends FlutterFlowModel<BuzzerWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  AudioPlayer? soundPlayer1;
  AudioPlayer? soundPlayer2;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
