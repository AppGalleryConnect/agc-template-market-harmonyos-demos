import { RouterMap, RouterModule, TelUtil } from 'lib_foundation';
import { FeedbackRouteMap } from 'feedback';
import { MenuInfo } from '../types';
import { MinePageVM } from '../viewModels/MinePageVM';


@ComponentV2
export struct CommonServiceView {
  @Consumer('pageStack') pageStack?: NavPathStack;
  vm: MinePageVM = MinePageVM.instance
  private menuList: MenuInfo[] = [
    {
      label: '意见反馈',
      icon: $r('app.media.feedback'),
      action: () => {
        if (this.vm.userInfoModel.isLogin) {
          RouterModule.push({ url: FeedbackRouteMap.FeedbackSubmit });
        } else {
          RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE }, () => {
            RouterModule.push({ url: FeedbackRouteMap.FeedbackSubmit })
          })
        }
      },
    },
    {
      label: '联系客服',
      icon: $r('sys.symbol.service'),
      isSymbol: true,
      action: () => {
        TelUtil.makeCall('联系客服', '0012356');
      },
    },
    {
      label: '设置',
      icon: $r('app.media.ic_setting'),
      action: () => {
        RouterModule.push({ url: RouterMap.SETTING_PAGE });
      },
    },
  ]

  build() {
    Column({ space: 8 }) {
      Column() {
        GridRow({
          columns: { sm: 1, md: 2 },
          gutter: { x: 48 },
        }) {
          ForEach(this.menuList, (item: MenuInfo) => {
            GridCol() {
              this.menuItemView(item)
            }
          }, (item: MenuInfo) => JSON.stringify(item))
        }
      }
      .width('100%')
      .constraintSize({ maxWidth: '100%' })
      .borderRadius(12)
      .padding({ left: 12, right: 12, top: 8 })
      .backgroundColor($r('sys.color.background_primary'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  menuItemView(menu: MenuInfo) {
    Column({ space: 16 }) {
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

      Divider().margin({ left: 40 })
    }
    .width('100%')
    .height(56)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      menu.action()
    })
  }
}