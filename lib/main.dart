// CoupleCore - Modern Login with Partner Details
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

const String kLogoPath = 'assets/images/logo_cc_w.png';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CoupleCoreApp());
}

class CoupleCoreApp extends StatelessWidget {
  const CoupleCoreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoupleCore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B7FD8)),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const AuthScreen();
        return DashboardScreen(user: user);
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _partnerNameController = TextEditingController();
  final _partnerEmailController = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B7FD8),
              const Color(0xFF6B5FD8),
              const Color(0xFF9B8FE8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Container(
                      width: 210,
                      height: 210,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        // color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.12),
                        //     blurRadius: 20,
                        //     offset: const Offset(0, 10),
                        //   ),
                        // ],
                        // border: Border.all(
                        //   color: Colors.white.withOpacity(0.2),
                        //   width: 1,
                        // ),
                      ),
                      child: Image.asset(kLogoPath, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'CoupleCore',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegister ? 'Create your account' : 'Welcome back',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login Form Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (_isRegister) ...[
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Your Name',
                                  icon: Icons.person_outline,
                                  validator:
                                      (val) =>
                                          val?.isEmpty ?? true
                                              ? 'Please enter your name'
                                              : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val?.isEmpty ?? true)
                                    return 'Please enter your email';
                                  if (!val!.contains('@'))
                                    return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                obscureText: true,
                                validator: (val) {
                                  if (val?.isEmpty ?? true)
                                    return 'Please enter your password';
                                  if ((val?.length ?? 0) < 6)
                                    return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),

                              if (_isRegister) ...[
                                const SizedBox(height: 24),
                                Divider(color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'Partner Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  controller: _partnerNameController,
                                  label: "Partner's Name",
                                  icon: Icons.favorite_outline,
                                  validator:
                                      (val) =>
                                          val?.isEmpty ?? true
                                              ? "Please enter your partner's name"
                                              : null,
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  controller: _partnerEmailController,
                                  label: "Partner's Email",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if (val?.isEmpty ?? true)
                                      return "Please enter your partner's email";
                                    if (!val!.contains('@'))
                                      return 'Please enter a valid email';
                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(height: 32),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child:
                                    _loading
                                        ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : ElevatedButton(
                                          onPressed: _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF8B7FD8,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            _isRegister
                                                ? 'Create Account'
                                                : 'Sign In',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Toggle Sign In/Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRegister
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () => setState(() => _isRegister = !_isRegister),
                          child: Text(
                            _isRegister ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF8B7FD8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B7FD8), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;

      if (_isRegister) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );
        final user = cred.user!;
        final name = _nameController.text.trim();
        await user.updateDisplayName(name);

        final uid = user.uid;
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        await userDoc.set({
          'email': email,
          'name': name,
          'partnerName': _partnerNameController.text.trim(),
          'partnerEmail': _partnerEmailController.text.trim(),
        }, SetOptions(merge: true));
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Authentication error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class DashboardScreen extends StatefulWidget {
  final User user;
  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String partnerMood = '—';
  String myMood = '—';
  String? partnerUid;
  late final FirebaseFirestore _db;
  StreamSubscription? _myMoodSub;
  StreamSubscription? _userDocSub;
  StreamSubscription? _partnerMoodSub;
  String userName = 'User';
  String partnerName = 'Partner';

  @override
  void initState() {
    super.initState();
    _db = FirebaseFirestore.instance;
    _listenToProfileAndMoods();
  }

  void _listenToProfileAndMoods() {
    final user = widget.user;
    final uid = user.uid;
    final userDoc = _db.collection('users').doc(uid);

    userDoc.set({'email': user.email}, SetOptions(merge: true));

    _myMoodSub = _db.collection('moods').doc(uid).snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data();
      if (data == null) return;
      if (!mounted) return;
      setState(() => myMood = (data['mood'] as String?) ?? myMood);
    });

    _userDocSub = userDoc.snapshots().listen((snap) async {
      if (!snap.exists) return;
      final data = snap.data();
      if (data == null) return;

      // Update user's own name
      if (mounted) {
        setState(() {
          userName =
              data['name'] as String? ?? widget.user.displayName ?? 'User';
          partnerName = data['partnerName'] as String? ?? 'Partner';
        });
      }

      final pUid = data['partnerUid'] as String?;
      final pEmail = data['partnerEmail'] as String?;

      if (pUid != null && pUid != partnerUid) {
        partnerUid = pUid;
        _subscribeToPartnerMood();
      } else if (pUid == null && pEmail != null) {
        final q =
            await _db
                .collection('users')
                .where('email', isEqualTo: pEmail)
                .limit(1)
                .get();
        if (q.docs.isNotEmpty) {
          final found = q.docs.first.id;
          await userDoc.set({'partnerUid': found}, SetOptions(merge: true));
          partnerUid = found;
          _subscribeToPartnerMood();
        }
      }
    });
  }

  void _subscribeToPartnerMood() {
    _partnerMoodSub?.cancel();
    final p = partnerUid;
    if (p == null) return;

    _partnerMoodSub = _db.collection('moods').doc(p).snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data();
      if (data == null) return;
      if (!mounted) return;
      setState(() => partnerMood = (data['mood'] as String?) ?? partnerMood);
    });
  }

  @override
  void dispose() {
    _myMoodSub?.cancel();
    _userDocSub?.cancel();
    _partnerMoodSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B7FD8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildMoodSection(),
                      const SizedBox(height: 24),
                      _buildFeatureGrid(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEmergencyDialog,
        backgroundColor: const Color(0xFF8B7FD8),
        child: const Icon(Icons.favorite, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final monthDay = DateFormat('MMMM d').format(now);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $userName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    monthDay.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    FirebaseAuth.instance.signOut();
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(kLogoPath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPartnerMood(
                  name: userName,
                  mood: myMood,
                  icon: Icons.sentiment_satisfied_alt,
                  onTap: () => _showMoodPicker(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPartnerMood(
                  name: partnerName,
                  mood: partnerMood,
                  icon: Icons.sentiment_satisfied_alt,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerMood({
    required String name,
    required String mood,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF8B7FD8)),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B7FD8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mood.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildFeatureCard(
            'Shared Calendar',
            Icons.calendar_today,
            const Color(0xFFFFEBEE),
            const Color(0xFFE91E63),
          ),
          _buildFeatureCard(
            'Memories',
            Icons.photo_album,
            const Color(0xFFFFF3E0),
            const Color(0xFFFF9800),
          ),
          _buildFeatureCard(
            'Messages',
            Icons.chat_bubble,
            const Color(0xFFE8F5E9),
            const Color(0xFF4CAF50),
          ),
          _buildFeatureCard(
            'Good Deeds',
            Icons.star,
            const Color(0xFFF3E5F5),
            const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap:
          () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Opening $title...'))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.timeline, 'Timeline', 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.notifications, 'Alerts', 2),
              _buildNavItem(Icons.settings, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF8B7FD8) : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF8B7FD8) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodPicker(bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'How are you feeling?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _moodOption('😊', 'Happy', isMe),
                    _moodOption('😐', 'Neutral', isMe),
                    _moodOption('😔', 'Sad', isMe),
                    _moodOption('😰', 'Stressed', isMe),
                    _moodOption('😍', 'Loved', isMe),
                    _moodOption('😤', 'Frustrated', isMe),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _moodOption(String emoji, String label, bool isMe) {
    return GestureDetector(
      onTap: () => _handleMoodSelection(label.toLowerCase(), isMe),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Future<void> _handleMoodSelection(String mood, bool isMe) async {
    final uid = widget.user.uid;
    if (isMe) {
      setState(() => myMood = mood);
      await _db.collection('moods').doc(uid).set({
        'mood': mood,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      if (partnerUid != null) {
        await _db.collection('moods').doc(partnerUid).set({
          'mood': mood,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      setState(() => partnerMood = mood);
    }
    if (mounted) Navigator.pop(context);
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Emergency Alert'),
            content: const Text(
              'Send an emergency notification to your partner?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _sendEmergencyNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B7FD8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _sendEmergencyNotification() async {
    final uid = widget.user.uid;
    final doc = _db.collection('users').doc(uid);
    final snap = await doc.get();
    String? pUid = snap.data()?['partnerUid'] as String?;
    if (pUid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No partner linked to send emergency')),
        );
      }
      Navigator.pop(context);
      return;
    }
    await _db.collection('alerts').add({
      'from': uid,
      'to': pUid,
      'type': 'emergency',
      'message': 'Emergency alert from your partner',
      'timestamp': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency notification sent to partner'),
          backgroundColor: Color(0xFF8B7FD8),
        ),
      );
    }
  }
}
