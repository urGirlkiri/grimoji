const Set<Song> menuSongs = {
  Song('midnight_study.mp3', 'Midnight Study', artist: 'Gemmini'),
  Song('the_mercury_key.mp3', 'The Mercury Key', artist: 'Gemmini'),
  Song('seven_drops_of_mercury.mp3', 'Seven Drops Of Mercury', artist: 'Gemmini'),
  Song('halloween_trap.mp3','Halloween Trap', artist: 'Villatic Music from Pixabay'),
  Song('mystical_halloween.mp3','Mystical Halloween', artist: 'Villatic Music from Pixabay'),
  Song('mysterious_halloween.mp3','Mysterious Halloween', artist: 'TuneTank from Pixabay'),
  Song('halloween.mp3','Halloween', artist: 'TuneTank from Pixabay'),
  Song('halloween_bg.mp3','Halloween Bg', artist: 'viacheslavstarostin from Pixabay'),
};

const Set<Song> levelSongs = {
  Song('clock_work.mp3', 'Clock Work', artist: '???'),
  Song('halloween_piano.mp3','Halloween Piano', artist: 'Tunetank from Pixabay'),
  Song('scary_mansion_halloween.mp3','Scray Mansion', artist: 'Villatic Music from Pixabay'),
  Song('halloween_scary.mp3','Halloween Scary', artist: 'The Mountain from Pixabay'),
  Song('halloween_happy.mp3','Halloween Happy Background', artist: 'Sigma Music Art from Pixabay'),
  Song('halloween_background.mp3','Halloween Background', artist: ' From Pixabay'),
  Song('halloween_bg2.mp3','Halloween Background 2 ', artist: 'Sigma Music Art From Pixabay'),
  Song('halloween_trap.mp3','Halloween Trap', artist: 'Villatic Music from Pixabay'),
  Song('halloween_bg3.mp3','Halloween Background 3 ', artist: 'Hitlab')
};

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
