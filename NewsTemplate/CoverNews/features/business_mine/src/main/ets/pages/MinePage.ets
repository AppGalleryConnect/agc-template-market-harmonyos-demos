import { CommonConstants, customTitleBuilder } from 'lib_common'
import { AtomicserviceLogin } from 'atomicservice_login'
import { MinePageVM } from '../viewmodels/MinePageVM';
import { SettingItemModel, SettingItemView } from '../components/SettingItem';

@ComponentV2
export struct MinePage {
  private vm: MinePageVM = new MinePageVM();

  aboutToAppear(): void {
    this.vm.queryUserInfo();
  }

  build() {
    NavDestination() {
      Column() {
        customTitleBuilder('我的')
        this.userCard()
        this.listCard()
      }
      .width('100%')
      .height('100%')
      .padding({
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
        top: this.vm.breakPointModel.isTabVertical ? this.vm.windowModel.windowTopPadding : 0,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  userCard() {
    AtomicserviceLogin({
      userInfo: this.vm.userInfo,
      isLink: this.vm.userInfoModel.isLink,
      controller: this.vm.controller,
      bindPhone: () => {
        this.vm.bindPhone();
      },
      onGetPhoneError: (err) => {
        this.vm.onGetPhoneError(err);
      },
      unBindPhone: this.vm.unBindPhone,
    })
  }

  @Builder
  listCard() {
    Text('常用服务')
      .fontSize($r('sys.float.Subtitle_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .margin({ top: 24, bottom: 8 })
      .width('100%')

    List() {
      Repeat(this.vm.settingList)
        .key((item) => item.label)
        .each((item: RepeatItem<SettingItemModel>) => {
          ListItem() {
            SettingItemView({ item: item.item })
          }
        })
    }
    .width('100%')
    .height('auto')
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(CommonConstants.PADDING_XS)
    .lanes(this.vm.lanesMap.getValue(this.vm.breakPointModel.currentBreakpoint))
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: 48,
      endMargin: CommonConstants.PADDING_M,
    })
  }
}
