export default class ImageUtils {
    static repeatTopBorder( src ) {
        var w = src.width;
        var h = src.height;

        var dst = new ImageData(w, h);

        var dstBuf = dst.data;
        var srcBuf = src.data;

        for (var row = 0; row < h; row++) {
            for (var col = 0; col < w; col++) {
                var srcIndex = ((row % 4) * w + col) * 4;
                var dstIndex = (row * w + col) * 4;

                for (var channel = 0; channel < 4; channel++) {
                    dstBuf[dstIndex + channel] = srcBuf[srcIndex + channel];
                }
            }
        }

        return dst;
    }

    static borderBlur( imageData ) {
      return this.convolve(
          imageData,
          this.gaussianKernel7x7(),
          1,
          0
      );
    }

    static gaussianKernel7x7() {
        return [
            [ 0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067 ],
            [ 0.00002292, 0.00078634, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292 ],
            [ 0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117 ],
            [ 0.00038771, 0.01330373, 0.11098164, 0.22508352, 0.11098164, 0.01330373, 0.00038771 ],
            [ 0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117 ],
            [ 0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292 ],
            [ 0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067 ]
        ];
    }

    // Applying the convolution to the canvas image data
    // https://medium.com/the-missing-bit/convolution-filter-in-javascript-666b114c0f34
    static convolve(src: ImageData, kernel: number[][], divisor = 1, offset = 0, opaque = true) {
        var w = src.width;
        var h = src.height;

        var dst = new ImageData(w, h);

        var dstBuf = dst.data;
        var srcBuf = src.data;

        var rowOffset = Math.floor(kernel.length / 2);
        var colOffset = Math.floor(kernel[0].length / 2);

        for (var row = 0; row < h; row++) {
            for (var col = 0; col < w; col++) {
                var result = [0, 0, 0, 0];

                for (var kRow = 0; kRow < kernel.length; kRow++) {
                    for (var kCol = 0; kCol < kernel[kRow].length; kCol++) {
                        var kVal = kernel[kRow][kCol]

                        var pixelRow = row + kRow - rowOffset;
                        var pixelCol = col + kCol - colOffset;

                        if (pixelRow < 0 || pixelRow >= h ||
                            pixelCol < 0 || pixelCol >= w) {
                            continue;
                        }

                        var srcIndex = (pixelRow * w + pixelCol) * 4;

                        for (var channel = 0; channel < 4; channel++) {
                            if (opaque && channel === 3) {
                                continue;
                            } else {
                                var pixel = srcBuf[srcIndex + channel];
                                result[channel] += pixel * kVal;
                            }
                        }
                    }
                }

                var dstIndex = (row * w + col) * 4;

                for (var channel = 0; channel < 4; channel++) {
                    var val = (opaque && channel === 3) ? 255 : result[channel] / divisor + offset;
                    dstBuf[dstIndex + channel] = val;
                }
            }
        }
        return dst;
    }
}
