import { AppRouter, Constants, WebPageParams } from 'common'
import { BaseTitle } from 'components'
import { NavItemView } from '../components/NavItemView'
import { NavItem } from '../model/MinePageModel'

@Builder
export function settingPageBuilder() {
  SettingPage()
}

@ComponentV2
export struct SettingPage {
  // 隐私协议
  @Local privacy: NavItem = new NavItem('隐私政策', 'privacy', $r('app.media.ic_privacy'))

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '设置',
          bgColor: $r('sys.color.white'),
          showBackBtn: true,
          onBack: () => {
            AppRouter.pop()
          }
        })

        Column({space: 12}) {
          NavItemView({
            data: this.privacy,
            clickItem: () => {
              let param = {
                title: '隐私政策',
                linkUrl: $rawfile('privacy.html')
              } as WebPageParams
              AppRouter.push({
                url: 'WebPage',
                param: param
              })
            }
          })
        }
        .width(Constants.FULL_PERCENT_WIDTH)
        .padding({left: 16, right:16, top: 12})
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.color_page_bg'))
  }
}