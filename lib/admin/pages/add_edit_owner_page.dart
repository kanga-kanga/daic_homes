import '../services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddEditOwnerPage extends StatefulWidget {
  final Map<String, dynamic>? owner;
  final VoidCallback? onOwnerSaved;

  const AddEditOwnerPage({super.key, this.owner, this.onOwnerSaved});

  @override
  State<AddEditOwnerPage> createState() => _AddEditOwnerPageState();
}

class _AddEditOwnerPageState extends State<AddEditOwnerPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.owner != null) {
      _nameController.text = widget.owner!['name'] ?? '';
      _emailController.text = widget.owner!['email'] ?? '';
      _phoneController.text = widget.owner!['phone'] ?? '';
    }
  }

  Future<void> _saveOwner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final owner = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      if (widget.owner == null) {
        owner['created_at'] = DateTime.now().toIso8601String();
        await _supabaseService.addOwner(owner);
      } else {
        await _supabaseService.updateOwner(widget.owner!['id'], owner);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.owner == null ? 'Propriétaire ajouté' : 'Propriétaire mis à jour'),
            backgroundColor: const Color(0xFF00A859),
          ),
        );
        widget.onOwnerSaved?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.owner == null ? 'Nouveau Propriétaire' : 'Modifier Propriétaire'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildFormCard(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveOwner,
                        child: Text(widget.owner == null ? 'Créer le compte' : 'Enregistrer les modifications'),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.owner == null ? 'Ajouter un contact' : 'Édition du profil',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideX(begin: -0.1),
        const SizedBox(height: 8),
        Text(
          'Gérez les informations de contact de vos bailleurs et propriétaires.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Nom complet', Icons.person_outline, isRequired: true),
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, 'Téléphone', Icons.phone_android_outlined, type: TextInputType.phone),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (v) {
        if (isRequired && (v == null || v.isEmpty)) return 'Ce champ est requis';
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
