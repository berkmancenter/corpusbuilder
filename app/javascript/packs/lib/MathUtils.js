export default class MathUtils {
    static std(array) {
        return Math.sqrt(
            MathUtils.variance(array)
        );
    }

    static median(arrays){
        if(arrays.length === 0) return 0;

        arrays.sort(function(a,b){
            return a - b;
        });

        var half = Math.floor(arrays.length / 2);

        if (arrays.length % 2) {
            return arrays[half];
        }

        return (arrays[half - 1] + arrays[half]) / 2.0;
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
