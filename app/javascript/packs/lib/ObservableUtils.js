export default class ObservableUtils {
    static plain(object) {
        if(typeof object.$mobx === 'object') {
            return Object.keys(object.$mobx.values).reduce(
                (s, k) => {
                    if(typeof object[k].$mobx === 'object') {
                        s[k] = ObservableUtils.plain(object[k]);
                    }
                    else {
                        s[k] = object[k];
                    }

                    return s
                },
                {}
            );
        }
        else {
            return object;
        }
    }
}
