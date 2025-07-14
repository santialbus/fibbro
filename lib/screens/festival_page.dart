import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/festival_map_page.dart';
import 'package:myapp/screens/state_page.dart';
import 'package:myapp/widgets/draggable_favorite_button.dart';
import 'package:myapp/screens/south_beach_page.dart';
import 'package:myapp/screens/heineken_stage_page.dart';
import 'package:myapp/screens/cutty_shark_page.dart';
import 'package:myapp/screens/repsol_page.dart';
import 'package:myapp/screens/rising_stars_page.dart';

class FestivalPage extends StatefulWidget {
  final String festivalId;
  final String festivalName;
  final List<String> stageNames;
  final List<String> dates;

  const FestivalPage({
    super.key,
    required this.festivalId,
    required this.festivalName,
    required this.stageNames,
    required this.dates,
  });

  @override
  State<FestivalPage> createState() => _FestivalPageState();
}

class _FestivalPageState extends State<FestivalPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  bool get isFib => widget.festivalName.toLowerCase() == 'fib';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.stageNames.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _buildPages() {
    if (isFib) {
      return const [
        HeinekenStagePage(),
        RepsolPage(),
        RisingStarsPage(),
        CuttySharkPage(),
        SouthBeachPage(),
      ];
    } else {
      return widget.stageNames.map((stage) {
        return StagePage(
          key: ValueKey(stage),
          stageName: stage,
          dates: widget.dates,
          festivalId: widget.festivalId,
        );
      }).toList();
    }
  }

  Future<bool> hasMapForFestival(String festivalId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('festivales')
            .doc(festivalId)
            .get();

    return doc.exists &&
        doc.data() != null &&
        doc.data()!.containsKey('mapUrl') &&
        (doc.data()!['mapUrl'] as String).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: FutureBuilder<bool>(
          future: hasMapForFestival(widget.festivalId),
          builder: (context, snapshot) {
            final hasMap = snapshot.data ?? false;

            return AppBar(
              title: Text(widget.festivalName),
              centerTitle: true,
              actions: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (hasMap)
                  IconButton(
                    icon: const Icon(Icons.map_outlined),
                    tooltip: 'Ver mapa del recinto',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FestivalMapPage(
                                festivalId: widget.festivalId,
                              ),
                        ),
                      );
                    },
                  )
                else
                  const Tooltip(
                    message: 'Mapa aún no disponible',
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.map_outlined, color: Colors.grey),
                    ),
                  ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs:
                    widget.stageNames.map((stage) => Tab(text: stage)).toList(),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          TabBarView(controller: _tabController, children: _buildPages()),
          DraggableFavoriteButton(
            festivalId: widget.festivalId,
            dates: widget.dates,
          ),
        ],
      ),
    );
  }
}
