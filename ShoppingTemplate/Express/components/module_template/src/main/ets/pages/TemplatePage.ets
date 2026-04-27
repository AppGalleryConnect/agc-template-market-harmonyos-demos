import { LengthMetrics } from '@kit.ArkUI';
import {
  SHIPPING_METHOD_LIST,
  PAY_METHOD_LIST,
  RouterModule,
  IGoods,
  ISetting,
  CommonStepper,
  CommonTitle,
  BottomBtn,
} from 'lib_foundation';
import { PageMode } from '../common/Constant';
import { TemplatePageVM } from '../viewmodel/TemplatePageVM';
import { AddressSelectCard } from '../components/AddressSelectCard';


@Builder
export function TemplatePageBuilder() {
  TemplatePage()
}

@ComponentV2
struct TemplatePage {
  vm: TemplatePageVM = new TemplatePageVM();

  aboutToAppear(): void {
    this.vm.init();
  }

  aboutToDisappear(): void {
    this.vm.clear();
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: this.vm.pageTitle,
      })
      Column({ space: 12 }) {
        Scroll() {
          Column({ space: 12 }) {
            if (this.vm.pageMode === PageMode.CREATE) {
              this.myTemplateBtn()
            }

            AddressSelectCard({
              stack: RouterModule.stack,
              userId: this.vm.userInfoModel.id,
              senderInfo: this.vm.senderInfo,
              receiverInfo: this.vm.receiverInfo,
            })

            Column({ space: 8 }) {
              this.titleBuilder('物品类型')

              Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
                ForEach(this.vm.goodsList, (goods: IGoods) => {
                  Row() {
                    Text(goods.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor(this.vm.selectedGoodsId === goods.id ? Color.White : $r('sys.color.font_primary'))
                  }
                  .width(72)
                  .height(28)
                  .justifyContent(FlexAlign.Center)
                  .borderRadius(8)
                  .backgroundColor(this.vm.selectedGoodsId === goods.id ?
                    $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'),
                  )
                  .onClick(() => {
                    this.vm.selectedGoodsId = goods.id
                    this.vm.weight = goods.weight
                  })
                }, (item: IGoods) => JSON.stringify(item))
              }
            }
            .cardFancy()
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            Row() {
              this.titleBuilder('预估重量')
              CommonStepper({
                value: this.vm.weight,
                unit: 'kg',
                min: 1,
                max: 9999,
                buttonType: ButtonType.Circle,
                isBorder: false,
                onChange: (value) => {
                  if (value <= 0) {
                    return;
                  }
                  if (value > 9999) {
                    return;
                  }
                  this.vm.weight = value
                },
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .cardFancy()

            Column({ space: 8 }) {
              this.titleBuilder('寄件方式')

              Flex({ space: { main: LengthMetrics.vp(this.vm.shippingMethodSpace) } }) {
                ForEach(SHIPPING_METHOD_LIST, (shippingMethod: ISetting) => {
                  Row() {
                    Text(shippingMethod.value === 3 && this.vm.selectedTime ? this.vm.selectedTime :
                      shippingMethod.text)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .lineHeight(19)
                      .fontColor(this.vm.selectedShippingMethod === shippingMethod.value ? Color.White :
                        $r('sys.color.font_primary'))
                      .margin(shippingMethod.value === 3 ? { right: 4 } : {})
                    if (shippingMethod.value === 3) {
                      SymbolGlyph($r('sys.symbol.chevron_right'))
                        .fontSize(16)
                        .fontColor([
                          this.vm.selectedShippingMethod === 3 ? Color.White : $r('sys.color.icon_secondary'),
                        ])
                    }
                  }
                  .flexGrow(1)
                  .justifyContent(FlexAlign.Center)
                  .borderRadius(8)
                  .backgroundColor(this.vm.selectedShippingMethod === shippingMethod.value ?
                    $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'),
                  )
                  .padding({ top: 4, bottom: 4 })
                  .onClick(() => {
                    this.vm.selectedShippingMethod = shippingMethod.value;
                    if (this.vm.selectedShippingMethod === 3) {
                      this.vm.openDateTimeSheet();
                    }
                  })
                }, (item: ISetting) => JSON.stringify(item))
              }
              .width('100%')
            }
            .cardFancy()
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              this.titleBuilder('付款方式')

              Flex({ space: { main: LengthMetrics.vp(this.vm.shippingMethodSpace) } }) {
                ForEach(PAY_METHOD_LIST, (payMethod: ISetting) => {
                  Row() {
                    Text(payMethod.text)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .lineHeight(19)
                      .fontColor(this.vm.selectedPaymentMethod === payMethod.value ? Color.White :
                        $r('sys.color.font_primary'))
                  }
                  .flexGrow(1)
                  .justifyContent(FlexAlign.Center)
                  .padding({ top: 4, bottom: 4 })
                  .borderRadius(8)
                  .backgroundColor(this.vm.selectedPaymentMethod === payMethod.value ?
                    $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'),
                  )
                  .onClick(() => {
                    this.vm.selectedPaymentMethod = payMethod.value
                  })
                }, (item: ISetting) => JSON.stringify(item))
              }
              .width('100%')
            }
            .cardFancy()
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .layoutWeight(1)
        .align(Alignment.Top)

        BottomBtn({
          text: '保存模板',
          onAction: () => {
            if (this.vm.pageMode === PageMode.EDIT) {
              this.vm.updateTemplate()
            } else {
              this.vm.addTemplate()
            }
          },
        })
      }
      .padding({ left: 16, right: 16, bottom: this.vm.windowModel.windowBottomPadding })
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  myTemplateBtn() {
    Row() {
      Text('我的模板')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([$r('sys.color.icon_secondary')])
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .padding({
      left: 12,
      right: 12,
      top: 9,
      bottom: 9,
    })
    .borderRadius(16)
    .onClick(() => {
      this.vm.jumpToTemplateList();
    })
  }

  @Builder
  titleBuilder(text: string) {
    Text(text)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .lineHeight(21)
      .textAlign(TextAlign.Start)
  }

  @Styles
  cardFancy() {
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}