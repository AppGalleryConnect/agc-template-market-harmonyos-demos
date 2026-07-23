import { getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import { DramaInfo } from '@agctemplate/server'
import { appRouter, Logger, WindowManager } from '@agctemplate/utils'
import { PlayController, PlaySession } from 'video_swiper'
import { AppStorageV2 } from '@kit.ArkUI'
import { ColorMode, FontModel, fp2pxUtil } from '@agctemplate/widgets';
import { ConfigurationConstant } from '@kit.AbilityKit'

const TAG = '[DramaDesLayer]'

@ComponentV2
export struct DramaDesLayer {
  @Consumer('navStack') navPathStack: NavPathStack = new NavPathStack();
  @Param @Once @Require dramaInfo: DramaInfo
  @Param @Require playControl: PlayController
  @Param @Require playerSession: PlaySession
  @Local maxLine: number = 2
  @Local retractLength: number = 30
  @Local isSpread: boolean = false
  @Event onJump: Function
  @Local currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.isSpread) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
      }

      Row() {
        Column() {
          Row() {
            Text(this.dramaInfo.name)
              .fontSize(this.fontModel.getFg(16))
              .fontWeight(500)
              .fontColor('#fff')
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(this.fontModel.getFg(21))
              .fontColor([$r('sys.color.white')])
          }
          .accessibilityGroup(true)
          .accessibilityText(`点击进入${this.dramaInfo.name}剧集详情页`)
          .width('100%')
          .onClick(() => {
            if (this.currentColorMode.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' });
            } else {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' });
            }
            this.playControl.pause()
            appRouter.push({
              builderName: NAV_PAGE_NAME.DramaDetailInfoPage.name, params: {
                dramaInfo: this.dramaInfo,
                currentIndex: 0,
                changeIndex: (index: number) => {
                  this.onJump?.()
                }
              }
            })
          })

          Text(getString('app.string.drama_desc', this.dramaInfo.totalCount.toString(),
            (this.isSpread ? this.dramaInfo.description :
              (this.dramaInfo.description.slice(0, this.retractLength) + '...'))))
            .width('100%')
            .fontColor($r('sys.color.font_on_secondary'))
            .fontSize(this.fontModel.getFg(12))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(this.maxLine)
            .textAlign(TextAlign.Start)
            .margin({ bottom: this.isSpread ? 20 : 0 })
            .onAreaChange((oldVal, newVal) => {
              let nowWidth: number = parseInt(newVal.width.toString())
              this.retractLength = Math.floor(nowWidth / 12) * 2 - 8
            })
            .margin({ top: 2 })

          Row() {
            Text(this.isSpread ? '收起' : '展开')
              .fontSize(this.fontModel.getFg(12))
              .fontWeight(500)
              .fontColor('#fff')
            Column() {
              SymbolGlyph($r('sys.symbol.chevron_down'))
                .fontSize(this.fontModel.getFg(16))
                .fontColor([$r('sys.color.white')])
                .rotate({ angle: this.isSpread ? 180 : 0 })
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .onClick(() => {
            this.isSpread = !this.isSpread
            this.maxLine = this.maxLine === -1 ? 2 : -1
          })
        }
        .layoutWeight(1)
        .margin({
          left: 16,
          bottom: 12,
          right: 12,
          top: 13
        })

        Button(getString('app.string.watch_full_drama'))
          .onClick(() => {
            Logger.debug(TAG, `currentPlayTime:${this.playerSession.avPlayer?.currentTime}`)
            // 进入详情页，接续播放
            this.onJump?.()
          })
          .height(28)
          .fontSize(fp2pxUtil(14))
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#EC6E45')
          .margin({ bottom: 12, right: 16 })
          .id('watchFullDrama')
          .zIndex(4)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
  }
}