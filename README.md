# KanjiFace

A Garmin Connect IQ watch face designed for kanji review

## Overview

This watch face assists with learning [Japanese kanji][kanji].
A random character is displayed periodically, allowing the wearer to test their knowledge.
The date, day of week, and watch status details may also be displayed as kanji for further immersion.
Currently just the Forerunner 45 watch model is supported, since that's the only model I have for testing.

## Development requirements

- [Connect IQ SDK][sdk]
- [fontbm][fontbm] for generating bitmap fonts

## Status symbols

The watch face uses abbreviations to indicate the current device status.
These can be displayed in the Latin alphabet or as kanji:

| ASCII symbol | Kanji symbol | meaning |
| --- | --- | --- |
| A | 覚 | alarm set |
| D | 切 | phone disconnected |
| P | 話 | phone connected |
| Z | 夜 | night mode |
| S | 休 | display sleeping (less frequent redraws) |

## Generating bitmaps

[fontbm][fontbm] is used as a cross-platform, CLI-friendly alternative to BMFont.
To update or replace the generated bitmap fonts, `fontbm` must be available on the path.

To change the bitmaps for the main set of kanji, run:
``` bash
./generate_packed_font.rb resources/data/joyo.txt
```

To change the bitmaps for the status font (used for status symbols, numerals, and days of the week), run:
``` bash
./generate_mapped_font.rb resources/data/status_kanji.txt
```

Other parameters, including size and which vector font is used, can be changed directly in the scripts.

## Design

### Bitmap font

English-language models of the Forerunner 45 watch don't include system fonts to render kanji.
Instead, I'm using a custom bitmap font.
For this project, the large display kanji bitmaps are rasterized from Noto Serif CJK, and the status font kanji use Noto Sans CJK.
All 2136 [jōyō kanji][joyo] are included.

### Monkey C resource objects

A watch face for the Forerunner 45 is limited to 48 KiB of memory.
This is too small to fit all the kanji bitmaps into one font resource.
I settled on chunks of 64 kanji characters for each font resource, which may be loaded as necessary at runtime.
Through careful memory management, the watch face will release the prior font resource before loading the new one, to minimize memory usage.

### Custom encoding

Trying to use the original Unicode code points for all kanji characters consumes too much memory.
Instead, I've created a custom encoding that compresses all desired kanji into one contiguous block.
The Connect IQ font rendering seems to aware of Unicode properties like non-printable and combining characters.
To avoid accidentally mapping one of the kanji characters to a code point that doesn't render properly, the custom encoding begins at U+4E00.
This is the start of the CJK Unified Ideographs range in Unicode, which consists entirely of printable characters, and is more than large enough to fit all the jōyō kanji.
This encoding doesn't require storing a sparse list of codepoints, and the wearer is only concerned with the appearance of the rendered bitmap.

[fontbm]: https://github.com/vladimirgamalyan/fontbm
[sdk]: https://developer.garmin.com/connect-iq/overview/
[kanji]: https://en.wikipedia.org/wiki/Kanji
[joyo]: https://en.wikipedia.org/wiki/J%C5%8Dy%C5%8D_kanji
