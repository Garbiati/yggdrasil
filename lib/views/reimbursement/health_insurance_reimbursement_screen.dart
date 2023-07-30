// Importando as dependências necessárias
import 'package:flutter/material.dart';
import 'package:yggdrasil/models/reimbursement_request.dart';
import 'package:yggdrasil/models/beneficiary.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

// Definindo o widget da tela de Solicitação de Reembolso de Plano de Saúde
class HealthInsuranceReimbursementScreen extends StatefulWidget {
  const HealthInsuranceReimbursementScreen({Key? key}) : super(key: key);

  @override
  HealthInsuranceReimbursementScreenState createState() =>
      HealthInsuranceReimbursementScreenState();
}

class HealthInsuranceReimbursementScreenState
    extends State<HealthInsuranceReimbursementScreen> {
  // Inicializando uma chave global para o formulário
  final _formKey = GlobalKey<FormState>();
  // Inicializando uma variável para armazenar a solicitação de reembolso
  late final ReimbursementRequest _reimbursementRequest;
  // Inicializando uma lista para os controladores de texto dos campos de valor
  List<MoneyMaskedTextController> controllers = [];

  @override
  void initState() {
    super.initState();

    // Obtendo o nome do usuário logado
    final username = context.read<AuthService>().user.value?.displayName ?? '';

    // Criando uma nova solicitação de reembolso
    _reimbursementRequest = ReimbursementRequest(
      requesterName: username,
      date: DateTime.now(),
      beneficiaries: [
        Beneficiary(name: username, amount: 0.0, type: BeneficiaryType.holder)
      ],
    );

    // Inicializando os controladores de texto para os campos de valor
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

  // Função para adicionar um beneficiário à lista
  void _addBeneficiary() {
    setState(() {
      BeneficiaryType type = _reimbursementRequest.beneficiaries.isEmpty
          ? BeneficiaryType.holder
          : BeneficiaryType.dependent;
      String name = type == BeneficiaryType.holder
          ? _reimbursementRequest.requesterName
          : '';
      _reimbursementRequest.beneficiaries
          .add(Beneficiary(name: name, amount: 0.0, type: type));
      controllers.add(MoneyMaskedTextController(
        decimalSeparator: ',',
        thousandSeparator: '.',
        leftSymbol: 'R\$ ',
        precision: 2,
        initialValue: 0.0,
      ));
    });
  }

  // Função para remover um beneficiário da lista
  void _removeBeneficiary(int index) {
    setState(() {
      _reimbursementRequest.beneficiaries.removeAt(index);
      controllers.removeAt(index);
    });
  }

  // Função para construir a interface gráfica do widget
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitação de Reembolso',
            style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05), // 5% do tamanho da tela
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Column(
              children: <Widget>[
                // Campo para o nome do colaborador
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome do colaborador',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _reimbursementRequest.requesterName,
                  onChanged: (value) {
                    _reimbursementRequest.requesterName = value;
                  },
                ),
                SizedBox(height: screenHeight * 0.02), // 2% da altura da tela
                // Título da lista de beneficiários
                const Text("Beneficiários",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Lista de beneficiários
                ...List.generate(_reimbursementRequest.beneficiaries.length,
                    (index) {
                  return Stack(
                    children: <Widget>[
                      // Caixa de detalhes do beneficiário
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical:
                                screenHeight * 0.01), // 1% da altura da tela
                        child: Card(
                          elevation: 2.0,
                          child: Padding(
                            padding: EdgeInsets.all(
                                screenWidth * 0.02), // 2% da largura da tela
                            child: Column(
                              children: <Widget>[
                                // Campo para o nome do beneficiário
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Nome do beneficiário',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: _reimbursementRequest
                                      .beneficiaries[index].name,
                                  onChanged: (value) {
                                    setState(() {
                                      _reimbursementRequest
                                          .beneficiaries[index].name = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                    height: screenHeight *
                                        0.02), // 2% da altura da tela
                                // Linha com o campo de valor e o dropdown de tipo de beneficiário
                                Row(
                                  children: <Widget>[
                                    // Campo de valor
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        controller: controllers[index],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Valor',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          _reimbursementRequest
                                                  .beneficiaries[index].amount =
                                              controllers[index].numberValue;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                        width: screenWidth *
                                            0.02), // 2% da largura da tela
                                    // Dropdown de tipo de beneficiário
                                    Expanded(
                                      flex: 1,
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Tipo',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: _reimbursementRequest
                                            .beneficiaries[index].type,
                                        items: BeneficiaryType.values
                                            .map((BeneficiaryType type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(type
                                                .toString()
                                                .split('.')
                                                .last),
                                          );
                                        }).toList(),
                                        onChanged: (BeneficiaryType? value) {
                                          if (value != null) {
                                            setState(() {
                                              _reimbursementRequest
                                                  .beneficiaries[index]
                                                  .type = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Botão de excluir beneficiário
                      Positioned(
                        top: 2.0,
                        right: -2.0,
                        child: Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 15.0,
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeBeneficiary(index),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                // Botão de adicionar beneficiário
                TextButton.icon(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  label: const Text('Adicionar beneficiário',
                      style: TextStyle(color: Colors.blue)),
                  onPressed: _addBeneficiary,
                ),
                SizedBox(height: screenHeight * 0.02), // 2% da altura da tela
                // Botão de enviar solicitação
                ElevatedButton(
                  child: const Text('Enviar Solicitação',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // Aqui você pode adicionar a lógica para enviar a solicitação de reembolso
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
