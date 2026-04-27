import { ExpressPageVM } from '../viewModels/ExpressPageVM';
import { CustomContentDialog } from '@kit.ArkUI';
import { CommonButton, RouterModule } from 'lib_foundation';
import { RouterMap } from 'module_base';

@ComponentV2
export struct PurchaseBar {
  vm: ExpressPageVM = ExpressPageVM.instance
  payDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      contentAreaPadding: {
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
      },
    }),
  })

  build() {
    Row() {
      Column() {
        Row() {
          Text('预估总价')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Text(`￥${this.vm.price}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0A59F7')
        }
        .margin({ bottom: 10 })

        Row() {
          Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
            .select(false)
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value) => {
              this.vm.isSign = value
            })
          Text() {
            Span('阅读并同意')
              .fontColor($r('sys.color.font_tertiary'))
            Span('《电子运单契约条约》')
              .fontColor('#0A59F7')
              .onClick(() => {
                RouterModule.push({ url: RouterMap.PRIVACY_PAGE })
              })
          }
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
        }
      }
      .alignItems(HorizontalAlign.Start)

      Row() {
        Button(this.vm.orderInfo ? '保存' : '下单')
          .width('100%')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor(this.vm.getButtonColor())
      }
      .width(164)
      .flexShrink(0)
      .onClick(() => {
        if (this.vm.orderInfo) {
          this.vm.updateOrder()
        } else {
          if (this.vm.selectedPayMethod === '到付') {
            if (this.vm.isPrepayRequestValid()) {
              this.payDialogController.open()
              return
            }
          }
          this.vm.prepay()
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('预估金额')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text(this.vm.price)
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FE543A')
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          CommonButton({
            cancelFunc: () => {
              this.payDialogController.close()
            }, saveButton: () => {
              this.vm.prepay()
              this.payDialogController.close()
            },
          })
        }
        .width('100%')
        .padding({
          top: 24,
          bottom: 16,
          left: 24,
          right: 24,
        })
        .backgroundColor('rgba(255,255,255,0.80)')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }
}