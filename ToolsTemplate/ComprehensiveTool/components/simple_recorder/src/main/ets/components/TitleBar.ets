import { getInstance } from '../util/Route';


@ComponentV2
export struct TitleBar {
  @Param @Require title: string;
  @Param isShowBtn: boolean = false;
  @Param isShowEdit: boolean = false;
  // 是否做返回拦截
  @Param isBlock: boolean = false;
  @Local isEdit: boolean = true;
  @Event save: () => void = () => {

  };
  @Event onBlock: () => void = () => {

  };
  @Event onEdit: () => void = () => {

  };
  @Event onCancel: () => void = () => {

  };

  build() {
    Row({ space: 22 }) {
      Row({ space: 8 }) {
        Image($r('app.media.icon_nav_left'))
          .size({ height: 40, width: 40 })
          .onClick(() => {
            if (this.isBlock) {
              this.onBlock();
            } else {
              getInstance().pop();
            }
          });
        Text(this.title)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .layoutWeight(1)
          .fontColor($r('sys.color.font_primary'));
      }.layoutWeight(1);

      if (this.isShowBtn) {
        Text('保存')
          .width(64)
          .height(40)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#2070F3')
          .textAlign(TextAlign.Center)
          .borderRadius(20)
          .onClick(() => {
            this.save();
          });
      }

      if (this.isShowEdit) {
        Text(this.isEdit ? '编辑' : '取消')
          .width(72)
          .height(40)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(20)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.isEdit) {
              this.onEdit();
              this.isEdit = false;
            } else {
              this.onCancel();
              this.isEdit = true;
            }
          });
      }
    }
    .width('100%')
    .justifyContent(this.isShowBtn ? FlexAlign.SpaceBetween : FlexAlign.Start)
    .height(56)
    .padding({
      left: 12,
      right: 12,
    });
  }
}