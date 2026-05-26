const Set<Song> backgroundSongs = {
  Song('goth_piano.mp3', 'Piano', artist: 'Gemmini'),
  Song('midnight_study.mp3', 'Midnight Study', artist: 'Gemmini'),
  Song('the_mercury_key.mp3', 'The Mercury Key', artist: 'Gemmini'),
  Song('seven_drops_of_mercury.mp3', 'Seven Drops Of Mercury', artist: 'Gemmini'),
};

const Set<Song> levelSongs = {

};

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
