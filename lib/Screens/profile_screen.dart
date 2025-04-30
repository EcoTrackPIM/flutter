import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'loginScreen.dart';
import 'settingsScreen.dart';
import '../Api/authApi.dart';
import '../Screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  String _userName = 'User';
  String _userBio = 'Eco-conscious fashion lover';
  bool _isLoading = true;
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      final userData = await _apiService.getUserProfile();
      if (userData['profileImage'] != null) {
        setState(() => _profileImageUrl = userData['profileImage']);
      }
      setState(() {
        _userName = userData['name'] ?? 'User';
        _userBio = userData['bio'] ?? 'Eco-conscious fashion lover';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
          _isLoading = true;
        });

        final response = await _apiService.uploadProfileImage(_profileImage!);
        await _apiService.updateProfile(profileImage: response['imageUrl']);
        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile image: $e')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'rememberMe');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'userName');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D8B6F),
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ProfileHeader(
              name: _userName,
              bio: _userBio,
              profileImage: _profileImage,
              profileImageUrl: _profileImageUrl,
              onImageTap: _pickAndUploadImage,
            ),
            const SizedBox(height: 24),
            _ProfileStats(),
            const SizedBox(height: 32),
            _ProfileMenu(
              onEditProfile: () async {
                try {
                  final userData = await _apiService.getUserProfile();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(userData: userData),
                    ),
                  );
                  if (result == true) _loadUserData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load profile: $e')),
                  );
                }
              },
              onLogout: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String bio;
  final File? profileImage;
  final String? profileImageUrl;
  final VoidCallback onImageTap;

  const _ProfileHeader({
    required this.name,
    required this.bio,
    required this.onImageTap,
    this.profileImage,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onImageTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4D8B6F),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _buildProfileImage(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bio,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (profileImage != null) {
      return Image.file(profileImage!, fit: BoxFit.cover);
    } else if (profileImageUrl != null) {
      return Image.network(profileImageUrl!, fit: BoxFit.cover);
    } else {
      return Image.asset(
        'assets/profile_placeholder.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person,
          size: 60,
          color: Colors.grey.shade400,
        ),
      );
    }
  }
}

class _ProfileStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '24', label: 'Scans'),
          _StatItem(value: '8.7', label: 'Avg. Score'),
          _StatItem(value: '15%', label: 'Impact'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const _ProfileMenu({
    required this.onEditProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.history,
            title: 'Scan History',
            onTap: () {},
          ),
          const Divider(height: 1),
          _MenuTile(
            icon: Icons.favorite_border,
            title: 'Saved Items',
            onTap: () {},
          ),
          const Divider(height: 1),
          _MenuTile(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: onEditProfile,
          ),
          const Divider(height: 1),
          _MenuTile(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Divider(height: 1),
          _MenuTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF338C5E)),
      title: Text(title),
      onTap: onTap,
    );
  }
}
