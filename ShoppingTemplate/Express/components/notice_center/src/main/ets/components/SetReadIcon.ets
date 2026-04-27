import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';


@ComponentV2
export struct SetReadIcon {
  @Param enable: boolean = true;
  @Event confirm: () => void = () => {
  };

  build() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.clean'))
          .fontSize(24)
          .fontColor([$r('sys.color.font_primary')])
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        if (this.enable) {
          UIDialog.open({
            title: '温馨提示',
            content: '您确定将全部未读消息标记为已读？',
            showConfirmButton: true,
            showCancelButton: true,
            confirmButtonOptions: {
              buttonBgColor: Color.Transparent,
            },
            cancelButtonOptions: {
              buttonBgColor: Color.Transparent,
            },
            closeOnClickMask: false,
            closeOnBackPress: false,
            onConfirm: () => {
              this.confirm();
            }
          })
        } else {
          ToastDialog.showToast({ message: '暂无未读消息' })
        }
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}