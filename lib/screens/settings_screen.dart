import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _partnerNameController = TextEditingController();
  final _partnerEmailController = TextEditingController();
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _loading = false;
  bool _loaded = false;
  bool _editingProfile = false;
  String _partnerStatus = 'Not linked';
  String _savedName = '';
  String _savedEmail = '';

  late final FirebaseFirestore _db;

  @override
  void initState() {
    super.initState();
    _db = FirebaseFirestore.instance;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = widget.user.uid;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final data = doc.data();
    if (data == null) return;
    if (!mounted) return;

    setState(() {
      if (!_loaded) {
        _savedName = (data['name'] as String?) ?? '';
        _savedEmail =
            (data['email'] as String?) ?? (widget.user.email ?? '');
        _nameController.text = _savedName;
        _emailController.text = _savedEmail;
        _partnerNameController.text = (data['partnerName'] as String?) ?? '';
        _partnerEmailController.text = (data['partnerEmail'] as String?) ?? '';
        _loaded = true;
      }
      _darkMode = (data['prefTheme'] as String?) == 'dark';
      _notificationsEnabled = (data['prefNotifications'] as bool?) ?? true;
      final partnerName = (data['partnerName'] as String?) ?? '';
      final partnerUid = data['partnerUid'] as String?;
      _partnerStatus =
          partnerUid == null || partnerUid.isEmpty
              ? 'Not linked'
              : 'Linked with $partnerName';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _partnerNameController.dispose();
    _partnerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Account'),
          const SizedBox(height: 12),
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildPartnerCard(),
          const SizedBox(height: 16),
          _buildSignOutTile(),
          const SizedBox(height: 24),
          _buildSectionTitle('Preferences'),
          const SizedBox(height: 12),
          _buildPreferencesCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Support'),
          const SizedBox(height: 12),
          _buildSupportCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildProfileCard() {
    return _buildCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: _loading ? null : _toggleEditProfile,
                icon: Icon(
                  _editingProfile ? Icons.close : Icons.edit,
                  size: 18,
                ),
                label: Text(_editingProfile ? 'Cancel' : 'Edit details'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Name',
            controller: _nameController,
            readOnly: !_editingProfile,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            readOnly: !_editingProfile,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'User ID',
            initialValue: widget.user.uid,
            readOnly: true,
          ),
          if (_editingProfile) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B7FD8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _loading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Save Profile',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartnerCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Partner Status',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            _partnerStatus,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Partner Name',
            controller: _partnerNameController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Partner Email',
            controller: _partnerEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _showLinkPartnerDialog,
              icon: const Icon(Icons.link),
              label: const Text('Link Partner'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutTile() {
    return _buildCard(
      child: ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Sign out'),
        onTap: _confirmLogout,
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return _buildCard(
      child: Column(
        children: [
          SwitchListTile(
            value: _darkMode,
            onChanged: (value) => _updatePreferences(themeDark: value),
            title: const Text('Dark theme'),
            subtitle: const Text('Light/Dark appearance'),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (value) => _updatePreferences(notifications: value),
            title: const Text('Notifications'),
            subtitle: const Text('Alerts & reminders (future feature)'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy & data controls'),
            subtitle: const Text('Manage your data (placeholder)'),
            onTap: () => _showSnack('Coming soon'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return _buildCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About CoupleCore'),
            onTap: () => _showSnack('CoupleCore v1.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Report a problem'),
            subtitle: const Text('Placeholder'),
            onTap: () => _showSnack('We will add this soon'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      final uid = widget.user.uid;
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final partnerName = _partnerNameController.text.trim();
      final partnerEmail = _partnerEmailController.text.trim();

      if (email.isEmpty) {
        _showSnack('Email cannot be empty');
        return;
      }

      if (email != _savedEmail) {
        await widget.user.updateEmail(email);
      }

      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'partnerName': partnerName,
        'partnerEmail': partnerEmail,
      }, SetOptions(merge: true));

      await widget.user.updateDisplayName(name);

      _savedName = name;
      _savedEmail = email;
      _editingProfile = false;

      setState(() {
        _partnerStatus =
            partnerName.isNotEmpty
                ? 'Linked with $partnerName'
                : _partnerStatus;
      });

      _showSnack('Profile updated');
    } catch (_) {
      _showSnack('Unable to update profile');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleEditProfile() {
    setState(() {
      if (_editingProfile) {
        _nameController.text = _savedName;
        _emailController.text = _savedEmail;
      }
      _editingProfile = !_editingProfile;
    });
  }

  Future<void> _updatePreferences({
    bool? themeDark,
    bool? notifications,
  }) async {
    setState(() {
      if (themeDark != null) _darkMode = themeDark;
      if (notifications != null) _notificationsEnabled = notifications;
    });

    await _db.collection('users').doc(widget.user.uid).set({
      'prefTheme': _darkMode ? 'dark' : 'light',
      'prefNotifications': _notificationsEnabled,
    }, SetOptions(merge: true));
  }

  Future<void> _showLinkPartnerDialog() async {
    final emailController = TextEditingController();
    final uidController = TextEditingController();

    final shouldLink = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Link Partner'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Partner Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: uidController,
                  decoration: const InputDecoration(
                    labelText: 'Partner User ID (optional)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B7FD8),
                ),
                child: const Text(
                  'Link',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (shouldLink != true) return;

    final partnerEmail = emailController.text.trim();
    final partnerUidInput = uidController.text.trim();
    if (partnerEmail.isEmpty) {
      _showSnack('Partner email is required');
      return;
    }

    await _createLinkRequest(
      partnerEmail: partnerEmail,
      partnerUid: partnerUidInput.isEmpty ? null : partnerUidInput,
    );
  }

  Future<void> _createLinkRequest({
    required String partnerEmail,
    String? partnerUid,
  }) async {
    try {
      final fromUid = widget.user.uid;
      final fromEmail = widget.user.email ?? '';
      final fromName =
          _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : (widget.user.displayName ?? 'Someone');

      String? resolvedUid = partnerUid;
      if (resolvedUid == null) {
        final userQuery =
            await _db
                .collection('users')
                .where('email', isEqualTo: partnerEmail)
                .limit(1)
                .get();
        if (userQuery.docs.isNotEmpty) {
          resolvedUid = userQuery.docs.first.id;
        }
      }

      final requestRef = _db.collection('link_requests').doc();
      await requestRef.set({
        'fromUid': fromUid,
        'fromName': fromName,
        'fromEmail': fromEmail,
        'toEmail': partnerEmail,
        'toUid': resolvedUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (resolvedUid != null) {
        await _db.collection('alerts').add({
          'toUid': resolvedUid,
          'fromUid': fromUid,
          'type': 'partner_link_request',
          'message': '$fromName wants to link with you!',
          'requestId': requestRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      _showSnack('Link request sent');
    } catch (_) {
      _showSnack('Failed to send link request');
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Log out?'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B7FD8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
