import { UserInfo } from 'base_common';
import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  FontModel,
  NavHeaderBar,
  TaskCoins,
  TaskList
} from 'common'
import { emitter } from '@kit.BasicServicesKit';
import { SignComp } from '../comp/SignComp'
import { AppStorageV2 } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common';

class TimeCoins {
  coin: number = 0;
  time: number = 0;
  isReceive: number = 0
}

AppStorage.setOrCreate('bookFinished', 0)

@ComponentV2
export struct WelfareCenter {
  @Local bookCoins: number = 0;
  @Local isLogin: boolean = false;
  @Local userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
  @Consumer('userInfo') userInfo: UserInfo | undefined = undefined;
  @Consumer('index') index: number = 0;
  @Local taskT: TaskList = AppStorageV2.connect(TaskList, 'TaskList', () => new TaskList())!
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  private stages: Array<TimeCoins> = [
    { coin: 50, time: 12, isReceive: 0 },
    { coin: 100, time: 37, isReceive: 0 },
    { coin: 150, time: 62, isReceive: 0 },
    { coin: 300, time: 88, isReceive: 0 }
  ];

  aboutToAppear(): void {
    this.loadUserInfo();
    try {
      emitter.on(Constants.COINS_CHANGE, () => {
        this.loadUserInfo();
      });
    } catch (error) {
      console.error('Failed to emitter on coins change. Cause: ' + JSON.stringify(error));
    }

    try {
      emitter.on(Constants.COINS_AD, () => {
        this.loadUserInfo();
      });
    } catch (error) {
      console.error('Failed to emitter on coins ad. Cause: ' + JSON.stringify(error));
    }
    this.userInfo = AppStorage.get('userInfo') as UserInfo;
  }

  loadUserInfo() {
    const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
    if (userInfoFromStorage) {
      this.bookCoins = typeof userInfoFromStorage.bookCoins === 'number' ? userInfoFromStorage.bookCoins : 100;
      this.isLogin = true;
    } else {
      this.bookCoins = 0;
      this.isLogin = false;
    }
  }

  @Builder
  showBookCoins() {
    Column() {
      Text('我的书币')
        .fontSize(this.fontModel.getFg(12))

      Text(this.bookCoins.toString())
        .fontSize(this.fontModel.getFg(38))
        .height(51)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 4, bottom: 4 })

      Text('金币明细>金币规则')
        .fontSize(this.fontModel.getFg(12))
        .fontColor($r('sys.color.mask_secondary'))
    }
    .margin({ top: 18, bottom: 18 })
    .width(Constants.FULL_SIZE)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  getReadTimeCoins() {
    Column() {
      Text('阅读赚书币')
        .width(Constants.FULL_SIZE)
        .textAlign(TextAlign.Start)
        .margin({
          bottom: 12
        })

      Stack() {
        Progress({ value: this.userInfo?.totalReading, total: 100, type: ProgressType.Linear })
          .width(Constants.FULL_SIZE)
          .color('#E84026')
          .style({
            enableScanEffect: false,
          })
          .privacySensitive(true)
          .margin({ top: 4 })
        Row() {
          ForEach(this.stages, (item: TimeCoins) => {
            Column() {
              Row() {
                Image($r('app.media.time_coins'))
                  .height(12)
                  .width(12)
                Text(item.coin.toString())
                  .fontSize(this.fontModel.getFg(10))
              }
              .opacity((this.userInfo?.totalReading || 0) >= item.time ? 1 : 0.4)
              .padding({
                left: 4,
                right: 4,
                top: 2,
                bottom: 2
              })
              .borderRadius(4)
              .backgroundColor('#FDF1DB')
              .margin({ bottom: 6 })
              .onClick(() => {
                let promptAction = this.getUIContext().getPromptAction();
                if ((this.userInfo?.totalReading || 0) >= item.time && item.coin < 1) {
                  this.bookCoins += item.coin
                  item.isReceive++
                  promptAction.showToast({ message: '已领取成功' })
                } else if (item.isReceive > 0) {
                  promptAction.showToast({ message: '您已领取' })
                }
              })

              Image((this.userInfo?.totalReading || 0) >= item.time ? $r('app.media.circle_red') :
                $r('app.media.circle_grey'))
                .height(9)
                .width(9)
                .margin({ bottom: 4 })
              Text() {
                Span(item.time.toString())
                Span('分钟')
              }
              .fontSize(this.fontModel.getFg(12))
              .fontColor($r('sys.color.font_secondary'))
              .opacity((this.userInfo?.totalReading || 0) >= item.time ? 1 : 0.4)
            }
            .width('25%')
          }, (item: TimeCoins) => item.time + new Date().toString())

        }
        .width(Constants.FULL_SIZE)
      }
    }
    .layoutWeight(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 0 : 1)
    .width(this.curBreakpoint.value === BreakpointTypeEnum.SM ? Constants.FULL_SIZE : 'auto')
    .padding({
      left: 12,
      right: 12,
      top: 15,
      bottom: 15
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
  }

  @Builder
  getTaskCoins() {
    Column() {
      Text('做任务 赚金币')
        .fontSize(this.fontModel.getFg(16))
        .fontWeight(FontWeight.Medium)
        .width(Constants.FULL_SIZE)
        .margin({ bottom: 16 })
      ForEach(this.taskT.taskList, (item: TaskCoins) => {
        Row() {
          Column() {
            Row() {
              Text(item.title)
                .fontSize(this.fontModel.getFg(12))
              Text() {
                Span('+')
                Span(item?.coins?.toString())
              }
              .fontSize(this.fontModel.getFg(12))
              .fontColor('#ED6F21')
            }
            .margin({ bottom: 4 })

            Row() {
              Text(item.description)
                .fontSize(this.fontModel.getFg(12))
              if ((item?.allFinish || 1) > 1) {
                Text() {
                  Span('(')
                  Span(item.finished?.toString())
                  Span('/')
                  Span(item.allFinish?.toString())
                  Span(')')
                }
                .fontSize(this.fontModel.getFg(12))
              }
            }
          }
          .alignItems(HorizontalAlign.Start)

          Button(item.finished < item.allFinish ? item.buttonOn : item.buttonOff,
            { stateEffect: item.finished < item.allFinish ? true : false })
            .fontSize(fp2pxUtil(12))
            .height(30)
            .padding({ left: 15, right: 15 })
            .fontColor($r('sys.color.font_on_primary'))
            .enabled(item.finished < item.allFinish ? true : false)
            .backgroundColor('#ED6F21')
            .onClick(() => {
              if (item.event) {
                item.event(item);
              }
            })
        }
        .width(Constants.FULL_SIZE)
        .margin({ bottom: 8 })
        .justifyContent(FlexAlign.SpaceBetween)
      }, (item: TaskCoins) => item.title + new Date().toString())
    }
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 8
    })
    .width(Constants.FULL_SIZE)
    .borderRadius(12)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          Image($r('app.media.welfare_bg'))
            .width(Constants.FULL_SIZE)
            .backgroundColor($r('sys.color.comp_background_gray'))
          Column() {
            NavHeaderBar({
              title: $r('app.string.welfare_center'),
              hasBackButton: true,
              hasBgColor: false,
            })

            Scroll() {
              Column({ space: 12 }) {
                this.showBookCoins()
                if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
                  SignComp()
                  this.getReadTimeCoins()
                } else {
                  Row({ space: 12 }) {
                    SignComp()
                      .layoutWeight(1)
                    this.getReadTimeCoins()
                  }
                  .width('100%')
                }
                this.getTaskCoins()
              }
              .layoutWeight(1)
              .padding({ left: 16, right: 16 })
            }
            .align(Alignment.TopStart)
            .edgeEffect(EdgeEffect.Spring)
            .layoutWeight(1)
          }
          .width(Constants.FULL_SIZE)
          .height(Constants.FULL_SIZE)
        }
      }
      .backgroundColor($r('sys.color.comp_background_gray'))
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)

    }
    .hideTitleBar(true)
  }
}
