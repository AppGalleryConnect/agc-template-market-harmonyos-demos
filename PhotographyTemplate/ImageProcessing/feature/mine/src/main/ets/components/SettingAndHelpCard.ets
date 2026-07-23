import { BreakpointNameEnum } from 'commonlib';
import { MinePageVM } from '../viewmodels/MinePageVM';
import { MenuInfo } from '../model/MineModel';

@ComponentV2
export struct SettingAndHelpCard {
  vm: MinePageVM = MinePageVM.instance;

  @Computed
  get listLanes() {
    const bp = this.vm.breakPointModel.currentBreakpoint;
    return bp === BreakpointNameEnum.SM ? 1 : 2;
  }

  build() {
    List({ space: 24 }) {
      ForEach(this.vm.menuList, (item: MenuInfo) => {
        ListItem() {
          this.menuItemView(item)
        }
      }, (item: MenuInfo) => JSON.stringify(item))
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(12)
    .divider({ strokeWidth: 1 })
    .lanes(this.listLanes, 16)
  }

  @Builder
  menuItemView(menu: MenuInfo) {
    Row() {
      if (menu.isSymbol) {
        SymbolGlyph(menu.icon).fontSize(24).fontColor([$r('sys.color.icon_primary')])
      } else {
        Image(menu.icon).width(24).height(24)
      }

      Text(menu.label).fontSize(14).fontColor($r('sys.color.font_primary'))
        .margin({ left: 16 })

      Blank()

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(24)
        .fontColor([$r('sys.color.icon_tertiary')])
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      menu.action()
    })
  }
}