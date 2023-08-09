// Importando as dependências necessárias
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yggdrasil/models/reimbursement_request.dart';
import 'package:yggdrasil/models/beneficiary.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yggdrasil/services/reimbursement_service.dart';
import 'dart:convert';
import 'dart:math';

import 'package:yggdrasil/services/storage_service.dart';

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
  final _dateController = TextEditingController();

  final List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();

    // Obtendo o nome do usuário logado
    final username = context.read<AuthService>().user.value?.displayName ?? '';

    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());

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

  // Função para converter o tipo de beneficiário para string
  String beneficiaryTypeToString(BeneficiaryType type) {
    switch (type) {
      case BeneficiaryType.holder:
        return 'Titular';
      case BeneficiaryType.dependent:
        return 'Dependente';
      default:
        return '';
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        for (var path in result.paths) {
          final file = File(path!);
          if (!_selectedFiles
              .any((existingFile) => existingFile.path == file.path)) {
            _selectedFiles.add(file);
          }
        }
      });
    } else {
      // O usuário cancelou a seleção de arquivos
    }

    if (_selectedFiles.isNotEmpty) {
      for (var file in _selectedFiles) {
        final path =
            'reimbursements/${DateTime.now().millisecondsSinceEpoch}/${file.path.split('/').last}';
        final downloadUrl = await StorageService().uploadFile(file, path);
        // Aqui você pode armazenar o downloadUrl em uma lista ou em um modelo para uso posterior
      }
    }
  }

  String generateGuid() {
    var random = Random.secure();
    var values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(values).substring(0, 22);
  }

  List<String> generateNext12Months() {
    DateTime now = DateTime.now();
    return List.generate(12, (i) {
      DateTime nextMonth = now.add(Duration(days: 30 * i));
      return '${nextMonth.month.toString().padLeft(2, '0')}/${nextMonth.year}';
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
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
              children: <Widget>[
                // Seção de Protocolo e Data (Mês/Ano)
                Row(
                  children: [
                    // Campo de Protocolo
                    Expanded(
                      flex: 2, // Dando mais espaço para o Protocolo
                      child: TextFormField(
                        readOnly: true,
                        initialValue: generateGuid().substring(0, 14),
                        decoration: const InputDecoration(
                          labelText: 'Protocolo:',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Dropdown para o Mês
                    Expanded(
                      flex: 1,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Mês',
                            border: OutlineInputBorder(),
                          ),
                          value:
                              DateTime.now().month.toString().padLeft(2, '0'),
                          items: List.generate(
                                  12, (i) => (i + 1).toString().padLeft(2, '0'))
                              .map((month) {
                            return DropdownMenuItem(
                                value: month, child: Text(month));
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              // Sua lógica de tratamento para o mês selecionado
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Dropdown para o Ano
                    Expanded(
                      flex: 1,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Ano',
                            border: OutlineInputBorder(),
                          ),
                          value: DateTime.now().year.toString(),
                          items: [
                            (DateTime.now().year - 1).toString(),
                            DateTime.now().year.toString(),
                            (DateTime.now().year + 1).toString()
                          ].map((year) {
                            return DropdownMenuItem(
                                value: year, child: Text(year));
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              // Sua lógica de tratamento para o ano selecionado
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Campo do nome do colaborador
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
                SizedBox(height: screenHeight * 0.02),

                // Seção Beneficiários
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Beneficiários",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Lista de beneficiários
                    ...List.generate(_reimbursementRequest.beneficiaries.length,
                        (index) {
                      return Stack(
                        children: <Widget>[
                          // Caixa de detalhes do beneficiário
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: screenHeight *
                                    0.01), // 1% da altura da tela
                            child: Card(
                              elevation: 2.0,
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth *
                                    0.03), // 3% da largura da tela
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
                                              .beneficiaries[index]
                                              .name = value;
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
                                                      .beneficiaries[index]
                                                      .amount =
                                                  controllers[index]
                                                      .numberValue;
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                            width: screenWidth *
                                                0.02), // 2% da largura da tela
                                        // Dropdown de tipo de beneficiário
                                        Expanded(
                                          flex: 1,
                                          child: DropdownButtonFormField<
                                              BeneficiaryType>(
                                            decoration: const InputDecoration(
                                              labelText: 'Tipo',
                                              border: OutlineInputBorder(),
                                            ),
                                            value: _reimbursementRequest
                                                .beneficiaries[index].type,
                                            onChanged:
                                                (BeneficiaryType? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  _reimbursementRequest
                                                      .beneficiaries[index]
                                                      .type = newValue;
                                                });
                                              }
                                            },
                                            items: BeneficiaryType.values
                                                .map((BeneficiaryType type) {
                                              return DropdownMenuItem<
                                                  BeneficiaryType>(
                                                value: type,
                                                child: Text(
                                                    beneficiaryTypeToString(
                                                        type)),
                                              );
                                            }).toList(),
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
                            top: 5.0,
                            right: 0.0,
                            child: Container(
                              width: 15.0,
                              height: 15.0,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                iconSize: 15.0,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.remove,
                                    color: Colors.white),
                                onPressed: () => _removeBeneficiary(index),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.blue[100],
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar beneficiário'),
                      onPressed: _addBeneficiary,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),

                // Seção Arquivos anexados
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Arquivos anexados",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ..._selectedFiles.map((file) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: const Icon(Icons.attach_file),
                            title: Text(file.path.split('/').last),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedFiles.remove(file);
                                });
                              },
                            ),
                          ),
                        )),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.blue[100],
                      ),
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        _selectedFiles.isNotEmpty
                            ? 'Arquivo Anexado'
                            : 'Anexar Arquivo',
                      ),
                      onPressed: _pickFile,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
                // Seção de Botões de confirmação
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {},
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {                        
                          final requestData = {
                            'requesterName':
                                _reimbursementRequest.requesterName,
                            'date': _reimbursementRequest.date,
                            'beneficiaries': _reimbursementRequest.beneficiaries
                                .map((beneficiary) {
                              return {
                                'name': beneficiary.name,
                                'amount': beneficiary.amount,
                                'type': beneficiary.type.toString(),
                              };
                            }).toList(),                            
                          };
                          await ReimbursementService().saveRequest(requestData);                          
                        }
                      },
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
