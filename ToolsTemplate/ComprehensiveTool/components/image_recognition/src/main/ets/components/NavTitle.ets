import { getInstance } from '../util/Route';


@ComponentV2
export struct NavTitle {
  @Param title: string = '';
  @Param isDark: boolean = false;

  build() {
    Row({ space: 22 }) {
      Row({ space: 8 }) {
        Image(this.isDark ? $r('app.media.ic_dark_back') : $r('app.media.ic_light_back'))
          .size({ height: 40, width: 40 })
          .onClick(() => {
            getInstance().pop();
          });
        Text(this.title)
          .titleExtend();
      }.layoutWeight(1);
    }
    .width('100%')
    .height(56)
    .padding({
      left: 12,
      right: 12,
    });
  }
}

@Extend(Text)
function titleExtend() {
  .fontSize($r('sys.float.Title_S'))
  .fontWeight(FontWeight.Bold)
  .layoutWeight(1)
  .fontColor($r('sys.color.font_primary'));
}
