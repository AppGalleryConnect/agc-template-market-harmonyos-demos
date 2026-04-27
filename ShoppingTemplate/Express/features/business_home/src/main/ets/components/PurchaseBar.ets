import { UIDialog } from '@hw-agconnect/ui-dialog';
import { RouterModule, RouterMap } from 'lib_foundation';
import { ExpressPageVM } from '../viewModels/ExpressPageVM';

@ComponentV2
export struct PurchaseBar {
  vm: ExpressPageVM = ExpressPageVM.instance

  @Computed
  get btnDisabled() {
    return this.vm.isPrepayRequestValid() && this.vm.isSign;
  }

  openPayTipDialog() {
    UIDialog.open({
      titleOptions: {
        primaryTitle: '到付须知',
      },
      contentOptions: {
        content:
        `您选择的付款方式为【到付】，预估金额${this.vm.price}元，请提前和收件人沟通付款金额。若收件人拒绝支付，托寄物品退回可能产生双程费用`,
        contentFontColor: $r('sys.color.font_secondary'),
      },
      showConfirmButton: true,
      showCancelButton: true,
      confirmButtonOptions: {
        buttonFontColor: $r('sys.color.font_emphasize'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      cancelButtonOptions: {
        buttonFontColor: $r('sys.color.font_tertiary'),
        buttonFontSize: 16,
        buttonBgColor: Color.Transparent,
      },
      onConfirm: () => {
        UIDialog.closeLast();
        this.vm.preOrder();
      },
      closeOnClickMask: false,
      closeOnBackPress: false,
    })
  }

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
            .fontColor($r('sys.color.font_emphasize'))
        }
        .margin({ bottom: 10 })

        Row() {
          Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
            .select(this.vm.isSign)
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value) => {
              this.vm.isSign = value;
            })
          Text() {
            Span('阅读并同意')
              .fontColor($r('sys.color.font_tertiary'))
            Span('《电子运单契约条约》')
              .fontColor($r('sys.color.font_emphasize'))
              .onClick(() => {
                RouterModule.push({ url: RouterMap.PRIVACY_PAGE });
              })
          }
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
        }
        .onClick(() => {
          this.vm.isSign = !this.vm.isSign;
        })
      }
      .alignItems(HorizontalAlign.Start)

      Button('下单')
        .width('30%')
        .constraintSize({ maxWidth: 142 })
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .enabled(this.btnDisabled)
        .onClick(() => {
          if (this.vm.selectedPayMethod.value === 2) {
            this.openPayTipDialog();
            return;
          }
          this.vm.preOrder();
        })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: this.vm.windowModel.windowBottomPadding
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}