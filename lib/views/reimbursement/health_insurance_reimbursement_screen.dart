import 'package:flutter/material.dart';

class HealthInsuranceReimbursementScreen extends StatelessWidget {
  const HealthInsuranceReimbursementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitação de Reembolso'),
      ),
      body: const Center(
        child: Text('Formulário de Solicitação de Reembolso Aqui'),
      ),
    );
  }
}
