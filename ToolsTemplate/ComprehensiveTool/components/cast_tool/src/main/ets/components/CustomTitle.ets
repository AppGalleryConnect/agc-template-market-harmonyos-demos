import { getInstance } from '../util/Route';


@ComponentV2
export struct CustomTitle {
  @Param title: string = '';
  @Param isDark: boolean = false;

  build() {
    Row({ space: 22 }) {
      Row({ space: 8 }) {
        Image(this.isDark ? $r('app.media.ic_cast_left_dark') : $r('app.media.ic_cast_left'))
          .size({ height: 40, width: 40 })
          .onClick(() => {
            getInstance().pop();
          });
        Text(this.title)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .layoutWeight(1)
          .fontColor(this.isDark ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'));
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