import { getInstance } from '../util/RouteUtil';


@ComponentV2
export struct NavTitle {
  @Param @Require title: string;

  build() {
    Row({ space: 22 }) {
      Row({ space: 8 }) {
        Image($r('app.media.ic_guitar_back'))
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
          .fontColor($r('sys.color.font_on_primary'));
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