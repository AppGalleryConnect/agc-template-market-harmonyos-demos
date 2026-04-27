import measure from '@ohos.measure';
import { TCLogger } from 'common';

/**
 * @usage: 用于长文本展示和折叠场景。提供文本展开/收起功能，超过3行时显示"展开"按钮，
 * 展开后显示"合上"按钮。关键数据结构：textContent（文本内容字符串）、isMoreDescExpand（是否展开布尔值）、
 * isShowMoreDesc（是否显示展开按钮布尔值）、onTextClick（点击回调函数）。
 * 包含if逻辑：根据文本高度判断是否需要展开功能（超过3行显示展开按钮），根据isMoreDescExpand判断显示展开或合上。
 * @layout: 垂直布局。使用Stack堆叠布局，底层为文本内容（左对齐，最多3行或50行），
 * 顶层右下角为展开/合上按钮（白色背景）。文本超过3行时显示"...展开"，展开后显示"合上"。
 * @constraints: textContent文本内容不能为空，文本宽度必须正确计算，onTextClick回调函数可选
 * @isGen: true
 * @fileType: component
 * @zhName: 可折叠文本组件
 */
@ComponentV2
export struct FoldText {
  @Param @Require textContent: string = '';
  @Local isMoreDescExpand: boolean = false;
  @Local isShowMoreDesc: boolean = false;
  private textWidth: number = 0;
  @Event onTextClick: () => void

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
    TCLogger.info('VodDescription',
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
        TCLogger.info('VodDescription',
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