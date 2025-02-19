import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absen_smkn1_punggelan/app/presentation/profile/profile_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryOrange = const Color.fromRGBO(243, 154, 0, 0.988);
  final Color bgLight = Colors.white;
  final Color textDark = const Color.fromRGBO(33, 33, 33, 1);
  final Color textGrey = Colors.grey;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        final provider = Provider.of<ProfileNotifier>(context, listen: false);
        
        final file = File(image.path);
        await provider.uploadProfilePicture(context, file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Camera'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Picture'),
        content: const Text('Are you sure you want to delete your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<ProfileNotifier>(context, listen: false);
              provider.deleteProfilePicture(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context, ProfileNotifier provider) async {
    final nameController = TextEditingController(text: provider.name);
    final emailController = TextEditingController(text: provider.email);
    final phoneController = TextEditingController(text: provider.phone);
    File? selectedPhoto;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  
                  if (image != null) {
                    // Check file size
                    final file = File(image.path);
                    final size = await file.length();
                    if (size > 5 * 1024 * 1024) { // 5MB
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ukuran foto maksimal 5MB'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Preview foto
                    setState(() {
                      selectedPhoto = file;
                    });
                  }
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: selectedPhoto != null 
                          ? FileImage(selectedPhoto!) 
                          : (provider.profilePicture != null 
                              ? NetworkImage(provider.profilePicture!) 
                              : null) as ImageProvider?,
                      child: provider.profilePicture == null && selectedPhoto == null
                          ? Icon(Icons.person, size: 50, color: primaryOrange)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: provider.isLoading 
                ? null 
                : () async {
                    try {
                      await provider.updateProfile(
                        name: nameController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        photo: selectedPhoto,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            child: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, ProfileNotifier notifier) {
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureCurrentPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password must be filled';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureNewPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'New password must be filled';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password must be filled';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  notifier.changePassword(
                    context,
                    _currentPasswordController.text,
                    _newPasswordController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryOrange,
      ),
      body: Consumer<ProfileNotifier>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: provider.profilePicture != null
                          ? NetworkImage(provider.profilePicture!)
                          : null,
                      child: provider.profilePicture == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: primaryOrange,
                            )
                          : null,
                    ),
                    if (provider.canUpdateProfile)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (provider.profilePicture != null)
                              IconButton(
                                onPressed: _showDeleteConfirmationDialog,
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                              ),
                            IconButton(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(Icons.camera_alt),
                              color: primaryOrange,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  provider.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.role,
                  style: TextStyle(
                    fontSize: 16,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoItem(Icons.email, 'Email', provider.email),
                _buildInfoItem(Icons.phone, 'Phone', provider.phone),
                _buildInfoItem(Icons.work, 'NIP', provider.nip),
                _buildInfoItem(Icons.location_on, 'Address', provider.address),
                const SizedBox(height: 24),
                if (!provider.canUpdateProfile)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Saat ini Anda tidak diizinkan untuk mengubah profil',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (provider.canUpdateProfile) ...[
                  _buildActionButton(
                    context,
                    Icons.lock_outline,
                    'Change Password',
                    () => _showChangePasswordDialog(context, provider),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    Icons.edit_outlined,
                    'Edit Profile',
                    () => _showEditProfileDialog(context, provider),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryOrange, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: textGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
