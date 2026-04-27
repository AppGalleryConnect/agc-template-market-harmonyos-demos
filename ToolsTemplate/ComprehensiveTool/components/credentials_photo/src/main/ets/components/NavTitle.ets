import { getInstance } from '../util/Route';


@ComponentV2
export struct NavTitle {
  @Param text: string = '';
  @Param isEdit: boolean = false;
  // 保存
  @Event onSave: () => void = () => {

  };
  // 被拦截的回调
  @Event onBlock: () => void = () => {

  };

  build() {
    Row({ space: 22 }) {
      Row({ space: 8 }) {
        Image($r('app.media.credentials_left'))
          .size({ height: 40, width: 40 })
          .onClick(() => {
            if (this.isEdit) {
              this.onBlock();
            } else {
              getInstance().pop();
            }
          });
        Text(this.text)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .layoutWeight(1)
          .fontColor($r('sys.color.font_primary'));
      }.layoutWeight(1);

      if (this.isEdit) {
        Image($r('app.media.ic_save_photo')).width(40).height(40)
          .onClick(() => {
            this.onSave();
          });
      }
    }
    .width('100%')
    .justifyContent(this.isEdit ? FlexAlign.SpaceBetween : FlexAlign.Start)
    .height(56)
    .padding({
      left: 12,
      right: 12,
    });
  }
}