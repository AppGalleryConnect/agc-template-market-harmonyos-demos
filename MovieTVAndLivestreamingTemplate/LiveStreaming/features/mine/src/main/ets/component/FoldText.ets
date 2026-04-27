import measure from '@ohos.measure';
import hilog from '@ohos.hilog';

@ComponentV2
export struct FoldText {
  @Param @Require textContent: string = '';
  @Local isMoreDescExpand: boolean = false;
  @Local isShowMoreDesc: boolean = false;
  private textWidth: number = 0;
  @Event onTextClick: () => void
  private uiContext: UIContext = this.getUIContext();

  aboutToAppear(): void {
    // this.setIsShowMoreDesc()
  }

  setIsShowMoreDesc(): void {
    // 内容超过2行，需要提供展开功能
    const textSizeShowMinLines: SizeOptions = this.uiContext.getMeasureUtils().measureTextSize({
      textContent: this.textContent || '',
      fontSize: $r('sys.float.Body_M'),
      textAlign: TextAlign.JUSTIFY,
      maxLines: 3,
      lineHeight: 19,
      baselineOffset: 7,
      wordBreak: WordBreak.BREAK_ALL,
      constraintWidth: this.textWidth,
    });
    const textSizeShowMaxLines: SizeOptions = this.uiContext.getMeasureUtils().measureTextSize({
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
    hilog.info(0x0000, 'VodDescription',
      `setIsShowMoreDesc isShowMoreDesc: ${this.isShowMoreDesc} maxline: ${textSizeShowMaxLines?.height} minline: ${textSizeShowMinLines?.height}`);
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
                  .fontColor($r('sys.color.font_tertiary'))
              }
            }
            .fontSize($r('sys.float.Body_M'))
            .backgroundColor($r('sys.color.comp_background_primary'))

            if (this.isMoreDescExpand) {
              Text('合上')
                .fontSize(14)
                .fontColor($r('sys.color.font_tertiary'))
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
        hilog.info(0x00001, 'VodDescription',
          `onAreaChange newValue.width: ${newValue.width} textWidth: ${this.textWidth}`)
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

@Preview
@ComponentV2
struct FoldTextPreview {
  textContent: string =
    '1出身泰国华人家庭的无业年轻人阿安（马群耀 饰）看到堂妹因照顾病重的爷爷而继承房产后，也对身患绝症的姥姥（乌萨·萨梅坎姆 饰）动了心思，计划复刻堂妹的“致富之路”获取百万遗产。但面对同样“努力”的舅舅们和挑剔毒舌的姥姥，阿安这条争当全职孝孙的“啃姥致富”之路似乎没有他预想的那么顺利';

  build() {
    foldTexBuilder(this.textContent)
  }
}

@Preview
@ComponentV2
struct FoldTextOneLinePreview {
  textContent: string = '2出身';

  build() {
    foldTexBuilder(this.textContent)
  }
}