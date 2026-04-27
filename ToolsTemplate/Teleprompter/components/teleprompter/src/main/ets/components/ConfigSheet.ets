import { emitter } from '@kit.BasicServicesKit';
import { PrompterController } from '../controller/PrompterController';
import { PrompterConfig, PrompterConfigOptions } from '../model/PrompterConfigModel';
import hilog from '@ohos.hilog';


@ComponentV2
struct colorListBuilder {
  @Param colorList: ResourceStr[] = []
  @Param color: ResourceStr = ''
  @Event changeColor: (color: ResourceStr) => void = (color: ResourceStr) => {
  }

  build() {
    Row({ space: 20 }) {
      ForEach(this.colorList, (item: ResourceStr) => {
        Stack() {
          Row()
            .width(34)
            .height(34)
            .borderRadius(17)
            .border({ width: 1, color: '#0A59F7' })
            .visibility(item === this.color ? Visibility.Visible : Visibility.Hidden)
          Row()
            .width(30)
            .height(30)
            .borderRadius(15)
            .backgroundColor(item)
        }
        .align(Alignment.Center)
        .onClick(() => {
          if (item !== this.color) {
            this.changeColor(item)
          }
        })
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@ComponentV2
struct sliderBuilder {
  @Param sliderRange: number[] = []
  @Param sliderValue: number = 0
  @Param step: number = 1
  @Event changeValue: (value: number) => void = (value: number) => {
  }

  build() {
    Row({ space: 20 }) {
      Slider({
        value: this.sliderValue,
        min: this.sliderRange[0],
        max: this.sliderRange[1],
        style: SliderStyle.OutSet,
        step: this.step
      })
        .blockColor('#0A59F7')
        .layoutWeight(1)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.changeValue(value)
        })

      Text(this.sliderValue.toString()).fontSize(14).fontColor('rgba(0, 0, 0, 0.60)').width(28)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@ComponentV2
export struct ConfigSheet {
  @Local showSheet: boolean = false
  @Local dialogId: number = 0
  @Param @Require configList: PrompterConfigOptions
  @Param @Require config: PrompterConfig
  @Param @Require isLandscapeMode: boolean
  @Param @Require isShowConfigSheet: boolean
  @Param isForSuspend: boolean = false
  @Event closeSheet: () => void = () => {
  };
  @Event openSuspend: () => void = () => {
  };
  prompterController: PrompterController = PrompterController.instance;

  aboutToAppear() {
    try {
      emitter.on('showConfigSheet', () => {
        if (this.isLandscapeMode) {
          this.openLandscapeDialog()
        } else {
          this.showSheet = true
        }
      })
      emitter.on('closeConfigSheet', () => {
        if (this.isLandscapeMode) {
          this.getUIContext().getPromptAction().closeCustomDialog(this.dialogId)
        } else {
          this.showSheet = false
        }
      })
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off('showConfigSheet')
      emitter.off('closeConfigSheet')
    } catch (e) {
    }
  }

  openLandscapeDialog() {
    this.getUIContext().getPromptAction().openCustomDialog({
      builder: () => this.sheetLandscapeBuilder(),
      width: '50%',
      height: '100%',
      transition: TransitionEffect.translate({ x: '50%', y: 0, z: 0 }).animation({ duration: 300, curve: Curve.Ease }),
      alignment: DialogAlignment.TopEnd,
      cornerRadius: 0,
      maskColor: Color.Transparent
    })
      .then((id) => {
        this.dialogId = id;
      });
  }

  @Builder
  suspendItemBuilder() {
    Column() {
      Row({ space: 20 }) {
        Text('快进快退')
          .fontSize(14)
          .fontColor('rgba(0, 0, 0, 0.90)')
          .width(56)
        sliderBuilder({
          sliderRange: this.configList.fastOrBackTimeList,
          sliderValue: this.config.fastOrBackTime,
          changeValue: (value) => {
            this.config.fastOrBackTime = value
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 37 })

      Row() {
        Column({ space: 15 }) {
          Text('镜像模式')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.90)')
          Text('开启后，文字在屏幕上反向显示，通过镜片反射后呈正向显示')
            .fontSize(10)
            .fontColor('rgba(0, 0, 0, 0.60)')
            .constraintSize({ maxWidth: '70%' })
        }
        .alignItems(HorizontalAlign.Start)

        Toggle({ type: ToggleType.Switch, isOn: this.config.isFlip }).onChange((value: boolean) => {
          this.config.isFlip = value
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 37 })

      Text('保存并开启悬浮')
        .width(210)
        .height(40)
        .fontSize(14)
        .fontColor('#fff')
        .backgroundColor('#0A59F7')
        .borderRadius(20)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.openSuspend()
        })
    }
  }

  @Builder
  sheetContent() {
    Scroll() {
      Column({ space: 36 }) {
        Row({ space: 18 }) {
          Text('背景颜色')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.90)')
          colorListBuilder({
            colorList: this.configList.backgroundColorList,
            color: this.config.backgroundColor,
            changeColor: (color) => {
              this.config.backgroundColor = color
              this.prompterController.setStatusFontColor()
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 18 }) {
          Text('字体颜色')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.90)')
          colorListBuilder({
            colorList: this.configList.fontColorList,
            color: this.config.fontColor,
            changeColor: (color) => {
              this.config.fontColor = color
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 20 }) {
          Text('字体大小')
            .fontSize(14)
            .width(56)
            .fontColor('rgba(0, 0, 0, 0.90)')
          sliderBuilder({
            sliderRange: this.configList.fontSizeList,
            sliderValue: this.config.fontSize,
            step: 2,
            changeValue: (value) => {
              hilog.error(0x0000, 'ConfigSheet', 'this.config.fontSize' + value);
              this.config.fontSize = value
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 20 }) {
          Text('语速调节')
            .fontSize(14)
            .width(56)
            .fontColor('rgba(0, 0, 0, 0.90)')
          sliderBuilder({
            sliderRange: this.configList.speechRateList,
            sliderValue: this.config.speechRate,
            changeValue: (value) => {
              this.config.speechRate = value
              this.prompterController.start()
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 20 }) {
          Text('倒计时 ')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.90)')
            .width(56)
          sliderBuilder({
            sliderRange: this.configList.countdownList,
            sliderValue: this.config.countdown,
            changeValue: (value) => {
              this.config.countdown = value
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.isForSuspend) {
          this.suspendItemBuilder()
        }
      }.margin({ top: 24 })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .padding({ left: 8, right: 8 })
    .layoutWeight(1)
  }

  @Builder
  sheetBuilder() {
    Column() {
      Row() {
        Text('提词板设置')
          .fontSize(20)
          .fontColor('#000')
          .fontWeight(FontWeight.Bold)

        Image($r('app.media.sheet_close'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.closeSheet()
            this.showSheet = false
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      this.sheetContent()
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 23,
      bottom: 40
    })
  }

  @Builder
  sheetLandscapeBuilder() {
    Column() {
      Row() {
        Text('提词板设置')
          .fontSize(20)
          .fontColor('#000')
          .fontWeight(FontWeight.Bold)

        Image($r('app.media.sheet_close'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.getUIContext().getPromptAction().closeCustomDialog(this.dialogId)
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      this.sheetContent()
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16,
      top: 23,
      bottom: 20
    })
  }

  build() {
    Row() {
    }
    .bindSheet($$this.showSheet, this.sheetBuilder(), {
      height: this.isForSuspend ? 600 : 450,
      backgroundColor: $r('sys.color.background_secondary'),
      showClose: false,
      maskColor: $r('sys.color.mask_fourth'),
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        sheetDismiss.dismiss()
        this.closeSheet()
      }
    })
  }
}
