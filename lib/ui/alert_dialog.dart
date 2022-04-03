import 'package:ectoplasm/model/server_info.dart';
import 'package:flutter/material.dart';

showConfirmationDialog(BuildContext context,
    {required String title,
    required String body,
    required void Function(bool) onComplete}) {
  showDialog(
      context: context,
      builder: (context) {
        return _dialogBuilder(title, Text(body), onComplete);
      });
}

showEditDialog(BuildContext context,
    {required String title,
    required Widget child,
    required void Function(bool) onComplete}) {
  showDialog(
      context: context,
      builder: (context) {
        return _dialogBuilder(title, child, onComplete);
      });
}

Widget buildForm(
    {required TextEditingController nameController,
    required TextEditingController hostController,
    required TextEditingController portController}) {
  return Form(
    key: GlobalKey<FormState>(),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Server Name',
          ),
        ),
        TextFormField(
          controller: hostController,
          decoration: const InputDecoration(
            labelText: 'Server Address',
          ),
        ),
        TextFormField(
          keyboardType: TextInputType.number,
          controller: portController,
          decoration: const InputDecoration(
            labelText: 'Server Port',
          ),
          validator: (value) {
            if (value == null) {
              return "Field cannot be empty.";
            }

            try {
              int portVal = int.parse(value);
              if (portVal < 1 || portVal > 65535) {
                return "Port must be between 1 and 65535.";
              }
            } on FormatException {
              return "Port must be numeric.";
            }
          },
        ),
      ],
    ),
  );
}

void editInfo(BuildContext context,
    {ServerInfo? initialServerInfo,
    required Function(ServerInfo serverInfo) onComplete}) {
  final TextEditingController nameController = TextEditingController.fromValue(
      TextEditingValue(text: initialServerInfo?.name ?? ""));
  final TextEditingController hostController = TextEditingController.fromValue(
      TextEditingValue(text: initialServerInfo?.host ?? ""));
  final TextEditingController portController = TextEditingController.fromValue(
      TextEditingValue(text: initialServerInfo?.port.toString() ?? ""));

  Widget editForm = buildForm(
      nameController: nameController,
      hostController: hostController,
      portController: portController);

  showEditDialog(context,
      title: initialServerInfo != null
          ? "Edit ${initialServerInfo.name}"
          : "Create new Server",
      child: editForm, onComplete: (confirm) {
    if (confirm) {
      onComplete(ServerInfo(
          uuid: initialServerInfo?.uuid,
          name: nameController.text,
          host: hostController.text,
          port: int.parse(portController.text)));
    }
    Navigator.of(context).pop();
  });
}

AlertDialog _dialogBuilder(
    String title, Widget bodyWidget, void Function(bool) onComplete) {
  return AlertDialog(title: Text(title), content: bodyWidget, actions: [
    TextButton(
      onPressed: () {
        onComplete(false);
      },
      child: const Text('Cancel'),
    ),
    TextButton(
      onPressed: () {
        onComplete(true);
      },
      child: Text('OK'),
    ),
  ]);
}
