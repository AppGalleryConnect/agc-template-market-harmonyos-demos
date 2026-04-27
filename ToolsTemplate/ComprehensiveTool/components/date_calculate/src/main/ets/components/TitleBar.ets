import { AppStorageV2 } from '@kit.ArkUI';
import { AreaType } from '../model/Index';
import { getInstance } from '../utils/Route';

@ComponentV2
export struct TitleBar {
  @Param @Require title: string;
  @Param isShowBack: boolean = true;
  @Local avoidArea: AreaType = AppStorageV2.connect(AreaType, 'avoidArea', () => new AreaType())!;

  build() {
    Row({ space: 8 }) {
      if (this.isShowBack) {
        Image($r('app.media.icon_nav_left'))
          .size({ height: 40, width: 40 })
          .onClick(() => {
            getInstance().pop();
          });
      }
      Text(this.title)
        .fontSize(20)
        .width('50%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .fontColor( $r('sys.color.black'))
        .fontWeight(FontWeight.Medium);
    }
    .margin({ top: this.avoidArea.top })
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding({
      left: 12,
      right: 12,
    });
  }
}