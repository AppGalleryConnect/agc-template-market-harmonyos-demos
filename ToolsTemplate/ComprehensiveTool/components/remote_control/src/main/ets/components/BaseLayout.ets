import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { BaseLayoutVM } from '../viewmodel/BaseLayoutVM';
import { ScheduledUtil } from '../util/Index';
import { RemoteConstant } from '../constant/Index';
import { ControlInfo, RunMode } from '../model/Index';
import { getInstance } from './RouteModule';
import { UtilLog } from '@hw-agconnect/util-log';

@ComponentV2
export struct BaseLayout {
  @Local controlInfo: ControlInfo = AppStorageV2.connect<ControlInfo>(ControlInfo, () => new ControlInfo())!;
  vm: BaseLayoutVM = BaseLayoutVM.instance;
  // 定时器id
  timer: number = 0;
  // 空调遥控器状态改变时触发
  @Event onStatusChange: (data: ControlInfo) => void = () => {

  };
  // 空调名称变化
  @Event onNameChange: (data: ControlInfo) => void = () => {

  };
  // 组件完成加载，当组件完成加载时再去展示高亮区域
  @Event onShow: () => void = () => {

  };

  // 处理定时展示逻辑
  handleScheduled() {
    // 定时状态判断是否已经触发定时关
    if (this.controlInfo.isScheduled) {
      const targetTime = this.controlInfo.startTime + this.controlInfo.interval;
      const currentTime = new Date().getTime();
      // 到达定时时间将状态置为关机状态，定时状态清空
      if (targetTime <= currentTime) {
        this.controlInfo.switchStatus = false;
        this.controlInfo.isScheduled = false;
        this.controlInfo.interval = 0;
      }
    }
  }

  aboutToAppear(): void {
    this.handleScheduled();
    // 每间隔一分钟判断，是否到定时关的状态
    this.timer = setInterval(() => {
      this.handleScheduled();
      this.vm.upDateView(this.controlInfo);
    }, 60000);

    this.vm.upDateView(this.controlInfo);
    this.onShow();
    try {
      emitter.on('toSwitchClick', this.switchClick);
      emitter.on('toModeClick', this.modeClick);
      emitter.on('toSpeedClick', this.speedClick);
    } catch (e) {
      UtilLog.error(`emit click event failed with error ${JSON.stringify(e)}`);
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off('toSwitchClick', this.switchClick);
      emitter.off('toModeClick', this.modeClick);
      emitter.off('toSpeedClick', this.speedClick);
    } catch (e) {
      UtilLog.error(`click event off failed with error ${JSON.stringify(e)}`);
    }

    clearInterval(this.timer);
  }

  // 名称修改模态框
  @Builder
  NameEditBuilder() {
    Column() {
      Column() {
        TextInput({ text: this.vm.bakName })
          .width('100%')
          .height(40)
          .maxLength(50)
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .backgroundColor($r('sys.color.comp_background_secondary'))
          .onChange((res) => {
            this.vm.bakName = res;
          });

        Text('温馨提示：遥控器自定义方便您在首页快速找到该遥控器')
          .margin({ top: 12, bottom: 24 })
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular);

        Row({ space: 24 }) {
          Button('取消')
            .width('calc(50% - 12vp)')
            .height(40)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.font_emphasize'))
            .onClick(() => {
              this.vm.isNameShow = false;
            });
          Button('保存').width('calc(50% - 12vp)').height(40)
            .onClick(() => {
              if (this.vm.bakName) {
                this.controlInfo.name = this.vm.bakName;
                this.vm.isNameShow = false;
                this.onNameChange(this.controlInfo);
              } else {
                this.getUIContext().getPromptAction().showToast({ message: '请输入自定义名称！' });
              }

            });
        };
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .width('100%')
      .padding({ top: 12, left: 12, right: 12 })
      .borderRadius({ topLeft: 16, topRight: 16 })
      .height('100%');
    }.width('100%').padding({ left: 16, right: 16 });
  }

  // 定时模态框
  @Builder
  ScheduledBuilder() {
    Column() {
      Column() {
        Text('请选定时间后，对准空调按下定时')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium);

        Row() {
          Row() {
            Image($r('app.media.icon_minus')).width(24);
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.controlInfo.interval = ScheduledUtil.decreaseTime(this.controlInfo.interval);
          });

          Row({ space: 10 }) {
            Row({ space: 2 }) {
              Text(ScheduledUtil.formatElapsedTimeMinutesMinimized(this.controlInfo.interval)[0]).controlText();
              Text('时')
                .padding({ top: 2 })
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Caption_L'))
                .fontWeight(FontWeight.Regular);
            };

            Row({ space: 2 }) {
              Text(ScheduledUtil.formatElapsedTimeMinutesMinimized(this.controlInfo.interval)[1]).controlText();
              Text('分')
                .padding({ top: 2 })
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Caption_L'))
                .fontWeight(FontWeight.Regular);
            };
          };

          Row() {
            Image($r('app.media.icon_add')).width(24);
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.controlInfo.interval = ScheduledUtil.addTime(this.controlInfo.interval);
          });

        }
        .width(236)
        .margin({ top: 12, bottom: 24 })
        .height(48)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(4)
        .borderRadius(24)
        .border({ width: 1, color: $r('sys.color.interactive_click') });

        Text(`按照您的设定将会${ScheduledUtil.getTimeAfterMilliseconds(new Date(this.controlInfo.startTime),
          this.controlInfo.interval)}关闭您的空调`)
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_tertiary'))
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: 24 });

        Row({ space: 24 }) {
          Button('取消')
            .width('calc(50% - 12vp)')
            .height(40)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.font_emphasize'))
            .onClick(() => {
              this.vm.isScheduledShow = false;
            });
          Button('定时关').width('calc(50% - 12vp)').height(40).onClick(() => {
            this.controlInfo.isScheduled = true;
            this.vm.upDateView(this.controlInfo);
            this.onStatusChange(this.controlInfo);
            this.vm.isScheduledShow = false;
          });
        };
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .width('100%')
      .padding({ top: 12, left: 12, right: 12 })
      .borderRadius({ topLeft: 16, topRight: 16 })
      .height('100%');
    }.width('100%').padding({ left: 16, right: 16 });

  }

  build() {
    if (this.controlInfo) {
      Column() {
        Row({ space: 8 }) {
          Image($r('app.media.ic_white_left'))
            .size({ height: 40, width: 40 }).onClick(() => {
            getInstance().pop();
          });
        }.width('100%').justifyContent(FlexAlign.Start).padding({ left: 12 });

        Column({ space: 12 }) {
          Row({ space: 14 }) {
            Text(this.controlInfo.name)
              .constraintSize({ maxWidth: 260 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Title_L'))
              .fontWeight(FontWeight.Bold);
            Image($r('app.media.ic_pen')).width(19).height(19);
          }.padding({ left: 16, right: 16 })
          .bindSheet($$this.vm.isNameShow, this.NameEditBuilder, {
            title: {
              title: '自定义名称',
            },
            preferType: SheetType.CENTER,
            detents: [252, 252, SheetSize.MEDIUM],
            blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          })
          .onClick(() => {
            this.vm.isNameShow = true;
            this.vm.bakName = this.controlInfo.name;
          });

          if (this.controlInfo.switchStatus) {
            Row() {
              Column({ space: 32 }) {
                Row({ space: 12 }) {
                  Text('风速').commonInfoText();
                  Image(this.vm.windSpeedIcon).width(24);
                };

                Row({ space: 12 }) {
                  Text('风向').commonInfoText();
                  Image(this.vm.windDirectionIcon).width(24);
                };

                Row({ space: 12 }) {
                  Text('扫风').commonInfoText();
                  Image(this.vm.windModeIcon).width(24);
                };

                if (this.controlInfo.isScheduled) {
                  Row({ space: 12 }) {
                    Image($r('app.media.icon_clock')).width(24);
                    Text(this.vm.scheduledStr).commonInfoText();
                  };
                }

              }.alignItems(HorizontalAlign.Start).layoutWeight(1);

              Column() {
                Row({ space: 4 }) {
                  Text(this.controlInfo.runMode === RunMode.AUTO ? 'NA' : this.controlInfo.temperature.toString())
                    .fontSize($r('sys.float.Display_S'))
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold);
                  Text('℃').padding({ bottom: 20 }).commonInfoText();
                }
                .width(120)
                .height(120)
                .borderRadius(60)
                .border({ width: 2, color: '#FFFFFF' })
                .justifyContent(FlexAlign.Center);

                Text(this.vm.runModeStr).lineHeight(22).commonInfoText().margin({ top: 16 });
                Image(this.vm.runModeIcon).width(24).margin({ top: 4 });
              };

            }.width('100%').padding({ left: 28, right: 28 }).alignItems(VerticalAlign.Top);
          } else {
            Column() {
              Column({ space: 24.5 }) {
                Image($r('app.media.ic_status_close')).width(58.5);
                Text('电源已关闭').fontSize($r('sys.float.Title_S')).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
              };
            }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center);
          }

        }
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 8 })
        .height(this.vm.isLowHeight ? 270 : 302)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

        Column() {
          Text('遥控区')
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .lineHeight(27);
          Image($r('app.media.icon_power')).width(44).margin({ top: 14 }).id('switchGuideId').onClick(() => {
            this.switchClick();
          });

          Row() {
            Row() {
              Image($r('app.media.icon_add')).width(24);
            }.temperatureExtend()
            .onClick(() => {
              if (this.controlInfo.switchStatus) {
                // 自动模式无法调节温度
                if (this.controlInfo.runMode === RunMode.AUTO) {
                  this.getUIContext().getPromptAction().showToast({ message: '该模式下无法调节温度' });
                  return;
                }
                if (this.controlInfo.temperature < RemoteConstant.MAX_TEMPERATURE) {
                  this.controlInfo.temperature++;
                }
              }

            });

            Text('温度').controlText();

            Row() {
              Image($r('app.media.icon_minus')).width(24);
            }.temperatureExtend()
            .onClick(() => {
              if (this.controlInfo.switchStatus) {
                if (this.controlInfo.runMode === RunMode.AUTO) {
                  this.getUIContext().getPromptAction().showToast({ message: '该模式下无法调节温度' });
                  return;
                }
                if (this.controlInfo.temperature > RemoteConstant.MIN_TEMPERATURE) {
                  this.controlInfo.temperature--;
                }
              }
            });

          }.width('100%').justifyContent(FlexAlign.SpaceBetween);


          Grid() {
            GridItem() {
              Column({ space: 4 }) {
                Column() {
                  Image($r('app.media.icon_switchover_border')).width(24);
                }.id('modeButtonId').commonBtnExtend()
                .onClick(() => {
                  this.modeClick();
                });

                Text('模式').controlText();
              };
            };

            GridItem() {
              Column({ space: 4 }) {
                Column() {
                  Image($r('app.media.icon_ict_fan')).width(24);
                }.id('speedButtonId').commonBtnExtend()
                .onClick(() => {
                  this.speedClick();
                });

                Text('风速').controlText();
              };
            };

            GridItem() {
              Column({ space: 4 }) {
                Column() {
                  Image($r('app.media.icon_sweeping')).width(24);
                }.commonBtnExtend()
                .onClick(() => {
                  if (this.controlInfo.switchStatus) {
                    this.controlInfo.windMode = this.vm.changeWindMode(this.controlInfo.windMode);
                    this.onStatusChange(this.controlInfo);
                    this.vm.upDateView(this.controlInfo);
                  }
                });

                Text('扫风').controlText();
              };
            };

            GridItem() {
              Column({ space: 4 }) {
                Column() {
                  Image($r('app.media.icon_wind_direction')).width(24);
                }.commonBtnExtend()
                .onClick(() => {
                  if (this.controlInfo.switchStatus) {
                    this.controlInfo.windDirection = this.vm.changeWindDirection(this.controlInfo.windDirection);
                    this.onStatusChange(this.controlInfo);
                    this.vm.upDateView(this.controlInfo);
                  }
                });

                Text('风向').controlText();
              };
            };


            GridItem() {
              Column({ space: 4 }) {
                Column() {
                  Image($r('app.media.icon_alarm_clock')).width(24);
                }.commonBtnExtend()
                .onClick(() => {
                  if (this.controlInfo.switchStatus) {
                    if (this.controlInfo.isScheduled) {
                      this.controlInfo.isScheduled = false;
                      this.vm.upDateView(this.controlInfo);
                      this.onStatusChange(this.controlInfo);
                    } else {
                      this.vm.isScheduledShow = true;
                      this.controlInfo.interval = 0;
                      this.controlInfo.startTime = new Date().getTime();
                    }
                  }
                });

                Text(this.controlInfo.isScheduled ? '取消定时' : '定时').controlText();
              };
            }.bindSheet($$this.vm.isScheduledShow, this.ScheduledBuilder, {
              title: {
                title: '定时',
              },
              preferType: SheetType.CENTER,
              detents: [311, 311, SheetSize.MEDIUM],
              blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
            });

          }.columnsTemplate('1fr 1fr 1fr').rowsGap(12).margin({ top: 24 }).columnsGap(24);

        }
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 32, topRight: 32 })
        .padding({ top: 24, left: 36, right: 36 })
        .layoutWeight(1);
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .height('100%')
      .backgroundColor($r('sys.color.background_emphasize'))
      .onSizeChange((oldSize: SizeOptions, newSize: SizeOptions) => {
        // 适配阔折叠
        const realHeight = newSize.height as number;
        if (realHeight < RemoteConstant.DESIGN_HEIGHT) {
          this.vm.isLowHeight = true;
        } else {
          this.vm.isLowHeight = false;
        }

      });
    }

  }

  // 点击开关
  private switchClick = () => {
    this.controlInfo.switchStatus = !this.controlInfo.switchStatus;
    // 关闭控制时取消定时状态
    if (!this.controlInfo.switchStatus) {
      this.controlInfo.isScheduled = false;
      this.controlInfo.interval = 0;
    }
    this.onStatusChange(this.controlInfo);
    this.vm.upDateView(this.controlInfo);
  };
  // 点击模式
  private modeClick = () => {
    if (this.controlInfo.switchStatus) {
      this.controlInfo.runMode = this.vm.changeMode(this.controlInfo.runMode);
      this.onStatusChange(this.controlInfo);
      this.vm.upDateView(this.controlInfo);
    }
  };
  // 点击风速
  private speedClick = () => {
    if (this.controlInfo.switchStatus) {
      this.controlInfo.windSpeed = this.vm.changeWindSpeed(this.controlInfo.windSpeed);
      this.onStatusChange(this.controlInfo);
      this.vm.upDateView(this.controlInfo);
    }
  };
}

@Extend(Column)
function commonBtnExtend() {
  .width('100%')
  .height(48)
  .backgroundColor($r('sys.color.background_secondary'))
  .borderRadius(12)
  .justifyContent(FlexAlign.Center);
}

@Extend(Text)
function controlText() {
  .fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
}

@Extend(Row)
function temperatureExtend() {
  .width(56)
  .height(40)
  .borderRadius(12)
  .border({ width: 1, color: '#000000' })
  .justifyContent(FlexAlign.Center);
}

@Extend(Text)
function commonInfoText() {
  .fontSize($r('sys.float.Subtitle_M')).fontColor('#FFFFFF').fontWeight(FontWeight.Medium);
}
