import { RouterMap, RouterModule } from '@agctemplate/router_module'
import { BarVM } from '@agctemplate/widgets'
import { LiveMsgModel } from '../models/LiveModel'
import { display } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'

interface data {
  title: string
  value: number
}

@ComponentV2
struct EndLivePage {
  @Local liveStreamer: LiveMsgModel = LiveMsgModel.instance
  @Local liveData: data[] = []
  @Local isLandScapeTablet: boolean = display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
    display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
      deviceInfo.deviceType === 'tablet'
  callback: Callback<number> = (data: number) => {
    if (display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE ||
      display.getDefaultDisplaySync().orientation === display.Orientation.LANDSCAPE_INVERTED &&
        deviceInfo.deviceType === 'tablet') {
      this.isLandScapeTablet = true
    } else {
      this.isLandScapeTablet = false
    }
  }

  aboutToAppear(): void {
    this.initLiveData()
    try {
      display.on('change', this.callback)
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('change', this.callback)
    } catch (e) {
    }
  }

  initLiveData() {
    this.liveData.push({ title: '累计观看人数', value: this.liveStreamer.data.audienceNum })
    this.liveData.push({ title: '点赞', value: this.liveStreamer.data.likeNum })
    this.liveData.push({ title: '收益', value: this.liveStreamer.data.incomeNum })
    this.liveData.push({ title: '新增粉丝', value: this.liveStreamer.data.addFansNum })
    this.liveData.push({ title: '弹幕数量', value: this.liveStreamer.data.bulletNum })
    this.liveData.push({ title: '付费人数', value: this.liveStreamer.data.bossNum })
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.chevron_left'))
                .fontSize(24)
                .fontColor(['#E5FFFFFF'])
            }
            .width(40)
            .height(40)
            .backgroundColor('#1AFFFFFF')
            .onClick(() => {
              RouterModule.pop()
            })

            Blank()
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.house'))
                .fontSize(24)
                .fontColor(['#E5FFFFFF'])
            }
            .width(40)
            .height(40)
            .backgroundColor('#1AFFFFFF')
            .onClick(() => {
              RouterModule.popToName(RouterMap.MAIN_PAGE)
            })
          }
          .width('100%')
          .margin({ top: 8, bottom: 8 })

          Text('直播已结束')
            .fontWeight(700)
            .fontSize(30)
            .fontColor('rgba(255, 255, 255, 0.9)')
            .lineHeight(40)
            .width('100%')
            .margin({ top: 8 })
          Text(`本场直播时长：${convertTime(this.liveStreamer.liveTime)}`)
            .fontWeight(400)
            .fontSize(14)
            .lineHeight(19)
            .width('100%')
            .fontColor('rgba(255, 255, 255, 0.6)')
            .margin({ top: 2 })
          Image(this.liveStreamer?.avatar)
            .width(120)
            .height(120)
            .borderRadius(16)
            .margin({ top: 36 })

          Text(this.liveStreamer?.nickname + '直播间')
            .width(172)
            .fontWeight(500)
            .fontSize(20)
            .lineHeight(27)
            .fontColor('rgba(255, 255, 255, 1)')
            .margin({ top: 16 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Column() {
            Column() {
              Text('直播数据')
                .fontWeight(700)
                .fontSize(18)
                .fontColor('rgba(255, 255, 255, 1)')
                .lineHeight(24)
                .width('100%')
            }
            .padding({ left: 24, right: 12, top: 24 })

            Line()
              .backgroundColor('rgba(255, 255, 255, 0.6)')
              .width('100%')
              .height(1)
              .margin({ top: 16 })
            Column() {
              GridRow({
                columns: { sm: 3, md: 4 },
                gutter: { y: 24 }
              }) {
                ForEach(this.liveData, (item: data) => {
                  GridCol() {
                    Column() {
                      Text(item.value > 10000 ? `${(item.value / 10000).toFixed(2)}万` : `${item.value}`)
                        .fontWeight(500)
                        .fontSize(14)
                        .lineHeight(19)
                        .fontColor('rgba(255, 255, 255, 1)')
                        .textAlign(TextAlign.Center)
                      Text(item.title)
                        .fontWeight(400)
                        .fontSize(12)
                        .lineHeight(16)
                        .fontColor('rgba(255, 255, 255, 0.6)')
                        .textAlign(TextAlign.Center)
                        .margin({ top: 8 })
                    }
                  }

                }, (item: data) => item.title)
              }
              .padding({ top: 16 })
              .width('100%')
              .height('100%')
            }
            .width('100%')
            .height(150)
            .padding({ left: 12, right: 12, top: 16 })
          }
          .width(this.isLandScapeTablet ? '70%' : '90%')
          .height(249)
          .borderRadius(20)
          .margin({ top: 24 })
          .backgroundColor('rgba(255, 255, 255, 0.2)')
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: BarVM.instance.staBarH })
        .backgroundColor('rgba(0, 0, 0, 0.8)')
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
      }
      .backgroundImage(this.liveStreamer?.avatar)
      .backgroundImageSize(ImageSize.Cover)
      .backgroundImagePosition(Alignment.Top)
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}

function convertTime(seconds: number): string {
  if (isNaN(seconds) || seconds < 0) {
    return '00:00:00'
  }
  let secondTime = seconds;
  let minuteTime = 0;
  let hourTime = 0;

  minuteTime = Math.trunc(secondTime / 60);
  secondTime = Math.trunc(secondTime % 60);

  if (minuteTime >= 60) {
    hourTime = Math.trunc(minuteTime / 60);
    minuteTime = Math.trunc(minuteTime % 60);
  }

  return `${hourTime.toString().padStart(2, '0')}:${minuteTime.toString().padStart(2, '0')}:${secondTime.toString()
    .padStart(2, '0')}`
}

@Builder
export function EndLivePageBuilder() {
  EndLivePage()
}