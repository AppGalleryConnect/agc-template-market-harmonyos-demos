import { PreferenceConstant, PreferenceUtil } from 'common';
import { phoneRouterControl } from 'oh_router';

/**
 * @usage: 开屏引导页面，应用首次启动或每次启动时展示的欢迎页面。关键数据结构：isSplashScreen（布尔值，控制开屏页显示），
 * countDownTimer（数字，定时器id）。包含条件渲染：if(this.isSplashScreen)控制开屏内容显示。定时逻辑：setTimeout 3秒后自动关闭。
 * 使用PreferenceUtil存储SPLASH_SCREEN状态标记，关闭后设置为false
 * @layout: 页面采用Stack堆叠布局，从底到顶依次为：背景图（s全屏铺满）、居中的品牌展示图（垂直居中），右上角关闭按钮。整体内容顶部对齐。
 * @constraints: countDownTimer用于自动关闭计时器，closeSplashScreen方法为核心关闭逻辑。isSplashScreen状态控制页面显示，不可删除。
 * @isGen: true
 * @fileType: page
 * @zhName: 开屏页
 * @component:
 */
@Builder
export function SplashScreenPageBuilder() {
  SplashScreenPage()
}

//开屏页面
@ComponentV2
export struct SplashScreenPage {
  @Local isSplashScreen: boolean = true
  @Local countDownTimer: number = -1

  closeSplashScreen() {
    PreferenceUtil.getInstance(this.getUIContext().getHostContext()).put(PreferenceConstant.SPLASH_SCREEN, false)
    phoneRouterControl.popPage({
      popData: 'agree'
    })
    clearTimeout(this.countDownTimer)
  }

  aboutToAppear(): void {
    this.countDownTimer = setTimeout(() => {
      this.closeSplashScreen()
    }, 3000)
  }

  build() {
    NavDestination() {
      if (this.isSplashScreen) {
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            Image($r('app.media.splashScreen_bgi'))
          }.width('100%').height('100%')

          Column() {
            Row() {
              Image($r('app.media.splashScreen_image')).width(340).height(298)
            }.height('100%').justifyContent(FlexAlign.Center)
          }.width('100%').height('100%')

          Row() {
            Text('关闭')
              .width(60)
              .height(30)
              .borderRadius(15)
              .backgroundColor('rgba(0, 0, 0, 0.08)')
              .textAlign(TextAlign.Center)
              .margin({ top: 40, right: 12 })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .onClick(() => {
            this.closeSplashScreen()
          })
        }
      }
    }.hideTitleBar(true) // 隐藏标题栏
  }
}

