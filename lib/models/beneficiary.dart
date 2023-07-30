enum BeneficiaryType { holder, dependent }

class Beneficiary {
  String name;
  double amount;
  BeneficiaryType type;

  Beneficiary({
    required this.name,
    this.amount = 0.0,
    required this.type,
  });
}
