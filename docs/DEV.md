# Local Development

## Audio

### Add Assets

Add .wav or .mp3 to assets and run


```bash
find assets/ -type f \( -name "*.wav" -o -name "*.mp3" \) -not -path "*/screenshots/*" | while read -r file; do   if ffmpeg -nostdin -i "$file" -c:a aac -b:a 48k -ac 1 -y "${file%.*}.m4a" > /dev/null 2>&1; then     rm "$file";     echo "Converted to M4A: $file";   else     echo "Failed: $file";   fi; done
```

### Confirmation


`Converted to M4A: assets/sfx/cha-ching.mp3`

## Mascot Animations

### Step 0: Get The img2webp

[documentation](https://developers.google.com/speed/webp/docs/img2webp)

### Step 1: Extract the frames to PNGs using FFmpeg:

```bash
ffmpeg -c:v libvpx-vp9 -i mascot.webm -vf "scale=320:-1,fps=15" mascot_frame_%04d.png
```

### Step 2: Stitch them together with img2webp:

```bash
img2webp -loop 0 -d 66 -lossy -q 75 mascot_frame_*.png -o mascot_clean.webp
```
## Cauldron Forge2d Workflow

Drag the [svg](assets/images/cauldron/Cauldron.svg) into figma

Play Around A bit :)

[Here's](https://cdn.hackclub.com/019ea59e-2dfc-78fe-8477-db7a7be6490b/output.png) How I do it 

## Logging

```dart
import 'package:logging/logging.dart';

final _log = Logger('Foo');

void foo() {
  _log.info('Hello, world!');
}
```

This will show up in the console as:

```text
[Foo] Hello, world!
```

When using Flutter DevTools, all the metadata of the log message is preserved, so you can filter by logger name, log level, and so on.