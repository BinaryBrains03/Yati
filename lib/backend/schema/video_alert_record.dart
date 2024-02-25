import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';

class VideoAlertRecord extends FirestoreRecord {
  VideoAlertRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "capturing" field.
  bool? _capturing;
  bool get capturing => _capturing ?? false;
  bool hasCapturing() => _capturing != null;

  // "playback_name" field.
  String? _playbackName;
  String get playbackName => _playbackName ?? '';
  bool hasPlaybackName() => _playbackName != null;

  // "playback_url" field.
  String? _playbackUrl;
  String get playbackUrl => _playbackUrl ?? '';
  bool hasPlaybackUrl() => _playbackUrl != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  void _initializeFields() {
    _capturing = snapshotData['capturing'] as bool?;
    _playbackName = snapshotData['playback_name'] as String?;
    _playbackUrl = snapshotData['playback_url'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('video_alert');

  static Stream<VideoAlertRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VideoAlertRecord.fromSnapshot(s));

  static Future<VideoAlertRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VideoAlertRecord.fromSnapshot(s));

  static VideoAlertRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VideoAlertRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VideoAlertRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VideoAlertRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VideoAlertRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VideoAlertRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVideoAlertRecordData({
  bool? capturing,
  String? playbackName,
  String? playbackUrl,
  DateTime? timestamp,
  String? uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'capturing': capturing,
      'playback_name': playbackName,
      'playback_url': playbackUrl,
      'timestamp': timestamp,
      'uid': uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class VideoAlertRecordDocumentEquality implements Equality<VideoAlertRecord> {
  const VideoAlertRecordDocumentEquality();

  @override
  bool equals(VideoAlertRecord? e1, VideoAlertRecord? e2) {
    return e1?.capturing == e2?.capturing &&
        e1?.playbackName == e2?.playbackName &&
        e1?.playbackUrl == e2?.playbackUrl &&
        e1?.timestamp == e2?.timestamp &&
        e1?.uid == e2?.uid;
  }

  @override
  int hash(VideoAlertRecord? e) => const ListEquality().hash(
      [e?.capturing, e?.playbackName, e?.playbackUrl, e?.timestamp, e?.uid]);

  @override
  bool isValidKey(Object? o) => o is VideoAlertRecord;
}
