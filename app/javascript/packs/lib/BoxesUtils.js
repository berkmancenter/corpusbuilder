export default class BoxesUtils {
    static boxesOverlap(box1, box2) {
        return box1.uly <= box2.lry &&
               box1.lry >= box2.uly &&
               box1.ulx <= box2.lrx &&
               box1.lrx >= box2.ulx;
    }

    static union(boxes) {
        let minUlx = boxes.reduce((min, b) => { return Math.min(min, b.ulx) }, boxes[0].ulx);
        let minUly = boxes.reduce((min, b) => { return Math.min(min, b.uly) }, boxes[0].uly);
        let maxLrx = boxes.reduce((max, b) => { return Math.max(max, b.lrx) }, boxes[0].lrx);
        let maxLry = boxes.reduce((max, b) => { return Math.max(max, b.lry) }, boxes[0].lry);

        return {
            ulx: minUlx,
            uly: minUly,
            lrx: maxLrx,
            lry: maxLry
        }
    }
}
