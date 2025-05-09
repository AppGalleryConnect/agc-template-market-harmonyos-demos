import { CustomContentDialog } from '@kit.ArkUI';
import { FormatUtil } from 'commonlib';
import { RouterMap } from 'commonlib/src/main/ets/constants/CommonEnum';
import { OtherVM } from '../viewModels/OtherVM';

@Builder
export function OtherBuilder() {
  Other()
}

@Entry
@ComponentV2
struct Other {
  vm: OtherVM = OtherVM.instance
  dialogControllerOther: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.vm.isOn = true
          }
        },
        {
          value: '确认',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
            this.vm.isOn = false
            this.vm.cancelRelated()
          }
        }
      ],
    }),
  })
  dialogControllerPurchase: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.openBuildContent();
      }
    }),
  })

  build() {
    NavDestination() {
      Column() {
        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text('我的理财账号')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Image($r('app.media.icc_arrow_right'))
              .width(7)
              .height(14)
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.FINANCIAL_ACCOUNT)
          })

          Divider().color($r('sys.color.comp_divider'))

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text('我的理财协议')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Image($r('app.media.icc_arrow_right'))
              .width(7)
              .height(14)
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.FINANCIAL_AGREEMENT)
          })
        }
        .borderRadius(16)
        .backgroundColor(Color.White)
        .padding({ left: 12, right: 12 })
        .margin({ bottom: 12 })

        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text('隐私协议')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Image($r('app.media.icc_arrow_right'))
              .width(7)
              .height(14)
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRIVACY, '隐私协议')
          })
        }
        .borderRadius(16)
        .backgroundColor(Color.White)
        .padding({ left: 12, right: 12 })
        .margin({ bottom: 12 })
      }
      .padding({ left: 16, right: 16, top: 12 })
    }
    .title('其他')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Text('解除关联')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 15 })
      Text('请确认是否解除账号关联？')
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
    }
    .width('100%')
  }

  // 自定义弹出框的内容区
  @Builder
  openBuildContent(): void {
    Column() {
      Row() {
        Text('关联账号')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .margin({ bottom: 16 })

      Column() {
        Text(FormatUtil.encryptPhoneNo(this.vm.userInfo.cellphone))
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
        Text('华为账号绑定手机号')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .padding(16)
      .borderRadius(16)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Color.White)

      Row() {
        Row() {
          Text('取消')
        }
        .width('50%')
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.vm.isOn = false
          this.dialogControllerPurchase.close()
        })

        Row() {
          Button('确认')
            .width('100%')
            .height(40)
            .backgroundColor('#E4480C')
        }
        .width('50%')
        .height(40)
        .onClick(() => {
          this.vm.isOn = true
          this.vm.getUserAccount(this.vm.userInfo.id)
          this.dialogControllerPurchase.close()
        })
      }
      .margin({ top: 28 })
    }
    .width('100%')
  }
}