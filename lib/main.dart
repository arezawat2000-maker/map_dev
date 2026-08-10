import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MapDevAdminApp());
}

class MapDevAdminApp extends StatelessWidget {
  const MapDevAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAP.DEV Admin',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117), // Dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF58A6FF), // Cyan/Teal accent
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161B22),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF30363D), width: 1),
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF58A6FF),
          secondary: const Color(0xFF3FB950),
          surface: const Color(0xFF161B22),
        ),
      ),
      home: const RequestsPage(),
    );
  }
}

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final _databaseRef = FirebaseDatabase.instance.ref('requests');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAP.DEV REQUESTS'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _databaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Text(
                'No requests found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final requestsList = data.entries.map((e) {
            final value = e.value as Map<dynamic, dynamic>;
            return {
              'id': e.key,
              ...value,
            };
          }).toList();

          // Sort by timestamp descending if available
          requestsList.sort((a, b) {
            final tA = a['timestamp'] ?? '';
            final tB = b['timestamp'] ?? '';
            return tB.compareTo(tA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requestsList.length,
            itemBuilder: (context, index) {
              final req = requestsList[index];
              return RequestCard(request: req);
            },
          );
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final Map<dynamic, dynamic> request;

  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final appName = request['app_name'] ?? 'Unknown App';
    final description = request['app_description'] ?? 'No description provided';
    final requesterName = request['requester_name'] ?? 'Unknown Requester';
    final email = request['contact'] ?? 'No email';
    final phone = request['phone_number'] ?? 'No phone';
    final timestamp = request['timestamp'];

    String formattedDate = '';
    if (timestamp != null) {
      try {
        final date = DateTime.parse(timestamp);
        formattedDate = '${date.toLocal().toString().split('.')[0]}';
      } catch (_) {
        formattedDate = timestamp.toString();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appName.toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58A6FF),
                    ),
                  ),
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description.toString(),
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFF30363D), height: 1),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoSection(
                    icon: Icons.person_outline,
                    label: 'REQUESTER',
                    value: requesterName.toString(),
                  ),
                ),
                Expanded(
                  child: _InfoSection(
                    icon: Icons.email_outlined,
                    label: 'EMAIL',
                    value: email.toString(),
                  ),
                ),
                Expanded(
                  child: _InfoSection(
                    icon: Icons.phone_outlined,
                    label: 'PHONE',
                    value: phone.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoSection({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
