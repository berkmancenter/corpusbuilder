export default class PlatformUtils {
    static specialKeyName() {
        if ( navigator.appVersion.indexOf("Mac") !== -1) {
            return 'Meta';
        }
        else {
            return 'Ctrl';
        }
    }
}
