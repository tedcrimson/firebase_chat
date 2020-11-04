// import 'package:beyouteek/models/activities/activitylog.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class StatusActivity extends ActivityLog {
//   int taskStatus;
//   bool highPriority;
//   String get taskStatusInfo => TaskStatus.getInfo(taskStatus);
//   StatusActivity.fromSnapshot(DocumentSnapshot snap)
//       : super.fromSnapshot(snap) {
//     taskStatus = snap.data['taskStatus'];
//     highPriority = snap.data['highPriority'];

//   }

//   StatusActivity({this.taskStatus, String idFrom, String idTo})
//       : super(activityStatus: ActivityStatus.Status);

//   @override
//   Map<String, Object> toJson() {
//     var json = super.toJson();
//     json['taskStatus'] = taskStatus;
//     json['highPriority'] = highPriority;
//     return json;
//   }
// }

// class TaskStatus {
//   static const int TASK_CREATED = 0;
//   static const int PROPOSAL_SET = 500;
//   static const int TASK_ENDED = 1000;

//   static getInfo(int taskStatus) {
//     String info = '';
//     switch (taskStatus) {
//       case TASK_CREATED:
//         info = "ტასკი შეიქმნა";
//         break;
//       case PROPOSAL_SET:
//         info = "თქვენი შეთავაზება აირჩიეს";
//         break;
//       case TASK_ENDED:
//         info = "ტასკი მოკვტა";
//         break;
//     }
//     return info;
//   }
// }
