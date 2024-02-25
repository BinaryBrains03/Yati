import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'alerted_widget.dart' show AlertedWidget;
import 'package:flutter/material.dart';

class AlertedModel extends FlutterFlowModel<AlertedWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Stores action output result for [Backend Call - Create Document] action in MuxBroadcast widget.
  VideoAlertRecord? muxStreamOutput;

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
