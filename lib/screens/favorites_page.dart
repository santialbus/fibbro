import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/domain/artists_domain.dart';
import 'package:myapp/services/artist_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/notification_storage_service.dart';
import 'package:myapp/utils/app_logger.dart';
import 'package:myapp/utils/artist_overlap_utils.dart';
import 'package:myapp/utils/date_utils.dart';
import 'package:myapp/widgets/snackbar_helper.dart';

import '../widgets/artist_favorite_card.dart';
import '../services/favorite_service.dart';

class FavoritesPage extends StatefulWidget {
  final String festivalId;
  final List<String> dates;

  const FavoritesPage({
    super.key,
    required this.festivalId,
    required this.dates,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  late final String _festivalId;
  late final String _userId;
  late final List<String> _dates;

  List<FestivalArtistDomain> favoriteArtists = [];
  bool isLoading = true;

  final List<String> _availableDates = [
    '2025-07-17',
    '2025-07-18',
    '2025-07-19',
  ];
  int _currentDateIndex = 0;

  bool get isFib => _festivalId == '0e79d8ae-8c29-4f8e-a2bb-3a1eae9d2a77';

  @override
  void initState() {
    super.initState();
    AppLogger.page('FavoritesPage');
    _festivalId = widget.festivalId;
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _dates = widget.dates;
    loadFavorites();
  }

  List<String> getDates() {
    List<String> dates = isFib ? _availableDates : _dates;
    return dates.map(DateUtilsHelper.normalizeDateNew).toList();
  }

  Future<void> loadFavorites() async {
    if (_userId.isEmpty) {
      setState(() {
        favoriteArtists = [];
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final favoriteIds = await _favoriteService.getFavoriteArtistIdsForUser(
        userId: _userId,
        festivalId: _festivalId,
      );

      final allArtists = await ArtistService.getArtistsByIds(
        artistIds: favoriteIds,
        festivalId: _festivalId,
      );

      final filtered =
          allArtists
              .where((artist) => favoriteIds.contains(artist.id))
              .toList();

      filtered.sort((a, b) {
        final dateCompare = a.festivalDate.compareTo(b.festivalDate);
        if (dateCompare != 0) return dateCompare;

        int parseTime(String? time) {
          if (time == null) return 9999;
          final parts = time.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          if (hour < 6) hour += 24;
          return hour * 60 + minute;
        }

        return parseTime(a.startTime) - parseTime(b.startTime);
      });

      setState(() {
        favoriteArtists = filtered;
        isLoading = false;
      });

      final notificationService = NotificationService();
      final storageService = NotificationStorageService();

      for (final artist in favoriteArtists) {
        try {
          final wasScheduled = await notificationService.scheduleIfNotExists(
            artist,
          );

          if (wasScheduled) {
            await storageService.addUnread(artist.id);
          }
        } catch (e) {}
      }
    } catch (e, st) {
      print('Error en loadFavorites: $e');
      print(st);
      setState(() {
        isLoading = false;
        favoriteArtists = [];
      });
    }
  }

  void _changeDate(int newIndex) {
    setState(() {
      _currentDateIndex = newIndex;
    });
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = getDates()[_currentDateIndex];
    final artistsOfDay =
        favoriteArtists.where((a) => a.festivalDate == currentDate).toList();
    final solapadosMap = ArtistOverlapUtils.artistasSolapados(artistsOfDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos'), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteArtists.isEmpty
              ? const Center(child: Text('Aún no has añadido favoritos'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed:
                              _currentDateIndex > 0
                                  ? () => _changeDate(_currentDateIndex - 1)
                                  : null,
                        ),
                        Text(
                          DateUtilsHelper.formatFullDate(currentDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              _currentDateIndex < getDates().length - 1
                                  ? () => _changeDate(_currentDateIndex + 1)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: artistsOfDay.length,
                      itemBuilder: (context, index) {
                        final artist = artistsOfDay[index];
                        final overlappingIds = solapadosMap[artist.id] ?? [];
                        final overlappingArtists =
                            overlappingIds
                                .map(
                                  (id) => artistsOfDay.firstWhere(
                                    (a) => a.id == id,
                                  ),
                                )
                                .toList();

                        return ArtistFavoriteCard(
                          artist: artist,
                          initiallyFavorite: true,
                          showAlert: overlappingArtists.isNotEmpty,
                          overlappingArtists: overlappingArtists,
                          onFavoriteChanged: (isFav) async {
                            await _favoriteService.toggleFavorite(
                              artistId: artist.id,
                              festivalId: _festivalId,
                            );
                            if (!isFav) {
                              final notificationService = NotificationService();
                              await notificationService.cancelNotification(
                                artist.id,
                              );
                              SnackBarHelper.showStyledSnackBar(
                                context,
                                message: 'Quitado de favoritos: ${artist.name}',
                                isSuccess: false,
                              );
                            }
                            loadFavorites();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
