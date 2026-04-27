import { common } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { PrompterController } from '../controller/PrompterController';
import { PrompterVM } from '../viewmodel/PrompterVM';

/**
 * @usage: 提词器主组件，用于展示自动滚动的提词文本和控制功能。关键数据结构：PrompterController（提词器控制器单例），
 * 关键方法：start()开始滚动、pause()暂停、restart()重新开始。启动逻辑：aboutToAppear中延迟1秒自动开始滚动
 * @layout: 页面采用垂直布局（Column），顶部是iconBar功能图标栏（横向Row），从左到右依次为：横屏模式图标、设置图标、翻转图标、
 * 刷新重新开始图标，四个图标等间距分布（SpaceBetween）。下方是滚动区域（Scroll），显示提词文本，文本支持翻转效果。
 * 底部是ConfigSheet配置面板（通过bindSheet绑定）。整体背景色根据config.backgroundColor动态改变
 * @constraints: prompterController为全局单例控制器，不可删除。
 * @domain: 工具
 * @isGen: true
 * @fileType: component
 * @zhName: 提词器主组件
 * @component:
 * @modifiable: 功能图标栏包含四个按钮，从左到右依次为：横竖屏切换按钮(横屏模式下最左侧会额外显示返回按钮)设置按钮,翻转按钮,刷新按钮。
 * 按钮顺序可调整
 * @image: screenshots/prompt_word/Prompter.jpg
 */
@ComponentV2
export struct Prompter {
  vm: PrompterVM = new PrompterVM();
  @Param prompterController: PrompterController = PrompterController.instance;
  @Local showIconBar: boolean = true
  @Event onReturnClick: () => void = () => {
  }
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.vm.displayOrientationListener()
  }

  @Builder
  iconBar() {
    Row() {
      if (this.prompterController.isLandscapeMode) {
        Image(this.prompterController.isDeepBack() ? $r('app.media.black_back_icon') : $r('app.media.ic_backward2'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.onReturnClick()
          })
        Image(this.prompterController.isDeepBack() ? $r('app.media.portrait_icon_white') :
        $r('app.media.portrait_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.prompterController.setRotationMode(this.context)
          })
      } else {
        Image(this.prompterController.isDeepBack() ? $r('app.media.landscape_icon_white') :
        $r('app.media.landscape_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.prompterController.setRotationMode(this.context)
          })
      }
      Image(this.prompterController.isDeepBack() ? $r('app.media.setup_icon_white') : $r('app.media.setup_icon'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.prompterController.isShowConfigSheet = true
          try {
            emitter.emit('showConfigSheet')
          } catch (e) {
          }
        })
      Image(this.prompterController.isDeepBack() ? $r('app.media.flip_icon_white') : $r('app.media.flip_icon'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.prompterController.config.isFlip = !this.prompterController.config.isFlip
        })
      Image(this.prompterController.isDeepBack() ? $r('app.media.refresh_icon_white') : $r('app.media.refresh_icon'))
        .width(24)
        .height(24)
        .onClick(() => {
          this.prompterController.restart()
        })
    }
    .width('100%')
    .justifyContent(this.vm.displayModel.isFoldAble ?
      this.vm.displayModel.isFullMode ? FlexAlign.SpaceAround : FlexAlign.SpaceBetween : FlexAlign.SpaceBetween)
    .padding({ bottom: 10 })
    .position({ top: 0, left: 0 })
    .backgroundColor(this.prompterController.config.backgroundColor)
  }

  @Builder
  pausePic() {
    Stack() {
      Image($r('app.media.prompter_pause'))
        .width(100)
        .height(100)
        .onClick(() => {
          this.prompterController.start()
        })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Center)
    .position({ top: 0, left: 0 })
  }

  @Builder
  scrollContent() {
    Scroll(this.prompterController.scrollController) {
      Text(this.prompterController.text)
        .width('100%')
        .fontSize(this.prompterController.config.fontSize)
        .fontColor(this.prompterController.config.fontColor)
        .rotate({ y: 2, angle: this.prompterController.config.isFlip ? 180 : 0, perspective: 200 })
    }
    .padding({ top: 65 })
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .align(Alignment.TopStart)
    .onWillScroll((xOffset: number, yOffset: number) => {
      if (this.prompterController.isPause) { // 条件判断
        return { xOffset: 0, yOffset: 0 } // 强制不滚动
      }
      return { xOffset: xOffset, yOffset: yOffset }
    })
    .onDidScroll(() => {
      if (this.prompterController.isLandscapeMode) {
        this.showIconBar = false
      }
    })
    .onScrollStop(() => {
      this.prompterController.pause()
      this.showIconBar = true
    })
    .onClick(() => {
      this.prompterController.pause()
      this.showIconBar = true
    })
  }

  build() {
    Column() {
      Stack() {
        this.scrollContent()
        if (this.prompterController.isPause && !this.prompterController.isAtEnd()) {
          this.pausePic()
        }
      }
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.TopStart)

      if (this.showIconBar) {
        this.iconBar()
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.prompterController.config.backgroundColor)
  }
}
