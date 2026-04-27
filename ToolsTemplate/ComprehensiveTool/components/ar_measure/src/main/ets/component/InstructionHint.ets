import { MeasureType } from '../constant/Constant';
import { PromptActionUtil } from '../util/PromptActionUtil';

@Builder
export function instructionHint(mode: number) {
  Column() {
    Text(mode === MeasureType.VOLUME ? '体积测量' : '空间识别')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 2 });

    Text(mode === MeasureType.VOLUME ? '请保持缓慢移动设备，保证相机分别完整捕捉到空间的各个面，工具会自动识别空间大小' :
      '请保持缓慢移动设备，保证相机分别完整捕捉到空间的各个面，工具会自动识别空间大小')
      .margin({ bottom: 16 })
      .fontSize(14);

    Image(mode === MeasureType.VOLUME ? $r('app.media.volume_hint') : $r('app.media.space_hint'))
      .height(180)
      .margin({ top: 8, bottom: 8 });

    Button('知道了')
      .fontColor($r('sys.color.font_emphasize'))
      .fontWeight(FontWeight.Medium)
      .backgroundColor('rgba(0, 95, 255, 0.1)')
      .borderRadius(20)
      .width('100%')
      .padding({ left: 24, right: 24 })
      .onClick(() => {
        PromptActionUtil.closeDialog(PromptActionUtil.getContentNode());
      });
  }.width('90%').padding(16).backgroundColor($r('sys.color.comp_background_primary')).borderRadius(32);
}