import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;

class KanjiLoader{
    // The first codepoint in our custom encoding
    static const ENCODING_START = 19968;
    // The total number of kanji encoded into custom fonts
    static const KANJI_MAX = 2136;
    // How many kanji each font resource can contain
    static const CHUNK_SIZE = 64;

    static const FONTS = [
        Rez.Fonts.Kanji0,
        Rez.Fonts.Kanji1,
        Rez.Fonts.Kanji2,
        Rez.Fonts.Kanji3,
        Rez.Fonts.Kanji4,
        Rez.Fonts.Kanji5,
        Rez.Fonts.Kanji6,
        Rez.Fonts.Kanji7,
        Rez.Fonts.Kanji8,
        Rez.Fonts.Kanji9,
        Rez.Fonts.Kanji10,
        Rez.Fonts.Kanji11,
        Rez.Fonts.Kanji12,
        Rez.Fonts.Kanji13,
        Rez.Fonts.Kanji14,
        Rez.Fonts.Kanji15,
        Rez.Fonts.Kanji16,
        Rez.Fonts.Kanji17,
        Rez.Fonts.Kanji18,
        Rez.Fonts.Kanji19,
        Rez.Fonts.Kanji20,
        Rez.Fonts.Kanji21,
        Rez.Fonts.Kanji22,
        Rez.Fonts.Kanji23,
        Rez.Fonts.Kanji24,
        Rez.Fonts.Kanji25,
        Rez.Fonts.Kanji26,
        Rez.Fonts.Kanji27,
        Rez.Fonts.Kanji28,
        Rez.Fonts.Kanji29,
        Rez.Fonts.Kanji30,
        Rez.Fonts.Kanji31,
        Rez.Fonts.Kanji32,
        Rez.Fonts.Kanji33
    ];

    function getRandomKanji() as Number {
        var kanjiNumber = (Math.rand() % KANJI_MAX) + ENCODING_START;
        return kanjiNumber;
    }

    function loadNextKanji() as [Number, FontResource] {
        var kanji = getRandomKanji();

        var resourceIndex = (kanji - ENCODING_START) / CHUNK_SIZE;
        var font = WatchUi.loadResource(FONTS[resourceIndex]);

        return [kanji, font];
    }

}
