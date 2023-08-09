// reimbursement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReimbursementService {
  final CollectionReference _requests =
      FirebaseFirestore.instance.collection('reimbursementRequests');

  Future<void> saveRequest(Map<String, dynamic> requestData) async {
    await _requests.add(requestData);
  }
}
