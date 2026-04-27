import { IGoods } from 'lib_foundation'
import { GoodsPageVM } from '../viewModels/GoodsPageVM'
import { CommonCounter } from 'module_base'

@Builder
export function GoodsPageBuilder() {
  GoodsPage()
}

@Entry
@ComponentV2
struct GoodsPage {
  vm: GoodsPageVM = GoodsPageVM.instance
  controllerSearch: SearchController = new SearchController()
  controllerInputLong: TextInputController = new TextInputController()
  controllerInputWidth: TextInputController = new TextInputController()
  controllerInputHeight: TextInputController = new TextInputController()

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Row() {
              Image($r('app.media.ic_warning_1'))
                .width(12)
                .height(12)
              Text('请如实填写，因填写不实导致相关责任损失的，有您自行承担')
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .width('100%')
            .margin({ top: 8, bottom: 12 })

            Column() {
              Text('热门类型')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))
                .margin({ bottom: 8 })
              Flex({ wrap: FlexWrap.Wrap }) {
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
                  .backgroundColor(this.vm.selectedGoods?.id === goods.id ? '#0A59F7' : '#C4C4C4')
                  .margin((index + 1) % 4 === 0 ? { bottom: 8 } : { bottom: 8, right: 5 })
                  .onClick(() => {
                    this.vm.selectedGoods = goods
                  })
                }, (item: IGoods[]) => JSON.stringify(item))
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .cardStyles()

            Row() {
              this.titleBuilder('预估重量')
              CommonCounter({
                weight: this.vm.weight,
                unit: 'kg',
                onChange: (value) => {
                  this.vm.weight = value
                },
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .cardStyles()

            Column() {
              Row() {
                this.titleBuilder('总体积')
                Row() {
                  Text('补充体积预估费用会更准确')
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_tertiary'))
                    .margin({ right: 4 })
                  Toggle({ type: ToggleType.Switch, isOn: true })
                    .onChange((value) => {
                      this.vm.showVolume = value
                    })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              if (this.vm.showVolume) {
                Row() {
                  CommonCounter({
                    weight: this.vm.volume,
                    unit: 'm³',
                    onChange: (value) => {
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
                    .padding({ top: 0, bottom: 0 })
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
                    .padding({ top: 0, bottom: 0 })
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
                    .padding({ top: 0, bottom: 0 })
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
              CommonCounter({
                weight: this.vm.count,
                unit: '件',
                onChange: (value) => {
                  this.vm.count = value
                },
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .cardStyles()
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .layoutWeight(1)

      Row() {
        Button('保存')
          .width('100%')
          .onClick(() => {
            this.vm.save()
          })
      }
      .width('100%')
      .padding({ left: 28, right: 28 })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .backgroundColor('#F1F3F5')
    .title('物品信息')
    .onShown(() => {
      this.vm.init()
    })
  }

  @Styles
  cardStyles(){
    .padding(12)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .borderRadius(8)
  }

  @Builder
  titleBuilder(text: string) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
  }
}