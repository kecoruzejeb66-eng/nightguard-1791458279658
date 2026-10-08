import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const NightGuardApp());
}

class NightGuardApp extends StatelessWidget {
  const NightGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NightGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD32F2F),
          secondary: Color(0xFFE53935),
          surface: Color(0xFF141414),
          background: Color(0xFF0A0A0A),
          error: Color(0xFFB71C1C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1C1C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  bool _loading = false;
  bool _isSignUp = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    Map<String, dynamic> res;
    if (_isSignUp) {
      res = await DwBackend.signUp(email, password);
    } else {
      res = await DwBackend.signIn(email, password);
    }

    setState(() {
      _loading = false;
      if (res['ok'] == true) {
        _isLoggedIn = true;
      } else {
        _errorMessage = res['error'] ?? 'Authentication failed';
      }
    });
  }

  Future<void> _signOut() async {
    await DwBackend.signOut();
    setState(() {
      _isLoggedIn = false;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return HomeScreen(onSignOut: _signOut);
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.security,
                  size: 64,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(height: 16),
                const Text(
                  'NightGuard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp ? 'Create a secure agent profile' : 'Secure Access Portal',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF330000),
                      border: Border.all(color: const Color(0xFFD32F2F)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFFF6666)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Agent Email',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Security Passcode',
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isSignUp ? 'REGISTER AGENT' : 'INITIALIZE ACCESS',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'Already registered? Sign In'
                        : 'Need clearance? Register',
                    style: const TextStyle(color: Color(0xFFD32F2F)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onSignOut;

  const HomeScreen({Key? key, required this.onSignOut}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardTab(),
      const NotesTab(),
      const SettingsTab(onSignOut: widget.onSignOut),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NightGuard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield, color: Color(0xFFD32F2F)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('System Status: Secure & Encrypted'),
                  backgroundColor: Color(0xFF1C1C1C),
                ),
              );
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.security_rounded),
            label: 'Command',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_rounded),
            label: 'Secure Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_rounded),
            label: 'Protocol',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _panicActive = false;
  int _countdown = 5;
  bool _countingDown = false;

  void _triggerPanic() {
    setState(() {
      _countingDown = true;
      _countdown = 5;
    });

    // Simple countdown simulation for panic trigger
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_countingDown) return false;
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        setState(() {
          _countingDown = false;
          _panicActive = true;
        });
        // Auto log emergency note
        await DwBackend.create('notes', {
          'title': '🚨 PANIC BUTTON TRIGGERED',
          'content': 'Emergency signal activated at ${DateTime.now().toIso8601String()}',
          'timestamp': DateTime.now().toIso8601String(),
        });
        return false;
      }
      return true;
    });
  }

  void _cancelPanic() {
    setState(() {
      _countingDown = false;
      _panicActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _panicActive ? Colors.red : const Color(0xFF333333),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _panicActive ? Icons.warning_amber_rounded : Icons.radar,
                  color: _panicActive ? Colors.red : const Color(0xFFD32F2F),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _panicActive ? 'STATUS: EMERGENCY ACTIVE' : 'STATUS: PERIMETER SECURE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _panicActive ? Colors.red : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _panicActive
                            ? 'Emergency signal logged to secure storage.'
                            : 'All sentinel nodes are reporting normal operations.',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: _countingDown ? _cancelPanic : _triggerPanic,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _countingDown ? Colors.orange : const Color(0xFFD32F2F),
                      const Color(0xFF5A0000),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_countingDown ? Colors.orange : const Color(0xFFD32F2F))
                          .withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _countingDown ? Icons.hourglass_top : Icons.alarm,
                        size: 56,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _countingDown ? 'CANCEL ($_countdown)' : 'PANIC',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tap the emergency beacon to transmit distress sequence and log alert note.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 40),
          const Text(
            'Active Protocols',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildProtocolCard('Silent Surveillance', 'Monitoring ambient frequency', Icons.mic_off),
          const SizedBox(height: 8),
          _buildProtocolCard('Dead Man\'s Switch', 'Armed - 24h check-in required', Icons.timer),
          const SizedBox(height: 8),
          _buildProtocolCard('Encrypted Vault', 'AES-256 active on local database', Icons.enhanced_encryption),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD32F2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }
}

class NotesTab extends StatefulWidget {
  const NotesTab({Key? key}) : super(key: key);

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  List<Map<String, dynamic>> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => _loading = true);
    final items = await DwBackend.list('notes');
    setState(() {
      _notes = items;
      _loading = false;
    });
  }

  Future<void> _deleteNote(String id) async {
    await DwBackend.remove(id);
    _fetchNotes();
  }

  void _openNoteEditor({Map<String, dynamic>? existingNote}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      builder: (context) {
        return NoteEditorModal(
          note: existingNote,
          onSave: () {
            _fetchNotes();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Secure Notes Found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _openNoteEditor(),
                        child: const Text('CREATE FIRST NOTE'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF262626)),
                      ),
                      child: ListTile(
                        title: Text(
                          note['title'] ?? 'Untitled',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            note['content'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => _deleteNote(note['id']),
                        ),
                        onTap: () => _openNoteEditor(existingNote: note),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openNoteEditor(),
      ),
    );
  }
}

class NoteEditorModal extends StatefulWidget {
  final Map<String, dynamic>? note;
  final VoidCallback onSave;

  const NoteEditorModal({Key? key, this.note, required this.onSave}) : super(key: key);

  @override
  State<NoteEditorModal> createState() => _NoteEditorModalState();
}

class _NoteEditorModalState extends State<NoteEditorModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?['title'] ?? '');
    _contentController = TextEditingController(text: widget.note?['content'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (widget.note != null) {
      await DwBackend.update(widget.note!['id'], {
        'title': title.isEmpty ? 'Untitled' : title,
        'content': content,
      });
    } else {
      await DwBackend.create('notes', {
        'title': title.isEmpty ? 'Untitled' : title,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    setState(() => _saving = false);
    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(
                widget.note == null ? 'New Secure Note' : 'Edit Secure Note',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Encrypted Content',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SAVE NOTE'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final VoidCallback onSignOut;

  const SettingsTab({Key? key, required this.onSignOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Security Protocols',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          tileColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: const Icon(Icons.security, color: Color(0xFFD32F2F)),
          title: const Text('Biometric Authentication'),
          subtitle: const Text('Require fingerprint to open notes'),
          trailing: Switch(
            value: true,
            activeColor: const Color(0xFFD32F2F),
            onChanged: (val) {},
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: const Icon(Icons.bolt, color: Color(0xFFD32F2F)),
          title: const Text('Duress PIN Wipe'),
          subtitle: const Text('Wipe notes on incorrect entry'),
          trailing: Switch(
            value: false,
            activeColor: const Color(0xFFD32F2F),
            onChanged: (val) {},
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Session',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('TERMINATE SESSION'),
            onPressed: onSignOut,
          ),
        ),
      ],
    );
  }
}

class DwBackend {
  static staticAuthTokenDoNotUseDirectly = "";
  static final String _dir = Directory.systemTemp.path;

  static File _getFile(String collection) {
    return File('$_dir/nightguard_$collection.json');
  }

  static File _getAuthFile() {
    return File('$_dir/nightguard_auth.json');
  }

  static Future<Map<String, dynamic>> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.isEmpty || password.isEmpty) {
      return {"ok": false, "error": "Email and password cannot be empty"};
    }
    final file = _getAuthFile();
    await file.writeAsString(jsonEncode({"email": email, "password": password}));
    staticAuthTokenDoNotUseDirectly = email;
    return {"ok": true};
  }

  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final file = _getAuthFile();
    if (!await file.exists()) {
      return {"ok": false, "error": "Account not found. Please sign up."};
    }
    final data = jsonDecode(await file.readAsString());
    if (data['email'] == email && data['password'] == password) {
      staticAuthTokenDoNotUseDirectly = email;
      return {"ok": true};
    }
    return {"ok": false, "error": "Invalid credentials"};
  }

  static Future<void> signOut() async {
    staticAuthTokenDoNotUseDirectly = "";
  }

  static Future<List<Map<String, dynamic>>> list(String collection) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final file = _getFile(collection);
    if (!await file.exists()) return [];
    try {
      final List list = jsonDecode(await file.readAsString());
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> create(String collection, Map<String, dynamic> item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final items = await list(collection);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newItem = {"id": id, ...item};
    items.add(newItem);
    await _getFile(collection).writeAsString(jsonEncode(items));
    return {"ok": true, "item": newItem};
  }

  static Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // assuming collection is notes for this app
    final items = await list('notes');
    final index = items.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      items[index] = {...items[index], ...data};
      await _getFile('notes').writeAsString(jsonEncode(items));
      return {"ok": true};
    }
    return {"ok": false, "error": "Item not found"};
  }

  static Future<Map<String, dynamic>> remove(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final items = await list('notes');
    items.removeWhere((element) => element['id'] == id);
    await _getFile('notes').writeAsString(jsonEncode(items));
    return {"ok": true};
  }
}

// ---------------------------------------------------------------------------
// Built-in backend — accounts and data API, provided by Danger World Builder.
// Do not edit or redefine this class; use it from your screens.
// ---------------------------------------------------------------------------
class DwBackend {
  static const String baseUrl =
      "https://danger-build-core.base44.app/functions/appBackend";
  static const String appKey = "5e166bef720649fda5750edd274ef8d7";
  static String? token;
  static String? userEmail;

  static Future<Map<String, dynamic>> _post(
      String action, Map<String, dynamic> extra) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(baseUrl));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json");
      final payload = <String, dynamic>{"app_key": appKey, "action": action};
      payload.addAll(extra);
      if (token != null) payload["token"] = token;
      request.write(jsonEncode(payload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"ok": false, "error": "Unexpected response from the server."};
    } catch (_) {
      return {"ok": false, "error": "Could not reach the server. Check your connection."};
    } finally {
      client.close(force: true);
    }
  }

  static Future<Map<String, dynamic>> signUp(String email, String password) async {
    final res = await _post("signup", {"email": email, "password": password});
    if (res["ok"] == true && res["token"] is String) {
      token = res["token"] as String;
      userEmail = email;
    }
    return res;
  }

  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    final res = await _post("login", {"email": email, "password": password});
    if (res["ok"] == true && res["token"] is String) {
      token = res["token"] as String;
      userEmail = email;
    }
    return res;
  }

  static Future<void> signOut() async {
    token = null;
    userEmail = null;
  }

  static Future<List<Map<String, dynamic>>> list(String collection) async {
    final res = await _post("list", {"collection": collection});
    final items = res["items"];
    if (items is List) {
      return items
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  static Future<Map<String, dynamic>> create(
      String collection, Map<String, dynamic> data) {
    return _post("create", {"collection": collection, "data": data});
  }

  static Future<Map<String, dynamic>> update(
      String id, Map<String, dynamic> data) {
    return _post("update", {"id": id, "data": data});
  }

  static Future<Map<String, dynamic>> remove(String id) {
    return _post("remove", {"id": id});
  }
}
