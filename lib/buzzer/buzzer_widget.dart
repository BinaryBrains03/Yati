import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'buzzer_model.dart';
export 'buzzer_model.dart';

class BuzzerWidget extends StatefulWidget {
  const BuzzerWidget({super.key});

  @override
  State<BuzzerWidget> createState() => _BuzzerWidgetState();
}

class _BuzzerWidgetState extends State<BuzzerWidget> {
  late BuzzerModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuzzerModel());
  }

  @override
  void dispose() {
    _model.dispose();

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
            'Buzzer',
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
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 160.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      _model.soundPlayer1 ??= AudioPlayer();
                      if (_model.soundPlayer1!.playing) {
                        await _model.soundPlayer1!.stop();
                      }
                      _model.soundPlayer1!.setVolume(1.0);
                      _model.soundPlayer1!
                          .setUrl('')
                          .then((_) => _model.soundPlayer1!.play());
                    },
                    text: 'Turn On Buzzer',
                    options: FFButtonOptions(
                      width: 300.0,
                      height: 86.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).tertiary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 32.0,
                              ),
                      elevation: 3.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 160.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      _model.soundPlayer2 ??= AudioPlayer();
                      if (_model.soundPlayer2!.playing) {
                        await _model.soundPlayer2!.stop();
                      }
                      _model.soundPlayer2!.setVolume(1.0);
                      _model.soundPlayer2!
                          .setUrl('')
                          .then((_) => _model.soundPlayer2!.play());
                    },
                    text: 'Alert',
                    options: FFButtonOptions(
                      width: 300.0,
                      height: 100.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).tertiary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 32.0,
                              ),
                      elevation: 3.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
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
}
