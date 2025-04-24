import { MeasureText, MeasureOptions, LengthMetrics } from '@kit.ArkUI';

@ComponentV2
export struct TagGrid {
  @Param
  data: string[] = [];
  @Param
  fontSize: number = 9;
  @Param
  fontColor: ResourceColor = '#FF666666';
  @Param
  tagPadding: Padding = {
    top: 0.5,
    bottom: 0.5,
    left: 3.5,
    right: 3.5,
  };
  @Param
  tagBorderWidth: number = 0.8;
  @Param
  tagBorderRadius: number = 3;
  @Param
  tagBorderColor: ResourceColor = '#FFD8D8D8';
  @Param
  gridMaxLines: number | undefined = undefined;
  @Param
  gridHorizontalGap: number = 3;
  @Param
  gridVerticalGap: number = 3;
  @Local
  private _gridMaxHeight: number = Infinity;

  aboutToAppear(): void {
    if (this.gridMaxLines !== undefined) {
      let textHeight: number = calcTextHeight({ textContent: 'ABC_012_零一二', fontSize: `${this.fontSize}vp` });
      let rowMaxHeight: number = textHeight + this.tagBorderWidth * 2 + (this.tagPadding.top as number ?? 0) +
        (this.tagPadding.bottom as number ?? 0);
      this._gridMaxHeight = rowMaxHeight * this.gridMaxLines + (this.gridMaxLines - 1) * this.gridVerticalGap;
    }
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      space: {
        main: LengthMetrics.vp(this.gridHorizontalGap),
        cross: LengthMetrics.vp(this.gridVerticalGap),
      },
    }) {
      ForEach(this.data, (item: string) => {
        this.tagBuilder(item);
      }, (item: string, index: number) => JSON.stringify(item + index));
    }
    .constraintSize({ maxHeight: this._gridMaxHeight });
  }

  @Builder
  tagBuilder(value: string) {
    Column() {
      Text(value)
        .fontSize(this.fontSize)
        .fontColor(this.fontColor)
        .margin(this.tagPadding)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .borderWidth(this.tagBorderWidth)
    .borderRadius(this.tagBorderRadius)
    .borderColor(this.tagBorderColor);
  }
}

function calcTextHeight(measureOptions: MeasureOptions): number {
  try {
    let sizeOptions: SizeOptions = MeasureText.measureTextSize(measureOptions);
    let textHeight: number = 0;
    if (sizeOptions.height !== undefined) {
      textHeight = px2vp(sizeOptions.height as number);
    }
    return textHeight > 0 ? textHeight : NaN;
  } catch (e) {
    return NaN;
  }
}