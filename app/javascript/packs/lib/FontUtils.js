export default class FontUtils {
    static inferFontName(graphemes) {
        if(FontUtils.hasSyriac(graphemes)) {
            return { name: 'Estrangelo Talada', url: 'fonts/EstrangeloTalada.otf' }
        }
        else if(FontUtils.hasArabic(graphemes)) {
            return { name: 'Lateef', url: 'fonts/LateefRegOT.ttf' }
        }
        else {
            return { name: 'Lora', url: 'fonts/Lora-Regular.ttf' }
        }
    }

    static hasSyriac(graphemes) {
        return FontUtils.includesAnyRange(graphemes, [
            [0x700, 0x74F], // Syriac
            [0x860, 0x86A]  // Extended Syriac
        ]);
    }

    static hasArabic(graphemes) {
        return FontUtils.includesAnyRange(graphemes, [
            [0x600,   0x6FF],    // Arabic
            [0x750,   0x77F],    // Supplement Arabic
            [0x8A0,   0x8FF],    // Extended-A Arabic
            [0xFB50,  0xFDFF],   // Presentation Forms-A
            [0xFE70,  0xFEFF],   // Presentation Forms-B
            [0x10E60, 0x10E7F],  // Rumi Numeral Symbols
            [0x1EE00, 0x1EEFF]   // Mathematical Arabic
        ]);
    }

    static includesAnyRange(graphemes, ranges) {
        // todo: explore possibility of making the following more performant

        for(let grapheme of graphemes) {
            let codePoint = grapheme.value.codePointAt(0);

            for(let [min, max] of ranges) {
                if(codePoint >= min && codePoint <= max) {
                    return true;
                }
            }
        }

        return false;
    }
}
