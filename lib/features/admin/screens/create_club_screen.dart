import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/club_repository.dart';
import '../providers/admin_providers.dart';

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _logoImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _logoImage = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final clubId = const Uuid().v4();
      String? logoUrl;
      if (_logoImage != null) {
        logoUrl = await ref.read(clubRepositoryProvider).uploadLogo(clubId, _logoImage!);
      }
      final club = Club(
        id: clubId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        logoUrl: logoUrl,
      );
      await ref.read(clubRepositoryProvider).createClub(club);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Club')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _logoImage != null ? FileImage(_logoImage!) : null,
                  child: _logoImage == null
                      ? const Icon(Icons.add_a_photo, size: 32)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to add logo'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                validator: (v) => Validators.required(v, 'Club Name'),
                decoration: const InputDecoration(labelText: 'Club Name'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) => Validators.required(v, 'Description'),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: 'Create Club',
                isLoading: _isLoading,
                useGradient: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
