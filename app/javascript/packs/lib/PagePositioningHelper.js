
export default class PagePositioningHelper {
    static graphemePositioning(grapheme, ratio) {
        let graphemeHeight = grapheme.area.lry - grapheme.area.uly;
        let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;

        let boxHeight = graphemeHeight * ratio;
        let boxWidth = graphemeWidth * ratio;
        let boxLeft = grapheme.area.ulx * ratio;
        let boxTop = grapheme.area.uly * ratio;

        return {
            left: boxLeft,
            top: boxTop,
            fontSize: `${boxHeight}px`,
            height: boxHeight,
            width: boxWidth
        };
    }

    static spacePositionsBetween(grapheme, previous, ratio) {
        if(previous === null || previous === undefined) {
            return [];
        }

        if(grapheme.area.uly !== previous.area.uly) {
            return [
                {
                    left: grapheme.area.lrx * ratio,
                    top: grapheme.area.uly * ratio,
                    fontSize: (grapheme.area.lry - grapheme.area.uly) * ratio
                }
            ];
        }
        else {
            let distance = grapheme.area.ulx - previous.area.lrx;
            let graphemeWidth = grapheme.area.lrx - grapheme.area.ulx;
            let graphemeHeight = grapheme.area.lry - grapheme.area.uly;

            if(distance > graphemeWidth * 0.5) {
                let boxWidth = graphemeWidth * ratio;
                let boxHeight = graphemeHeight * ratio;

                let spaces = [];

                for(let spaceIndex = 0; spaceIndex < distance / graphemeWidth; spaceIndex++) {
                    spaces.push(
                        {
                            left: `${(previous.area.ulx + boxWidth * spaceIndex) * ratio}px`,
                            top: `${(grapheme.area.uly * ratio)}px`,
                            height: `${boxHeight}px`,
                            width: `${boxWidth}px`,
                            fontSize: `${boxHeight}px`
                        }
                    );
                }

                return spaces;
            }
            else {
                return [];
            }
        }
    }
}
