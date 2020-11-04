import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ActivityStatus {
  static const Text = 1;
  static const Image = 2;
  // static const Status = 4;
  // static const Proposal = 8;
  //todo add more statuses
}

class SeenStatus {
  static const Sent = 0;
  static const Recieved = 1;
  static const Seen = 2;
  //todo add more statuses
}

class ActivityLog {
  String userId;
  int activityStatus;
  int seenStatus;
  List<String> seenBy;
  Timestamp timestamp;
  String path;
  String documentId;

  ActivityLog.fromSnapshot(DocumentSnapshot snapshot) {
    documentId = snapshot.id;
    var data = snapshot.data();
    userId = data['userId'];
    seenStatus = data['seenStatus'];
    seenBy = List<String>.from(data['seenBy'] ?? []);
    timestamp = data['timestamp'];
    activityStatus = data['activityStatus'];
    path = snapshot.reference.path;
  }

  ActivityLog({@required this.activityStatus, @required this.userId, String documentId}) {
    this.documentId = documentId;
    this.seenStatus = SeenStatus.Sent;
    this.seenBy = [];
  }

  Map<String, Object> toJson() {
    Map<String, Object> json = new Map<String, Object>();
    json['userId'] = userId;
    // json['idTo'] = idTo;
    json['seenStatus'] = seenStatus;
    json['seenBy'] = seenBy ?? [];
    json['timestamp'] = FieldValue.serverTimestamp();
    json['activityStatus'] = activityStatus;
    return json;
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ActivityLog && o.path == path;
  }

  @override
  int get hashCode {
    return path.hashCode;
  }
}
