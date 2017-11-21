export default class MathUtils {
    static std(array) {
        return Math.sqrt(
            MathUtils.variance(array)
        );
    }

    static variance(array) {
        let scaleLength = array.length - 1;

        if(scaleLength <= 0) {
            return NaN;
        }

        return MathUtils.sum(
            MathUtils.squaredDiffs(
              array,
              MathUtils.mean( array )
            )
          ) / scaleLength;
    }

    static mean(array) {
        return MathUtils.sum(array) / array.length;
    }

    static sum(array) {
        return array.reduce((sum, value) => { return sum + value }, 0);
    }

    static squaredDiffs(array, value) {
        return array.map((item) => { return Math.pow(item - value, 2) });
    }
}
