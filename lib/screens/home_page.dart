import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/festival_page.dart';
import 'package:myapp/services/festival_follor_service.dart';
import 'package:myapp/services/festival_service.dart';
import 'package:myapp/services/notification_storage_service.dart';
import 'package:myapp/utils/app_logger.dart';
import 'package:myapp/utils/notification_helper.dart';
import 'package:myapp/widgets/festival_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FestivalService _festivalService = FestivalService();
  final FestivalFollowService _followService = FestivalFollowService();

  final Map<String, bool> _followingStatus = {};

  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  String _searchQuery = '';

  Stream<QuerySnapshot<Map<String, dynamic>>> _festivalsStream() {
    return _festivalService.getFestivalsStream();
  }

  @override
  void initState() {
    super.initState();
    AppLogger.page('HomePage');
    Future.delayed(Duration.zero, () {
      NotificationHelper.checkNotificationStatus(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowStatusForFestival(String festivalId) async {
    final isFollowing = await _followService.isFollowing(festivalId);
    setState(() {
      _followingStatus[festivalId] = isFollowing;
    });
  }

  Future<void> _toggleFollow(String festivalId) async {
    await _followService.toggleFestivalFollow(festivalId);
    await _loadFollowStatusForFestival(festivalId);
  }

  List<DocumentSnapshot<Map<String, dynamic>>> _filteredDocs(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (_searchQuery.isEmpty) return docs;

    final query = _searchQuery.toLowerCase();

    return docs.where((doc) {
      final data = doc.data();
      if (data == null) return false;

      final name = (data['name'] ?? '').toString().toLowerCase();
      final city = (data['ciudad'] ?? '').toString().toLowerCase();
      final country = (data['pais'] ?? '').toString().toLowerCase();
      final genres =
          List<String>.from(
            data['genres'] ?? [],
          ).map((g) => g.toLowerCase()).toList();

      return name.contains(query) ||
          city.contains(query) ||
          country.contains(query) ||
          genres.any((g) => g.contains(query));
    }).toList();
  }

  Widget _buildFestivalCard(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final festivalId = doc.id;

    // Si no tenemos estado de seguimiento, lo cargamos
    if (!_followingStatus.containsKey(festivalId)) {
      _loadFollowStatusForFestival(festivalId);
      // Mientras carga, asumimos false
      _followingStatus[festivalId] = false;
    }

    return FestivalCard(
      name: (data['name'] ?? '').toString(),
      year: (data['year'] ?? '').toString(),
      dates: List<String>.from(data['date'] ?? []),
      city: (data['ciudad'] ?? '').toString(),
      country: (data['pais'] ?? '').toString(),
      stageNames: List<String>.from(data['stages'] ?? []),
      imageUrl: data['imageUrl'],
      followersCount: data['followersCount'],
      genres: List<String>.from(data['genres'] ?? []),
      hasMap: (data['mapUrl'] ?? '').toString().isNotEmpty,
      isFollowing: _followingStatus[festivalId] ?? false,
      onToggleFollow: () => _toggleFollow(festivalId),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FestivalPage(
                  festivalId: festivalId,
                  festivalName: (data['name'] ?? '').toString(),
                  stageNames: List<String>.from(data['stages']),
                  dates: List<String>.from(data['date']),
                ),
          ),
        );
      },
      onGenreTap: (genre) {
        setState(() {
          _isSearching = true;
          _searchQuery = genre;
          _searchController.text = genre;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar festivales...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
                : const Text('onStagee'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = '';
              });
            },
          ),
          FutureBuilder<int>(
            future: NotificationStorageService().getUnreadCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications').then((
                        _,
                      ) async {
                        await NotificationStorageService().markAllAsRead();
                        setState(() {});
                      });
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _festivalsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar festivales'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = _filteredDocs(snapshot.data?.docs ?? []);

          if (docs.isEmpty) {
            return const Center(child: Text('No hay festivales disponibles.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder:
                (context, index) => _buildFestivalCard(context, docs[index]),
          );
        },
      ),
    );
  }
}
