export default class GraphemesUtils {
    static wordBoxes(graphemes) {
        return this.words(graphemes)
                   .map(this.boxes);
    }
}
