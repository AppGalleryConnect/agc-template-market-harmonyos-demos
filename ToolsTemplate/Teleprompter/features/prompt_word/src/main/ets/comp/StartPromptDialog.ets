import { PiPWindow, promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { RouterMap, TCLogger } from 'common';
import { phoneRouterControl } from 'oh_router';
import { ConfigSheet } from 'teleprompter/src/main/ets/components/ConfigSheet';
import { PrompterController, PrompterNodeController } from 'teleprompter/src/main/ets/controller/PrompterController';
import { CueWordsItem } from '../viewmodel/CueWordsItemModel';
import { PromptBoardPageBuilder } from '../views/PromptBoardPage';

/**
 * @usage: 用于在开始提词时选择提词模式的对话框组件。关键数据结构：CueWordsItem（提词内容数据），
 * dialogId（对话框标识number类型，默认-1），MODE_BLACKBOARD（常量"提词板模式"），MODE_SUSPEND（常量"悬浮模式"）。
 * 包含条件判断：if(title === this.MODE_BLACKBOARD)判断点击的是哪个模式。
 * 通过emitter.on监听'openStartPromptDialog'事件触发对话框打开，aboutToDisappear时off移除监听。
 * 提供两种模式选择：提词板模式（跳转到PROMPT_BOARD_PAGE）和悬浮模式（关闭对话框）
 * @layout: 对话框采用垂直布局（Column），从上到下分为两部分，第一部分是模式选择区域（Column），包含两个模式选项纵向排列。
 * 每个模式选项为横向布局（Row），左侧是模式图标Image，右侧是描述Column。第二部分是底部关闭按钮。
 * @constraints: cueWordItem为可选参数，包含提词内容数据；dialogId用于控制对话框关闭，通过openCustomDialog返回值获取；
 * MODE_BLACKBOARD和MODE_SUSPEND为固定常量不可修改；emitter事件名'openStartPromptDialog'为固定值。
 * @domain: 工具
 * @isGen: true
 * @fileType: component
 * @zhName: 开始提词对话框组件
 * @subPage:
 * @component: ConfigSheet
 * @image: screenshots/prompt_word/StartPromptDialog.jpg
 */

@ComponentV2
export struct StartPromptDialog {
  cueWordItem: CueWordsItem = new CueWordsItem('', '', '', '');
  @Local prompterController: PrompterController = PrompterController.instance;
  @Local dialogId: number = -1
  @Local isForSuspend: boolean = false
  private MODE_BLACKBOARD = '提词板模式'
  private MODE_SUSPEND = '悬浮模式'
  private mXComponentController: XComponentController = new XComponentController();
  private options: XComponentOptions = {
    type: XComponentType.SURFACE,
    controller: this.mXComponentController
  }
  private surfaceId: string = '';
  private nodeController: PrompterNodeController = new PrompterNodeController();

  aboutToAppear() {
    try {
      emitter.on('openStartPromptDialog', (data) => {
        setTimeout(() => {
          this.cueWordItem = JSON.parse(data.data?.data) ?? new CueWordsItem('', '', '', '')
          TCLogger.info('openStartPromptDialog' + JSON.stringify(data))
        }, 100)
        this.openDialog()
      })
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off('openStartPromptDialog')
    } catch (e) {
    }
  }

  openDialog() {
    this.getUIContext().getPromptAction().openCustomDialog({
      builder: () => this.dialog(),
      width: 274,
      alignment: DialogAlignment.Center,
      backgroundBlurStyle: BlurStyle.NONE
    })
      .then((id) => {
        this.dialogId = id;
      });
  }

  startBlackboardMode() {
    this.closeDialog()
    TCLogger.info('startBlackboardMode' + JSON.stringify(this.cueWordItem))
    this.isForSuspend = false
    phoneRouterControl.jumpPage({
      pageName: RouterMap.PROMPT_BOARD_PAGE,
      param: this.cueWordItem,
      builder: wrapBuilder(PromptBoardPageBuilder)
    })
  }

  startSuspendMode() {
    this.prompterController.isShowConfigSheet = true
    this.isForSuspend = true
    try {
      emitter.emit('showConfigSheet')
    } catch (e) {
    }
    TCLogger.info('startSuspendMode' + JSON.stringify(this.cueWordItem))
  }

  openPip() {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      let text = JSON.parse(JSON.stringify(this.cueWordItem)).__ob_content as string
      this.prompterController.text = text
      let config: PiPWindow.PiPConfiguration = {
        context: this.getUIContext().getHostContext() as Context,
        componentController: this.mXComponentController,
        templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY, // 对于视频通话、视频会议等场景，需要设置相应的模板类型
        contentWidth: 1920, // 可选，创建画中画控制器时系统可通过XComponent组件大小设置画中画窗口比例
        contentHeight: 1080, // 可选，创建画中画控制器时系统可通过XComponent组件大小设置画中画窗口比例
        navigationId: phoneRouterControl.defaultRouteName,
        // 可选，对于视频通话、视频会议和视频直播场景，可通过该属性选择对应模板类型下需显示的的控件组
        controlGroups: [PiPWindow.VideoPlayControlGroup.FAST_FORWARD_BACKWARD],
        customUIController: this.nodeController, // 可选，如果需要在画中画显示内容上方展示自定义UI，可设置该参数。
      };
      this.prompterController.startPip(config)
    }
    this.closeDialog()
    try {
      emitter.emit('closeConfigSheet')
    } catch (e) {
    }
  }

  closeDialog() {
    this.getUIContext().getPromptAction().closeCustomDialog(this.dialogId)
  }

  @Builder
  modeItem(img: Resource, title: string, content: string) {
    Row({ space: 16 }) {
      Image(img)
        .width(24)
        .height(24)
      Column({ space: 8 }) {
        Text(title)
          .fontColor('rgba(0, 0, 0, 0.90)')
          .fontSize(16)
        Text(content)
          .fontColor('rgba(0, 0, 0, 0.40)')
          .fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .onClick(() => {
      if (title === this.MODE_BLACKBOARD) {
        this.startBlackboardMode()
      } else {
        this.startSuspendMode()
      }
    })
  }

  @Builder
  dialog() {
    Column({ space: 20 }) {
      Column({ space: 40 }) {
        this.modeItem($r('app.media.blackboard_mode_icon'), this.MODE_BLACKBOARD, '配合外部相机发言')
        this.modeItem($r('app.media.suspend_mode_icon'), this.MODE_SUSPEND, '配合其他APP使用')
      }
      .width('100%')
      .padding({ bottom: 35, top: 33 })
      .backgroundColor('#fff')
      .borderRadius(32)

      Image($r('app.media.close_circle_icon'))
        .width(28)
        .height(28)
        .onClick(() => {
          this.closeDialog()
        })
    }
  }

  build() {
    Column() {
      XComponent(this.options)
        .onLoad(() => {
          this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
        })
      ConfigSheet({
        configList: this.prompterController.configList,
        config: this.prompterController.config,
        isShowConfigSheet: this.prompterController.isShowConfigSheet,
        isLandscapeMode: this.prompterController.isLandscapeMode,
        isForSuspend: this.isForSuspend,
        closeSheet: () => {
          this.prompterController.isShowConfigSheet = false
        },
        openSuspend: () => {
          this.openPip()
        }
      })
    }
  }
}
