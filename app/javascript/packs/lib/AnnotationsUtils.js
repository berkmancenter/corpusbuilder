export default class AnnotationsUtils {
    static kindOf(annotation) {
        if(["header", "blockquote", "p"].indexOf(annotation.mode) !== -1) {
            return 'structural';
        }

        return annotation.mode;
    }

    static modeTitle(mode) {
        if(mode === "header") {
            return "Header";
        }
        else if(mode === "blockquote") {
            return "Blockquote";
        }
        else if(mode === "p") {
            return "Paragraph beginning";
        }
        else if(mode === "comment") {
            return "Comment";
        }
        else {
            return "Category";
        }
    }

    static title(annotation) {
        return AnnotationsUtils.modeTitle(annotation.mode);
    }
}
