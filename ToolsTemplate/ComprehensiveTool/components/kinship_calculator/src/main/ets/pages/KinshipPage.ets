import { common } from '@kit.AbilityKit'
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { Sex } from '../common/Constant'
import { setContext } from '../common/Context'
import { relationship } from '../utils/Relationship'
import { ShipPageVM } from '../viewmodel/ShipPageVM'
import { FileService } from '../utils/Service'

@ComponentV2
export struct KinshipPage {
  vm: ShipPageVM = ShipPageVM.instance
  @Local numbers2: string[] = ['夫', '父', '兄', '子', '妻', '母', '姐', '女', '弟', '妹', 'AC'];
  layoutOptions3: GridLayoutOptions = {
    regularSize: [1, 1],
    onGetRectByIndex: (index: number) => {
      if (index === 0) {
        return [0, 0, 1, 1];
      } else if (index === 1) {
        return [0, 1, 1, 1];
      } else if (index === 2) {
        return [0, 2, 1, 1];
      } else if (index === 3) {
        return [0, 3, 1, 1];
      } else if (index === 4) {
        return [1, 0, 1, 1];
      } else if (index === 5) {
        return [1, 1, 1, 1];
      } else if (index === 6) {
        return [1, 2, 1, 1];
      } else if (index === 7) {
        return [1, 3, 1, 1];
      } else if (index === 8) {
        return [2, 0, 1, 1];
      } else if (index === 9) {
        return [2, 1, 1, 1];
      } else if (index === 10) {
        return [2, 2, 1, 2];
      } else {
        return [2, 2, 1, 2];
      }
    },
  };

  aboutToAppear(): void {
    setContext(this.getUIContext().getHostContext() as common.UIAbilityContext)
    FileService.context = this.getUIContext().getHostContext() as common.UIAbilityContext
    FileService.getFileData()
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          titleBuilder('选择性别')
          Row() {
            this.sexBuilder(Sex.MAN)
            this.sexBuilder(Sex.WOMAN)
          }
          .width('100%')
          .margin({ bottom: 8 })

          titleBuilder('输入关系')
          Row() {
            Text(this.vm.inputText ? this.vm.inputText : this.vm.inputPlaceholder)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .padding({ left: 12, right: 12 })
          .margin({ bottom: 8 })

          titleBuilder('计算结果')
          Row() {
            Text(this.vm.outputText ? this.vm.outputText : this.vm.outputPlaceholder)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .padding({ left: 12, right: 12 })
        }
        .padding({ left: 16, right: 16 })

        //按钮区
        Column() {
          Column() {
            Grid(undefined, this.layoutOptions3) {
              ForEach(this.numbers2, (day: string) => {
                GridItem() {
                  if (day === 'AC') {
                    Button() {
                      Row() {
                        SymbolGlyph($r('sys.symbol.trash'))
                          .fontSize(24)
                          .fontColor([$r('sys.color.icon_emphasize')])
                          .margin({ right: 8 })
                        Text('AC')
                          .fontSize($r('sys.float.Body_L'))
                          .fontColor($r('sys.color.font_emphasize'))
                          .fontWeight(FontWeight.Medium)
                      }.alignItems(VerticalAlign.Center)
                    }
                    .width('100%')
                    .height(40)
                    .backgroundColor(Color.White)
                    .fontColor($r('sys.color.font_primary'))
                    .onClick(() => {
                      this.vm.clear()
                    })
                  } else {
                    Button(day)
                      .width('100%')
                      .backgroundColor(Color.White)
                      .fontColor($r('sys.color.font_primary'))
                      .enabled(day === '夫' ? this.vm.showManButton : day === '妻' ? this.vm.showWomanButton : true)
                      .onClick(() => {
                        this.vm.handleInput(day, this.getUIContext())
                      })
                  }
                }
                .height('100%')
                .width('100%')
              }, (day: string) => day)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr 1fr')
            .columnsGap(12)
            .rowsGap(8)
            .width('100%')
            .height(144)
            .margin({ bottom: 24 })

            Row() {
              Button() {
                Row() {
                  SymbolGlyph($r('sys.symbol.arrow_left_arrow_right'))
                    .fontSize(24)
                    .fontColor([$r('sys.color.icon_emphasize')])
                    .margin({ right: 8 })
                  Text('互查')
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('sys.color.font_emphasize'))
                    .fontWeight(FontWeight.Medium)
                }
                .alignItems(VerticalAlign.Center)
              }
              .width('50%')
              .height(40)
              .backgroundColor(Color.White)
              .fontColor($r('sys.color.font_primary'))
              .margin({ right: 8 })
              .onClick(() => {
                this.vm.reverse = !this.vm.reverse
                if (this.vm.reverse) {
                  this.vm.outputText = relationship({
                    text: this.vm.outputText,
                    target: '',
                    sex: this.vm.sex,
                    reverse: this.vm.reverse,
                    mode: 'default',
                    optimal: false,
                  })[0]
                } else {
                  this.vm.outputText = relationship({
                    text: this.vm.inputText,
                    target: '',
                    sex: this.vm.sex,
                    reverse: this.vm.reverse,
                    mode: 'default',
                    optimal: false,
                  })[0]
                }
                if (!this.vm.outputText) {
                  promptAction.showToast({ message: '暂无计算结果！' });
                }
              })

              Button() {
                Row() {
                  SymbolGlyph($r('sys.symbol.calculator'))
                    .fontSize(24)
                    .fontColor([$r('sys.color.font_on_primary')])
                    .margin({ right: 8 })
                  Text('计算')
                    .fontSize($r('sys.float.Body_L'))
                    .fontColor($r('sys.color.font_on_primary'))
                    .fontWeight(FontWeight.Medium)
                }
                .alignItems(VerticalAlign.Center)
              }
              .width('50%')
              .height(40)
              .backgroundColor($r('sys.color.comp_background_emphasize'))
              .fontColor($r('sys.color.font_primary'))
              .onClick(() => {
                this.vm.reverse = false
                this.vm.outputText = relationship({
                  text: this.vm.inputText,
                  target: '',
                  sex: this.vm.sex,
                  reverse: this.vm.reverse,
                  mode: 'default',
                  optimal: false,
                })[0]
                if (!this.vm.outputText) {
                  promptAction.showToast({ message: '暂无计算结果！' });
                }
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .padding({ left: 16, right: 16 })
        }
        .position({ bottom: 0 })
        .width('100%')
      }
      .height('100%')
    }
    .title('亲属称呼换算')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  sexBuilder(sex: Sex) {
    Row() {
      Text(sex === Sex.MAN ? '男' : '女')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.sex === sex ? Color.White : 'rgba(0, 0, 0, 0.9)')
    }
    .width(120)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .borderRadius(20)
    .margin({ right: 12 })
    .backgroundColor(this.vm.sex === sex ? 'rgba(10, 89, 247, 1)' : Color.White)
    .onClick(() => {
      this.vm.changeSex(sex)
    })
  }
}

@Builder
function titleBuilder(title: string) {
  Row() {
    Text(title)
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
  }
  .width('100%')
  .padding({ top: 24, bottom: 8 })
  .margin({ bottom: 8 })
}

@Builder
export function KinshipPageBuilder() {
  KinshipPage()
}