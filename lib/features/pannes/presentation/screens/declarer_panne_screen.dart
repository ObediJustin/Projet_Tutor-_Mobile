import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/di/injection.dart';
import '../bloc/pannes_bloc.dart';

class DeclarerPanneScreen extends StatefulWidget {
  final int bienId;

  const DeclarerPanneScreen({
    super.key,
    required this.bienId,
  });

  @override
  State<DeclarerPanneScreen> createState() => _DeclarerPanneScreenState();
}

class _DeclarerPanneScreenState extends State<DeclarerPanneScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PannesBloc _bloc;

  String _selectedType = 'AUTRE';
  String _selectedPriorite = 'MOYENNE';
  final _descriptionController = TextEditingController();

  final List<Map<String, String>> _types = const [
    {'value': 'MECANIQUE', 'label': 'Mécanique'},
    {'value': 'ELECTRIQUE', 'label': 'Électrique'},
    {'value': 'ELECTRONIQUE', 'label': 'Électronique'},
    {'value': 'LOGICIELLE', 'label': 'Logicielle'},
    {'value': 'STRUCTURELLE', 'label': 'Structurelle'},
    {'value': 'AUTRE', 'label': 'Autre / Inconnu'},
  ];

  final List<Map<String, String>> _priorites = const [
    {'value': 'BASSE', 'label': 'Basse'},
    {'value': 'MOYENNE', 'label': 'Moyenne'},
    {'value': 'HAUTE', 'label': 'Haute'},
    {'value': 'CRITIQUE', 'label': 'Critique'},
  ];

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PannesBloc>();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _bloc.add(
        SubmitDeclarerPanne(
          idBien: widget.bienId,
          typePanne: _selectedType,
          priorite: _selectedPriorite,
          description: _descriptionController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Déclarer une panne'),
        ),
        body: BlocConsumer<PannesBloc, PannesState>(
          listener: (context, state) {
            if (state is PanneDeclareSuccess) {
              // Notification locale (SnackBar de succès)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Panne signalée avec succès (Réf: ${state.panne.bienReference ?? 'N/A'})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppConstants.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              // Retour à l'écran précédent
              context.pop();
            } else if (state is PannesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is PannesLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Signalement pour le bien N° ${widget.bienId}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type de panne (Titre)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _types.map((t) {
                        return DropdownMenuItem<String>(
                          value: t['value'],
                          child: Text(t['label']!),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (val) {
                              if (val != null) setState(() => _selectedType = val);
                            },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPriorite,
                      decoration: const InputDecoration(
                        labelText: 'Priorité',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high_outlined),
                      ),
                      items: _priorites.map((p) {
                        return DropdownMenuItem<String>(
                          value: p['value'],
                          child: Text(p['label']!),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (val) {
                              if (val != null) setState(() => _selectedPriorite = val);
                            },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Description détaillée',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 80),
                          child: Icon(Icons.description_outlined),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Veuillez saisir une description.';
                        }
                        if (val.trim().length < 5) {
                          return 'La description doit faire au moins 5 caractères.';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Signaler la panne',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
