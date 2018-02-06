export default class BoxesUtils {
    static boxesOverlap(box1, box2) {
        return box1.uly <= box2.lry &&
               box1.lry >= box2.uly &&
               box1.ulx <= box2.lrx &&
               box1.lrx >= box2.ulx;
    }
}
