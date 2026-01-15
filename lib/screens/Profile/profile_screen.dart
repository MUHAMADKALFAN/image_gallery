import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'profile_notifier.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final profile = context.read<ProfileNotifier>();
    nameController = TextEditingController(text: profile.name);
    emailController = TextEditingController(text: profile.email);
  }

  // ================= IMAGE PICK & UPLOAD =================
  Future<void> pickAndUploadImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    final profile = context.read<ProfileNotifier>();

    // 🔹 Upload to backend
    final imageUrl = await ApiService().uploadProfileImage(
      email: profile.email,
      image: File(picked.path),
    );

    // 🔹 Save URL in provider
    await profile.setImage(imageUrl);
  }

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= SAVE NAME & EMAIL =================
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<ProfileNotifier>();

    await profile.setUser(
      newName: nameController.text.trim(),
      newEmail: emailController.text.trim(),
      newImageUrl: profile.imageUrl,
    );

    setState(() => isEditing = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => isEditing = !isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: isEditing ? showImagePicker : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: profile.imageUrl != null
                          ? NetworkImage(profile.imageUrl!)
                          : null,
                      child: profile.imageUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                enabled: isEditing,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                enabled: isEditing,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 30),
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saveProfile,
                    child: const Text('Save Changes'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
