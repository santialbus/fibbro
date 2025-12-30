import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/domain/artists_domain.dart';
import 'package:myapp/services/favorite_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/artist_service.dart';
import 'package:myapp/utils/app_logger.dart';
import 'package:myapp/widgets/artist_card.dart';
import 'package:myapp/widgets/stage_app_bar.dart';
import 'package:myapp/widgets/snackbar_helper.dart';

class StagePage extends StatefulWidget {
  final String festivalId;
  final String stageName;
  final List<String> dates;

  const StagePage({
    super.key,
    required this.festivalId,
    required this.stageName,
    required this.dates,
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  final FavoriteService _favoriteService = FavoriteService();
  final NotificationService _notificationService = NotificationService();

  List<FestivalArtistDomain> _artists = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  int _currentDateIndex = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.page('StatePage');
    _fetchArtists();
  }

  Future<void> _fetchArtists() async {
    setState(() => _isLoading = true);
    final box = Hive.box('festivalCache');
    final cacheKey =
        '${widget.festivalId}_${widget.stageName}_${widget.dates[_currentDateIndex]}';

    try {
      final currentDate = widget.dates[_currentDateIndex];
      final artists = await ArtistService.getArtistsForStageNew(
        festivalId: widget.festivalId,
        stage: widget.stageName,
        festivalDate: currentDate,
      );

      // Guardar en caché como JSON string
      //box.put(cacheKey, Artist.listToJson(artists));

      final favs = await _favoriteService.getFavoritesForFestival(
        widget.festivalId,
      );
      final favIds = favs.map((doc) => doc['artistId'] as String).toSet();

      setState(() {
        _artists = artists;
        _favoriteIds = favIds;
        _isLoading = false;
      });
    } catch (e) {
      // Intentar cargar desde cache si falla
      
    /*final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        setState(() {
          _artists = Artist.listFromJson(cachedData);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }*/
    }
  }

  void _changeDate(int newIndex) {
    setState(() => _currentDateIndex = newIndex);
    _fetchArtists();
  }

  Future<void> _handleFavoriteChange(FestivalArtistDomain artist, bool isNowFav) async {
    await _favoriteService.toggleFavorite(
      festivalId: widget.festivalId,
      artistId: artist.id,
    );

    if (isNowFav) {
      await _notificationService.scheduleIfNotExists(artist);
      SnackBarHelper.showStyledSnackBar(
        context,
        message: 'Añadido a favoritos: ${artist.name}',
        isSuccess: true,
      );
      _favoriteIds.add(artist.id);
    } else {
      await _notificationService.cancelNotification(artist.id);
      SnackBarHelper.showStyledSnackBar(
        context,
        message: 'Quitado de favoritos: ${artist.name}',
        isSuccess: false,
      );
      _favoriteIds.remove(artist.id);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StageAppBar(
        stage: widget.stageName,
        dates: widget.dates,
        currentIndex: _currentDateIndex,
        onDateChanged: _changeDate,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _artists.isEmpty
              ? const Center(child: Text('No hay artistas disponibles.'))
              : ListView.builder(
                itemCount: _artists.length,
                itemBuilder: (context, index) {
                  final artist = _artists[index];
                  final isFav = _favoriteIds.contains(artist.id);

                  return ArtistCard(
                    artist: artist,
                    initiallyFavorite: isFav,
                    onFavoriteChanged:
                        (val) => _handleFavoriteChange(artist, val),
                  );
                },
              ),
    );
  }
}
