export interface MenuItem {
  value: string;
  action: () => void;
}

//通用页面头部组件

@ComponentV2
export struct CommonHeader {
  @Param @Require onBack?: () => void
  @Param title: string = ''
  @Param showMenu: boolean = false
  @Param menuItems: MenuItem[] = []
  @Param onMenuToggle: () => void = () => {}
  @Param onMenuDisappear: () => void = () => {}

  build() {
    Row() {
      Image($r('app.media.ic_backward2'))
        .width(40)
        .aspectRatio(1)
        .margin({ left: 16, right: 8 })
        .onClick(() => {
          if (this.onBack) {
            this.onBack()
          }
        })

      Text(this.title)
        .size({ height: 27 })
        .margin({ left: 16 })
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(700)
        .fontColor($r('sys.color.font_primary'))

      Blank().layoutWeight(1)

      if (this.menuItems.length > 0) {
        Image($r('app.media.ic_title_menu'))
          .width(40)
          .height(40)
          .aspectRatio(1)
          .margin({ right: 16 })
          .onClick(() => {
            if (this.onMenuToggle) {
              this.onMenuToggle();
            }
          })
          .bindMenu(this.showMenu, this.menuItems, {
            placement: Placement.BottomRight,
            onDisappear: () => {
              if (this.onMenuDisappear) {
                this.onMenuDisappear();
              }
            }
          })
      }
    }
    .height(48)
    .width('100%')
    .padding({ top: 24 })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
