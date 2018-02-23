export default class DomUtils {
    static absoluteOffsetLeft(node) {
        if(node === undefined || node === null) {
            return 0;
        }
        else {
            return node.offsetLeft + DomUtils.absoluteOffsetLeft(node.offsetParent);
        }
    }
}
