//= require paper/dist/paper-core

class SummaryMatrix {
  constructor(el, options = {}) {
    this.el = el;
    this.div = $(this.el);
    this.canvas = $('canvas', this.div);
    this.data = this.div.data('summary');
    this.mode = 'p_pred_given_correct';

    this.div.css('position', 'relative');
    this.canvas.height(this.canvas.width());
    this.canvas.css('cursor', 'pointer');

    this.options = options;

    paper.setup(this.canvas[0]);

    this.modeSelect.show();
    this.tooltip.hide();

    this.draw()
  }

  modePLabel(truth, pred) {
    if(this.mode == 'p_pred_given_correct') {
      return `P( prediction = "${pred}" | correct = "${truth}" )`;
    }
    else {
      return `P( correct = "${truth}" | prediction = "${pred}" )`;
    }
  }

  get modeSelect() {
    if(this._modeSelect === undefined) {
      let wrapper = $('<div></div>');
      let label = $('<label>Mode:</label>');

      this._modeSelect = $(`
        <select>
          <option value="p_pred_given_correct" selected>P(prediction | correct)</option>
          <option value="p_correct_given_pred">P(correct | prediction)</option>
        </select>
        `
      );

      this._modeSelect.css('margin-left', '10px');
      let self = this;

      this._modeSelect.change(function(e) {
        self.setMode($(e.currentTarget).val());
      });

      wrapper.append(label);
      wrapper.append(this._modeSelect);
      this.div.prepend(wrapper);
    }

    return this._modeSelect;
  }

  get tooltip() {
    if(this._tooltip === undefined) {
      this._tooltip = $('<div></div>');

      this._tooltip.css('background-color', 'white');
      this._tooltip.css('color', '#444');
      this._tooltip.css('box-shadow', '0px 0px 8px rgba(0, 0, 0, 0.1), 2px 2px 2px rgba(0, 0, 0, 0.25)');
      this._tooltip.css('padding', '10px');
      this._tooltip.css('position', 'absolute');
      this._tooltip.css('left', '0px');
      this._tooltip.css('top', '0px');
      this._tooltip.css('border-radius', '2px');
      this._tooltip.css('font-size', '0.95em');

      this.div.append(this._tooltip);
    }

    return this._tooltip;
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
        let top = this.drawBox(0, ix, { value: value });
        let left = this.drawBox(ix, 0, { value: value });

        top['rect'].name = `top-${value}-rect`;
        left['rect'].name = `left-${value}-rect`

        top['label'].name = `top-${value}-label`;
        left['label'].name = `left-${value}-label`

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

  getSumPredictedFor(pred) {
    if(this._sumPrecicted === undefined) {
      this._sumPrecicted = {};
    }

    if(this._sumPrecicted[pred] === undefined) {
      let sum = 0;

      for(let truth in this.data) {
        sum = sum + (this.data[truth][pred] || 0);
      }

      this._sumPrecicted[pred] = sum;
    }

    return this._sumPrecicted[pred];
  }

  setMode(mode) {
    if(mode !== this.mode) {
      this.mode = mode;
      this.uiValueCells.remove();
      this._uiValueCells = undefined;
      this.uiHeaders.remove();
      this._uiHeaders = undefined;

      this.draw();
    }
  }

  getScore(truth, pred) {
    if(this.mode == 'p_pred_given_correct') {
      let value = (this.data[truth] || {})[pred] || 0;

      return value / this.getSumGroundTruthFor(truth);
    }
    else {
      let value = (this.data[truth] || {})[pred] || 0;

      return value / this.getSumPredictedFor(pred);
    }
  }

  get uiValueCells() {
    if(this._uiValueCells === undefined) {
      let layer = new paper.Layer({id: 'uiValueCells'});

      let truthIx = 0;
      for(let truth of this.allValues) {
        let predIx = 0;

        for(let pred of this.allValues) {
          let score = this.getScore(truth, pred);

          if(score > 0 || truth == pred) {
            let color = truth == pred ? `rgba(40, 200, 40, ${score})` : `rgba(200, 40, 40, ${score})`;
            if(score == 0) {
              color = 'white';
            }
            let strokeColor = '#eee';
            let strokeWidth = truth == pred ? 1 : 0;

            let { rect: box, label: label } = this.drawBox(predIx + 1, truthIx + 1, {
              value: '',
              fillColor: color,
              strokeColor: strokeColor,
              strokeWidth: strokeWidth
            });

            box.data = {
              truth: truth,
              pred: pred,
              score: score,
              col: truthIx + 1,
              row: predIx + 1
            };

            let self = this;

            box.onMouseEnter = function(event) {
              let data = event.target.data;

              self.select(data);
            }

            box.onMouseLeave = function(event) {
              let data = event.target.data;

              self.deselect(data);
            }
          }

          predIx++;
        }

        truthIx++;
      }

      this._uiValueCells = layer;
    }

    return this._uiValueCells;
  }

  getHex(value) {
    let cp = value.codePointAt(0);

    if(cp !== undefined && cp !== null) {
      let hex = value.codePointAt(0).toString(16);

      return "\\u" + "0000".substring(0, 4 - hex.length) + hex;
    }
    else {
      return '---';
    }
  }

  select(data) {
    this.deselect();

    this.tooltip.html(`
      Ground Truth: <b>${data.truth}</b> (${this.getHex(data.truth)})<br />
      Predicted: <b>${data.pred}</b> (${this.getHex(data.pred)})<br />
      <span>${this.modePLabel(data.truth, data.pred)}:</span> <b>${this.getScore(data.truth, data.pred).toFixed(4) * 100}%</b><br />
    `);
    this.tooltip.show();

    let valuesCount = this.allValues.length;

    let top = data.row * this.cellHeight + 20;
    let left = data.col * this.cellWidth + 20;

    if(top + this.tooltip.height() > this.viewSize.height) {
      top = (data.row - 1) * this.cellHeight - this.tooltip.height() - 20;
    }

    if(left + this.tooltip.width() > this.viewSize.width) {
      left = (data.col - 1) * this.cellWidth - this.tooltip.width() - 20;
    }

    this.tooltip.css('top', top);
    this.tooltip.css('left', left);

    this._selected = data;
  }

  deselect(data = undefined) {
    if(data === undefined) {
      data = this._selected;
    }

    if(data === undefined) {
      return;
    }

    this.tooltip.hide();

    this._selected = undefined;
  }

  getForData(data) {
    let topRect = this.uiHeaders.children[`top-${data.truth}-rect`];
    let leftRect = this.uiHeaders.children[`left-${data.pred}-rect`];

    let topLabel = this.uiHeaders.children[`top-${data.truth}-label`];
    let leftLabel = this.uiHeaders.children[`left-${data.pred}-label`];

    return { topRect: topRect, topLabel: topLabel, leftRect, leftLabel };
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

    let label = undefined;

    if(options['value'] !== undefined) {
      label = new paper.PointText({
        point: [position.x, position.y + this.cellHeight],
        content: options['value'],
        fontSize: `${this.cellHeight}px`
      })
    }

    return { rect: rect, label: label };
  }

  drawHeader(where) {
    this.drawBox(0, 0)
  }

  draw() {
    this.uiValueCells;
    this.uiHeaders.bringToFront();

    return paper.view.draw();
  }
}

window.SummaryMatrix = SummaryMatrix;
