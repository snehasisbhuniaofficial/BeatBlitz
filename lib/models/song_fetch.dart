class Song {
  final String id;
  final String title;
  final String singer;
  final String genre;
  final String duration;
  final String filepath;
  final String image;
  final String lyrics;

  Song(
      {required this.id,
      required this.title,
      required this.singer,
      required this.genre,
      required this.duration,
      required this.filepath,
      required this.image,
      required this.lyrics});
}
