export default class AnnotationsUtils {
    static kindOf(annotation) {
        if(["h1", "h2", "h3", "h4", "h5", "p"].indexOf(annotation.mode) !== -1) {
            return 'structural';
        }

        return annotation.mode;
    }

    static title(annotation) {
        if(annotation.mode === "h1") {
            return "Header 1";
        }
        else if(annotation.mode === "h2") {
            return "Header 2";
        }
        else if(annotation.mode === "h3") {
            return "Header 3";
        }
        else if(annotation.mode === "h4") {
            return "Header 4";
        }
        else if(annotation.mode === "h5") {
            return "Header 5";
        }
        else if(annotation.mode === "p") {
            return "Paragraph beginning";
        }
        else if(annotation.mode === "comment") {
            return "Comment";
        }
        else {
            return "Category";
        }
    }
}
