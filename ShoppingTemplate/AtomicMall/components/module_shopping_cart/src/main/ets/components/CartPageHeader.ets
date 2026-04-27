import { NavTitleBar } from 'lib_widget';

@ComponentV2
export struct CartPageHeader {
  // 购物车页面是否是作为子路由页面
  @Param isChildRoute: boolean = false;
  // 是否展示管理按钮
  @Param showEdit: boolean = false;
  // 是否编辑态
  @Param isEdit: boolean = false;
  // 切换编辑的回调
  @Event changeEdit: () => void = () => {
  };
  // 作为子页面时，返回事件回调
  @Event onBack: () => void = () => {
  };

  build() {
    Column() {
      NavTitleBar({
        title: '购物车',
        bgColor: $r('app.color.background_color_grey'),
      })
      if (this.showEdit) {
        Row() {
          Text(this.isEdit ? '完成' : '批量管理')
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.changeEdit();
            })
        }
        .width($r('app.string.size_percent_full'))
        .padding({
          right: $r('app.float.space_l'),
          top: $r('app.float.space_s'),
        })
        .justifyContent(FlexAlign.End)
      }
    }
    .backgroundColor($r('app.color.background_color_grey'))
  }
}