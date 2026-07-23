import { CircleButtonModifier, CommonConfirmDialog, GlobalContextUtils } from 'lib_common';

@ComponentV2
export struct SetReadIcon {
  @Param enable: boolean = true;
  @Event confirm: () => void = () => {
  };
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  build() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.clean'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize($r('app.float.normal_img_size'))
      }
      .attributeModifier(this.buttonModifier)
      .accessibilityText('一键已读')
      .onClick(() => {
        if (this.enable) {
          CommonConfirmDialog.show({
            primaryTitle: '温馨提示',
            content: '您确定将全部未读消息标记为已读？',
            secBtnV: '确定',
            confirm: () => {
              this.confirm();
            },
          });
        } else {
          GlobalContextUtils.showToast({ message: '暂无未读消息' });
        }
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}