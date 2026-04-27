import { MoreFunction } from '../commons/Interface';

@ComponentV2
export struct MoreMenuView {
  @Param list: MoreFunction[] = [];
  @Param menuWidth: number = 114;

  build() {
    Column() {
      List() {
        ForEach(this.list, (item: MoreFunction) => {
          ListItem() {
            Row() {
              if (item.icon) {
                Image(item.icon)
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })
              }

              Text(item.name)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('100%')
            .padding({ left: 16 })
            .height(48)
            .onClick(() => {
              item.onClick?.()
            })
          }
        }, (item: MoreFunction) => JSON.stringify(item))
      }
      .divider({ strokeWidth: 0.5 })
      .scrollBar(BarState.Off)
    }
    .width(this.menuWidth)
    .backgroundColor(Color.White)
    .margin({ top: 4, bottom: 4 })
  }
}