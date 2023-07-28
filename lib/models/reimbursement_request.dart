import 'package:yggdrasil/models/beneficiary.dart';

class ReimbursementRequest {
  late final String requesterName;
  final DateTime date;
  List<Beneficiary> beneficiaries;

  ReimbursementRequest({required this.requesterName, required this.date, required this.beneficiaries});
}
