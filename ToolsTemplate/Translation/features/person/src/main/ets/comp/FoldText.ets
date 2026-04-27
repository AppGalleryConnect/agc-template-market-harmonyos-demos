import measure from '@ohos.measure';

@ComponentV2
export struct FoldText {
  @Param @Require textContent: string = '';
  @Local isMoreDescExpand: boolean = false;
  @Local isShowMoreDesc: boolean = false;
  private textWidth: number = 0;
  @Event onTextClick: () => void

  aboutToAppear(): void {
    // this.setIsShowMoreDesc()
  }

  setIsShowMoreDesc(): void {
    // 内容超过2行，需要提供展开功能
    const textSizeShowMinLines: SizeOptions = measure.measureTextSize({
      textContent: this.textContent || '',
      fontSize: $r('sys.float.Body_M'),
      textAlign: TextAlign.JUSTIFY,
      maxLines: 3,
      lineHeight: 19,
      baselineOffset: 7,
      wordBreak: WordBreak.BREAK_ALL,
      constraintWidth: this.textWidth,
    });
    const textSizeShowMaxLines: SizeOptions = measure.measureTextSize({
      textContent: this.textContent || '',
      fontSize: $r('sys.float.Body_M'),
      textAlign: TextAlign.JUSTIFY,
      maxLines: 50,
      lineHeight: 19,
      baselineOffset: 7,
      wordBreak: WordBreak.BREAK_ALL,
      constraintWidth: this.textWidth,
    });

    // 2行高度和多行一样，说明不需要展开。多行大于2行才需要展开
    if (textSizeShowMinLines?.height && textSizeShowMaxLines?.height) {
      this.isShowMoreDesc = textSizeShowMaxLines?.height > textSizeShowMinLines?.height;
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {

        Text() {
          Span(this.textContent || '')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .lineHeight(19)
        }
        .width('100%')
        .textAlign(TextAlign.JUSTIFY)
        .maxLines(this.isMoreDescExpand ? 50 : 3)
        .baselineOffset(7)
        .wordBreak(WordBreak.BREAK_ALL)
        .id('id/introductionContent')

        if (this.isShowMoreDesc) {
          Column() {
            Text() {
              if (!this.isMoreDescExpand) {
                Span('... ')

                Span('展开')
                  .fontSize(14)
                  .fontColor('rgba(0, 0, 0, 0.4)')
              }
            }
            .fontSize($r('sys.float.Body_M'))
            .backgroundColor(Color.White)

            if (this.isMoreDescExpand) {
              Text('合上')
                .fontSize(14)
                .fontColor('rgba(0, 0, 0, 0.4)')
                .offset({ y: 20 })
            }


            Column() {
            }.height(7)
          }
          // 点击热区扩大到200%
          .responseRegion({
            x: '-50%',
            y: '-50%',
            width: '200%',
            height: '200%'
          })
          .onClick(() => {
            this.isMoreDescExpand = !this.isMoreDescExpand;
            this.onTextClick()
          })
        }
      }
      .width('100%')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        if (newValue.width === oldValue.width) {
          return;
        }
        // 作为返回值时width永远为number
        this.textWidth = newValue.width as number - 32;

        this.setIsShowMoreDesc();
      })
    }
    .alignItems(HorizontalAlign.Center)
  }
}

@Builder
export function foldTexBuilder(textContent: string, onTextClick?: () => void) {
  FoldText({ textContent: textContent, onTextClick })
}