import 'package:flutter/material.dart';
import 'package:yggdrasil/models/reimbursement_request.dart';
import 'package:yggdrasil/models/beneficiary.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

class HealthInsuranceReimbursementScreen extends StatefulWidget {
  const HealthInsuranceReimbursementScreen({Key? key}) : super(key: key);

  @override
  HealthInsuranceReimbursementScreenState createState() =>
      HealthInsuranceReimbursementScreenState();
}

class HealthInsuranceReimbursementScreenState
    extends State<HealthInsuranceReimbursementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ReimbursementRequest _reimbursementRequest;

  List<MoneyMaskedTextController> controllers = [];

  @override
  void initState() {
    super.initState();

    final username = context.read<AuthService>().user.value?.displayName ?? '';

    _reimbursementRequest = ReimbursementRequest(
      requesterName: username, // nome do usuário logado
      date: DateTime.now(),
      beneficiaries: [Beneficiary(name: '', amount: 0.0)],
    );

    // Initialize controllers
    controllers = List<MoneyMaskedTextController>.generate(
      _reimbursementRequest.beneficiaries.length,
      (index) => MoneyMaskedTextController(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: 'R\$ ',
        precision: 2,
        initialValue: _reimbursementRequest.beneficiaries[index].amount,
      ),
    );
  }

  void _addBeneficiary() {
    setState(() {
      _reimbursementRequest.beneficiaries
          .add(Beneficiary(name: '', amount: 0.0));
      controllers.add(MoneyMaskedTextController(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: 'R\$ ',
        precision: 2,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitação de Reembolso'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nome do colaborador',
              ),
              initialValue: _reimbursementRequest.requesterName,
              onChanged: (value) {
                _reimbursementRequest.requesterName = value;
              },
            ),
            // DatePicker para selecionar a data
            // Lista de beneficiários
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addBeneficiary,
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reimbursementRequest.beneficiaries.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nome do beneficiário',
                      ),
                      initialValue:
                          _reimbursementRequest.beneficiaries[index].name,
                      onChanged: (value) {
                        _reimbursementRequest.beneficiaries[index].name = value;
                      },
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: controllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Valor',
                            ),
                            onChanged: (value) {
                              _reimbursementRequest.beneficiaries[index]
                                  .amount = controllers[index].numberValue;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Botão para fazer upload do comprovante de pagamento
            // Checkbox para confirmar que as informações estão corretas
            // Botão para enviar o formulário
          ],
        ),
      ),
    );
  }
}
