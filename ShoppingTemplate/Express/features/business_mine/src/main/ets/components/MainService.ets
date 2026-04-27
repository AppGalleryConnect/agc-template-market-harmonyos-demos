import { RouterModule } from 'lib_foundation'
import { AddressManage } from 'module_address'
import { ControllerModule, RouterMap, TelUtil, toastUtil } from 'module_base'
import { MinePageVM } from '../viewModels/MinePageVM'

@ComponentV2
export struct MainService {
  vm: MinePageVM = MinePageVM.instance

  @Builder
  mainServiceBuilder(text: string, image: ResourceStr, func: Function) {
    Column() {
      Image(image)
        .width(32)
        .height(32)
        .margin({ bottom: 8 })
      Text(text)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .onClick(() => {
      if (!this.vm.userInfoModel.isLogin) {
        RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
        return
      }
      func()
    })
  }

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        this.mainServiceBuilder('我的快递', $r('app.media.ic_mine_express'), () => {
          const controller = ControllerModule.get()
          if (controller) {
            controller.changeIndex(1)
          }
        })
        AddressManage({
          navPathStack: RouterModule.stack,
          onBeforeNavigate: () => {
            if (!this.vm.userInfoModel.isLogin) {
              RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
              return false
            } else {
              return true
            }
          }
        }) {
          Column() {
            Image($r('app.media.wc'))
              .width(32)
              .height(32)
              .margin({ bottom: 8 })
            Text('地址簿')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
        }

        this.mainServiceBuilder('实名认证', $r('app.media.ic_card'), () => {
          if (this.vm.userInfoModel && this.vm.userInfoModel.realNameAuthFlag === 1) {
            toastUtil.showToast('已实名！')
            return
          }
          RouterModule.push({ url: RouterMap.REAL_NAME_AUTH_PAGE })
        })
        this.mainServiceBuilder('联系客服', $r('app.media.service'), () => {
          TelUtil.makeCall('联系客服', '10000000000');
        })
      }
    }
    .width('100%')
    .height(80)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .padding({
      left: 12,
      right: 12
    })
    .borderRadius(16)
  }
}