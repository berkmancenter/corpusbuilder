export default class BoxesUtils {
    static boxesOverlap(box1, box2) {
        return box1.uly <= box2.lry &&
               box1.lry >= box2.uly &&
               box1.ulx <= box2.lrx &&
               box1.lrx >= box2.ulx;
    }

    static empty() {
        return {
            ulx: 0,
            uly: 0,
            lrx: 0,
            lry: 0
        }
    }

    static boxValid(box) {
        return box.ulx > 0 && box.ulx < box.lrx &&
               box.lrx > 0 &&
               box.uly > 0 && box.uly < box.lry &&
               box.lry > 0;
    }

    static union(boxes) {
        if(boxes.length === 0) {
            return BoxesUtils.empty();
        }

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

    static boxesEqual(box1, box2) {
        if(box1 === null || box1 === undefined || box2 === null || box2 === undefined) {
            return false;
        }
        else {
            return Math.abs(box1.ulx - box2.ulx) < 1 &&
                  Math.abs(box1.lrx - box2.lrx) < 1 &&
                  Math.abs(box1.uly - box2.uly) < 1 &&
                  Math.abs(box1.lry - box2.lry) < 1;
        }
    }
}
