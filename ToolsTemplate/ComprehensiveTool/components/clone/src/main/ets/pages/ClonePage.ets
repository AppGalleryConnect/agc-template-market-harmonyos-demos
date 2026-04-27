import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { getInstance, setPathStack } from '../common/CommonRoute';
import { SystemUtil } from '../utils/SystemUtil';
import { ClonePageVM } from '../viewmodel/ClonePageVM';
import { common } from '@kit.AbilityKit';


@ComponentV2
export struct ClonePage {
  vm: ClonePageVM = ClonePageVM.instance
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext

  aboutToAppear(): void {
    SystemUtil.context = this.context
    this.vm.getPermission(this.context)
  }

  build() {
    NavDestination() {
      Column() {
        titleBuilder('数据迁移')
        routerBuilder($r('sys.symbol.phone_transmission_phone'), $r('sys.color.multi_color_02'), '#C5EDFF',
          '旧设备点这里', () => {
            if (!this.vm.checkAccessToken()) {
              return
            }
            SystemUtil.startScanAbility(this.getUIContext().getHostContext()).then((value) => {
              this.vm.handleScanResult(value)
            }).catch(() => {
              promptAction.showToast({ message: '启动扫码失败' })
            })
          })
        routerBuilder($r('sys.symbol.dual_phone_pairing'), '#68AFFF', '#EEF6FF', '新设备点这里', () => {
          if (!this.vm.checkAccessToken()) {
            return
          }
          getInstance().pushPathByName('ReceiverPage', true)
        })
        titleBuilder('隔空投送')
        routerBuilder($r('sys.symbol.mirror_projection'), $r('sys.color.multi_color_04'), '#DEFDF8',
          '各种数据，一键传送', () => {
            this.vm.pickerSelect()
          })
        Row() {
          Text('隔空投送说明：在点击按钮选择文件后，通过手机顶部的相碰触发。')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('克隆工具')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }
}

@Builder
function titleBuilder(title: string) {
  Row() {
    Text(title)
      .fontSize($r('sys.float.Subtitle_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 12 })
  }
  .width('100%')
}

@Builder
function routerBuilder(img: Resource, fontColor: ResourceStr, color: ResourceStr, text: string, func: Function) {
  Row() {
    Row() {
      Row() {
        SymbolGlyph(img)
          .fontSize(24)
          .fontColor([fontColor])
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(color)
      .borderRadius(8)
      .margin({ right: 12 })

      Text(text)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
    }

    Image($r('app.media.clone_chevron_right'))
      .width(12)
      .height(24)

  }
  .width('100%')
  .padding(12)
  .margin({ bottom: 12 })
  .backgroundColor($r('sys.color.background_primary'))
  .borderRadius(16)
  .justifyContent(FlexAlign.SpaceBetween)
  .onClick(() => {
    func()
  })
}

@Builder
export function ClonePageBuilder() {
  ClonePage();
}
