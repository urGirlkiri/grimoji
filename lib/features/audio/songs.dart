const Set<Song> menuSongs = {
  Song('midnight_study.m4a', 'Midnight Study', artist: 'Gemmini'),
  Song('the_mercury_key.m4a', 'The Mercury Key', artist: 'Gemmini'),
  Song('seven_drops_of_mercury.m4a', 'Seven Drops Of Mercury', artist: 'Gemmini'),
  Song('halloween_trap.m4a','Halloween Trap', artist: 'Villatic Music from Pixabay'),
  Song('mystical_halloween.m4a','Mystical Halloween', artist: 'Villatic Music from Pixabay'),
  Song('mysterious_halloween.m4a','Mysterious Halloween', artist: 'TuneTank from Pixabay'),
  Song('halloween.m4a','Halloween', artist: 'TuneTank from Pixabay'),
  Song('halloween_bg.m4a','Halloween Bg', artist: 'viacheslavstarostin from Pixabay'),
};

const Set<Song> levelSongs = {
  Song('clock_work.m4a', 'Clock Work', artist: '???'),
  Song('halloween_piano.m4a','Halloween Piano', artist: 'Tunetank from Pixabay'),
  Song('scary_mansion_halloween.m4a','Scray Mansion', artist: 'Villatic Music from Pixabay'),
  Song('halloween_scary.m4a','Halloween Scary', artist: 'The Mountain from Pixabay'),
  Song('halloween_happy.m4a','Halloween Happy Background', artist: 'Sigma Music Art from Pixabay'),
  Song('halloween_background.m4a','Halloween Background', artist: ' From Pixabay'),
  Song('halloween_bg2.m4a','Halloween Background 2 ', artist: 'Sigma Music Art From Pixabay'),
  Song('halloween_trap.m4a','Halloween Trap', artist: 'Villatic Music from Pixabay'),
  Song('halloween_bg3.m4a','Halloween Background 3 ', artist: 'Hitlab')
};

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
