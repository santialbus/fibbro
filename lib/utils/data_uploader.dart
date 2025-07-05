/*

Future<void> uploadArtistsFromJson() async {
  final firestore = FirebaseFirestore.instance;

  // Leer el archivo JSON desde assets
  final String jsonString = await rootBundle.loadString(
    'assets/docs/artistsZevra.json',
  );
  final List<dynamic> data = json.decode(jsonString);

  // Subir cada artista a Firestore
  for (var item in data) {
    await firestore.collection('artists').doc(item['id']).set(item);
  }

  print('✅ Datos subidos correctamente a Firestore.');
}

Future<void> associateArtistsToFestival() async {
  final firestore = FirebaseFirestore.instance;

  // Leer el JSON local de artistas (no se suben, solo se usan para extraer IDs)
  final String jsonString = await rootBundle.loadString(
    'assets/docs/artistsZevra.json',
  );
  final List<dynamic> data = json.decode(jsonString);

  // Extraer los IDs
  final List<String> artistIds =
      data.map((artist) => artist['id'] as String).toList();
  print(artistIds);
  // Asociar esos IDs al festival
  await firestore.collection('festivales').doc('7ZALOSvVWAD0bVVE9ZNV').update({
    'artistIds': FieldValue.arrayUnion(artistIds),
  });

  print('✅ Artist IDs asociados al festival Zevra');
}
*/
