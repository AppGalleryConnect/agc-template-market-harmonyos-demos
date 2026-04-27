import { LengthMetrics } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast'
import { IGoods, CommonStepper, CommonTitle, BottomBtn } from 'lib_foundation'
import { GoodsPageVM } from '../viewModels/GoodsPageVM'

@Builder
export function GoodsPageBuilder() {
  GoodsPage()
}

@Entry
@ComponentV2
struct GoodsPage {
  vm: GoodsPageVM = new GoodsPageVM();
  controllerSearch: SearchController = new SearchController();
  controllerInputLong: TextInputController = new TextInputController();
  controllerInputWidth: TextInputController = new TextInputController();
  controllerInputHeight: TextInputController = new TextInputController();

  aboutToAppear(): void {
    // 查询物品信息
    this.vm.init();
  }

  build() {
    NavDestination() {
      CommonTitle({
        title: '物品信息',
      })
      Column() {
        Scroll() {
          Column() {
            Row() {
              Image($r('app.media.ic_warning_1'))
                .width(12)
                .height(12)
              Text('请如实填写，因填写不实导致相关责任损失的，由您自行承担')
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
                .lineHeight(13)
            }
            .width('100%')
            .margin({ top: 8 })

            Column({ space: 8 }) {
              this.titleBuilder('物品类型')
              Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
                ForEach(this.vm.goodsList, (goods: IGoods, index: number) => {
                  Row() {
                    Text(goods.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor(this.vm.selectedGoods?.id === goods.id ? Color.White : $r('sys.color.font_primary'))
                  }
                  .width(72)
                  .height(28)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)
                  .borderRadius(8)
                  .backgroundColor(this.vm.selectedGoods?.id === goods.id ?
                    $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary')
                  )
                  .onClick(() => {
                    this.vm.selectedGoods = goods;
                    this.vm.weight = goods.weight;
                  })
                }, (item: IGoods[]) => JSON.stringify(item))
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .cardStyles()

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
            .cardStyles()

            Column({ space: 8 }) {
              Row() {
                this.titleBuilder('总体积')
                Row() {
                  Text('补充体积预估费用会更准确')
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_tertiary'))
                    .margin({ right: 4 })
                  Toggle({ type: ToggleType.Switch, isOn: $$this.vm.showVolume })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              if (this.vm.showVolume) {
                Row() {
                  CommonStepper({
                    value: this.vm.volume,
                    unit: 'm³',
                    min: 1,
                    max: 99,
                    buttonType: ButtonType.Circle,
                    isBorder: false,
                    onChange: (value) => {
                      if (value <= 0) {
                        return;
                      }
                      if (value > 99) {
                        ToastDialog.showToast({
                          message: '包裹总体积不能超过99立方米',
                          toastAlignment: DialogAlignment.Center,
                          toastOption: {
                            toastBackgroundColor: '#99000000',
                            toastBackgroundBlur: BlurStyle.NONE,
                          },
                          fontType: {
                            fontColor: '#FFFFFF'
                          }
                        })
                        return;
                      }
                      this.vm.volume = value
                    },
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.End)
                .margin({ top: 12, bottom: 12 })

                Row() {
                  TextInput({ text: this.vm.length, placeholder: '长 cm', controller: this.controllerInputLong })
                    .type(InputType.Number)
                    .placeholderColor($r('sys.color.font_secondary'))
                    .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                    .backgroundColor('rgba(196,196,196,0.2)')
                    .width(72)
                    .height(28)
                    .padding({ left: 12, top: 0, bottom: 0 })
                    .onChange((value) => {
                      this.vm.length = value
                      this.vm.calcVolume()
                    })
                  Text('*')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ left: 18, right: 18 })
                  TextInput({ text: this.vm.width, placeholder: '宽 cm', controller: this.controllerInputWidth })
                    .type(InputType.Number)
                    .placeholderColor($r('sys.color.font_secondary'))
                    .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                    .backgroundColor('rgba(196,196,196,0.2)')
                    .width(72)
                    .height(28)
                    .padding({ left: 12, top: 0, bottom: 0 })
                    .onChange((value) => {
                      this.vm.width = value
                      this.vm.calcVolume()
                    })
                  Text('*')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.font_primary'))
                    .margin({ left: 18, right: 18 })
                  TextInput({ text: this.vm.height, placeholder: '高 cm', controller: this.controllerInputHeight })
                    .type(InputType.Number)
                    .placeholderColor($r('sys.color.font_secondary'))
                    .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                    .backgroundColor('rgba(196,196,196,0.2)')
                    .width(72)
                    .height(28)
                    .padding({ left: 12, top: 0, bottom: 0 })
                    .onChange((value) => {
                      this.vm.height = value
                      this.vm.calcVolume()
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .cardStyles()

            Row() {
              this.titleBuilder('件数')

              CommonStepper({
                value: this.vm.count,
                unit: '件',
                min: 1,
                max: 999,
                buttonType: ButtonType.Circle,
                isBorder: false,
                onChange: (value) => {
                  if (value <= 0) {
                    return;
                  }
                  if (value > 999) {
                    return;
                  }
                  this.vm.count = value
                },
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .cardStyles()
          }
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding
          })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .layoutWeight(1)

      BottomBtn({
        text: '保存',
        paddingSize: { left: 28, right: 28, bottom: this.vm.windowModel.windowBottomPadding },
        onAction: () => {
          this.vm.save()
        }
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Styles
  cardStyles(){
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ top: 12 })
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
}