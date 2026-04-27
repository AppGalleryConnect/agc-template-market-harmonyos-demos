import { common } from '@kit.AbilityKit';
import { CommonHeader, TValueType, BarVM } from 'common';
import { Countdown } from 'countdown';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { Prompter } from 'teleprompter';
import { PrompterController } from 'teleprompter/src/main/ets/controller/PrompterController';
import { CueWordsItem } from '../viewmodel/CueWordsItemModel';

@Builder
export function PromptBoardPageBuilder(params?: TValueType) {
  PromptBoardPage({
    pageParam: params
  })
}

/**
 * @usage: 提词板页面，提词器的核心功能页面，用于全屏展示滚动的提词文本。关键数据结构：pageParam（页面参数，类型TValueType，
 * 包含CueWordsItem提词内容）。页面依赖teleprompter组件提供的Prompter提词器核心功能，支持文字滚动、速度控制、暂停/继续等功能
 * @layout: 页面整体采用垂直布局（Column），顶部是CommonHeader导航栏（标题"提词板"），下方是Prompter提词器组件占据剩余全部空间。
 * @constraints: pageParam为必需参数，通过路由传递提词内容；Prompter组件为teleprompter模块提供的核心组件，不可删除；
 * @domain: 工具
 * @isGen: true
 * @fileType: page
 * @zhName: 提词板
 * @component: CommonHeader, Prompter, OHPage
 * @image: screenshots/prompt_word/PromptBoard.png
 */
//提词板页面
@ComponentV2
export struct PromptBoardPage {
  @Param pageParam?: TValueType = null
  @Local prompterController: PrompterController = PrompterController.instance;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    showBackImg: false,
    aboutToAppear: () => {
      let params = this.pageParam as CueWordsItem
      let text = JSON.parse(JSON.stringify(params)).__ob_content as string ?? ''
      this.prompterController.text = text
      this.prompterController.setStatusFontColor()
    },
    onBackPress: () => {
      if (this.prompterController.isLandscapeMode) {
        this.prompterController.setRotationMode(this.context)
      }
    },
    aboutToDisappear: () => {
      this.prompterController.setStatusFontColor('#000000')
    }
  });
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  onReturnClick() {
    if (this.prompterController.isLandscapeMode) {
      this.prompterController.setRotationMode(this.context)
    }
    phoneRouterControl.popPage();
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      if (!this.prompterController.isLandscapeMode) {
        CommonHeader({
          title: '提词板',
          isDeepColor: this.prompterController.isDeepBack(),
          onReturnClick: () => {
            this.onReturnClick()
          },
          hasBackButton: true
        })
      }
      Prompter({
        prompterController: this.prompterController,
        onReturnClick: () => {
          this.onReturnClick()
        },
      })

      Countdown({
        time: this.prompterController.config.countdown,
        onFinish: () => {
          this.prompterController.start()
        }
      })
        .position({ top: 0, left: 0 })
    }
    .layoutWeight(1)
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH,
      left: 16,
      right: 16
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageBackgroundColor: this.prompterController.config.backgroundColor,
      pageConfig: this.pageConfig,
    })
  }
}

