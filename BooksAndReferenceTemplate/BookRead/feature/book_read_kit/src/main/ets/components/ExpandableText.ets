import curves from '@ohos.curves';
import { BusinessError } from '@ohos.base';
import display from '@ohos.display';
import { FontModel } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ExpandableText {
  @Param @Require content: string;
  @Param fontSize: number = 14;
  @Param lineHeight: number = 20;
  @Param fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  @Param widthRatio: number = 0.9;

  @Local lines: number = 4;
  @Local collapseText: string = '展开';
  @Local isExpandable: boolean = false;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  aboutToAppear() {
    const estimatedCharsPerLine = 20;
    const maxDisplayableChars = estimatedCharsPerLine * this.lines;

    this.isExpandable = this.content.length > maxDisplayableChars;
    this.performPreciseMeasurement();
  }

  private performPreciseMeasurement() {
    const textWidth = this.getUIContext().getMeasureUtils().measureText({
      textContent: this.content,
      fontSize: this.fontModel.getFg(this.fontSize)
    });
    
    display.getAllDisplays().then((data: Array<display.Display>) => {
      const screenWidth = data[0].width;
      const preciseExpandable = screenWidth * this.lines * this.widthRatio <= textWidth;
      
      if (this.isExpandable !== preciseExpandable) {
        if (!preciseExpandable && this.content.length < 60) {
          this.isExpandable = false;
        }
      }
    }).catch((err: BusinessError) => {
      console.error(`[ExpandableText] Failed to obtain display info: ${JSON.stringify(err)}`);
    });
  }

  build() {
    Column() {
      if (this.isExpandable) {
        Column() {
          Text(this.content)
            .fontSize(this.fontModel.getFg(this.fontSize))
            .lineHeight(this.lineHeight)
            .fontColor(this.fontColor)
            .maxLines(this.lines)
            .width('100%')
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(this.collapseText)
              .fontSize(this.fontModel.getFg(14))
              .fontColor($r('sys.color.ohos_id_color_text_hint'))
              .fontWeight(FontWeight.Medium)
              .padding({ top: 8, bottom: 4 })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .onClick(() => {
            if (this.collapseText === '展开') {
              this.collapseText = '收起';
              this.getUIContext().animateTo({
                duration: 200,
                curve: curves.springMotion(0.5, 0.8),
              }, () => {
                this.lines = -1;
              });
            } else {
              this.collapseText = '展开';
              this.getUIContext().animateTo({
                duration: 150,
                curve: Curve.Friction,
              }, () => {
                this.lines = 4;
              });
            }
          })
        }
        .alignItems(HorizontalAlign.Start)
      } else {
        Text(this.content)
          .fontSize(this.fontModel.getFg(this.fontSize))
          .lineHeight(this.lineHeight)
          .fontColor(this.fontColor)
          .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
} 