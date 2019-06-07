//= require paper/dist/paper-core

class SummaryMatrix {
  constructor(el, options = {}) {
    this.el = el;
    this.div = $(this.el);
    this.canvas = $('canvas', this.div);
    this.data = this.div.data('summary');

    this.canvas.height(this.canvas.width());

    this.options = options;

    paper.setup(this.canvas[0]);

    this.draw()
  }

  get allValues() {
    return Object.keys(this.data).sort();
  }

  get viewSize() {
    return paper.view.size;
  }

  get uiHeaders() {
    if(this._uiHeaders === undefined) {
      let layer = new paper.Layer({id: 'uiHeaders'});

      let ix = 1;
      for(let value of this.allValues) {
        this.drawBox(0, ix, { value: value });
        this.drawBox(ix, 0, { value: value });

        ix++;
      }

      this._uiHeaders = layer;
    }

    return this._uiHeaders;
  }

  getSumGroundTruthFor(truth) {
    if(this._sumGroundTruth === undefined) {
      this._sumGroundTruth = {};
    }

    if(this._sumGroundTruth[truth] === undefined) {
      let sum = 0;

      for(let pred of Object.keys(this.data[truth])) {
        sum = sum + this.data[truth][pred];
      }

      this._sumGroundTruth[truth] = sum;
    }

    return this._sumGroundTruth[truth];
  }

  getScore(truth, pred) {
    let value = (this.data[truth] || {})[pred] || 0;

    return value / this.getSumGroundTruthFor(truth);
  }

  get uiValueCells() {
    if(this._uiValueCells === undefined) {
      let layer = new paper.Layer({id: 'uiValueCells'});

      let truthIx = 0;
      for(let truth of this.allValues) {
        let predIx = 0;

        for(let pred of this.allValues) {
          let score = this.getScore(truth, pred);
          let color = truth == pred ? `rgba(40, 200, 40, ${score})` : `rgba(200, 40, 40, ${score})`;
          let strokeColor = '#eee';
          let strokeWidth = truth == pred ? 1 : 0;

          this.drawBox(predIx + 1, truthIx + 1, {
            value: '',
            fillColor: color,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth
          });

          predIx++;
        }

        truthIx++;
      }

      this._uiValueCells = layer;
    }

    return this._uiValueCells;
  }

  get cellVerticalCount() {
    return this.allValues.length + 1;
  }

  get cellWidth() {
    return this.viewSize.width / this.cellVerticalCount;
  }

  get cellHeight() {
    return this.cellWidth;
  }

  getPosition(row, column) {
    return {
      x: this.cellWidth * column,
      y: this.cellHeight * (row + 1),
      width: this.cellWidth,
      height: this.cellHeight
    };
  }

  drawBox(row, column, options = {}) {
    let position = this.getPosition(row, column);

    let rect = new paper.Shape.Rectangle(
      new paper.Rectangle(position.x, position.y, position.width, position.height)
    );

    rect.strokeColor = options['strokeColor'];
    rect.strokeWidth = options['strokeWidth'];
    rect.fillColor = options['fillColor'];

    if(options['value'] !== undefined) {
      rect.addChild(
        new paper.PointText({
          point: [position.x, position.y],
          content: options['value'],
          fontSize: `${this.cellHeight}px`
        })
      );
    }

    return rect;
  }

  drawHeader(where) {
    this.drawBox(0, 0)
  }

  draw() {
    this.uiHeaders;
    this.uiValueCells;

    return paper.view.draw();
  }
}

window.SummaryMatrix = SummaryMatrix;
