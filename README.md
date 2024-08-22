# Requirements

- [Connect IQ SDK][sdk]
- [fontbm][fontbm] for generating bitmap fonts

# Status symbols

| ASCII symbol | Kanji symbol | meaning |
| --- | --- | --- |
| A | 覚 | alarm set |
| D | 切 | phone disconnected |
| P | 話 | phone connected |
| Z | 夜 | night mode |
| S | 休 | display sleeping (less frequent redraws) |

# Generating bitmaps

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

[fontbm]: https://github.com/vladimirgamalyan/fontbm
[sdk]: https://developer.garmin.com/connect-iq/overview/