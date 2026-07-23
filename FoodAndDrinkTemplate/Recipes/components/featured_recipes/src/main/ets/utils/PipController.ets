import { AppStorageV2, PiPWindow } from '@kit.ArkUI';
import Logger from './Logger';
import { PipUINodeController } from './PipUINodeController';
import { media } from '@kit.MediaKit';
import { PiPWindowModel } from '../models/PiPWindowModel';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = '[PipUINodeController]';

/**
 * 画中画自定义UI控制器
 */
@ObservedV2
export class PipController {
  private pipController?: PiPWindow.PiPController = undefined;
  @Trace pipUINodeController: PipUINodeController = new PipUINodeController();
  @Trace pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;


  /**
   * 启动画中画
   */
  public startPip(context: Context, xComponentController: XComponentController,
    avPlayer: media.AVPlayer, detailScroller: Scroller) {
    if (!PiPWindow.isPiPEnabled()) {
      Logger.error(`picture in picture disabled for current OS`);
      return;
    }
    let config: PiPWindow.PiPConfiguration = {
      context: context,
      componentController: xComponentController,
      // 1、UIAbility使用Navigation管理页面，需要设置Navigation控件的id属性，并将该id设置给画中画控制器，确保还原场景下能够从画中画窗口恢复到原页面
      navigationId: 'navigationId',
      // 对于视频通话、视频会议等场景，需要设置相应的模板类型
      templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY,
      // 可选，创建画中画控制器时系统可通过XComponent组件大小设置画中画窗口比例
      contentWidth: avPlayer.width,
      // 可选，创建画中画控制器时系统可通过XComponent组件大小设置画中画窗口比例
      contentHeight: avPlayer.height,
      // 可选，如果需要在画中画显示内容上方展示自定义UI，可设置该参数。
      customUIController: this.pipUINodeController,
    };
    // 步骤1：创建画中画控制器，通过create接口创建画中画控制器实例
    PiPWindow.create(config).then((controller: PiPWindow.PiPController) => {
      this.pipController = controller;
      this.pipWindowModel.pipController = this.pipController;
      // 步骤1：初始化画中画控制器
      this.initPipController(avPlayer, detailScroller);
      // 步骤2：通过startPiP接口启动画中画
      this.pipController.startPiP().then(() => {
        Logger.info(`Succeeded in starting pip.`);
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to start pip. Cause:${err.code}, message:${err.message}`);
      });
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to create pip controller. Cause:${err.code}, message:${err.message}`);
    });
  }

  initPipController(avPlayer: media.AVPlayer, detailScroller: Scroller) {
    if (!this.pipController) {
      return;
    }
    // 步骤1：通过setAutoStartEnabled接口设置是否需要在应用返回桌面时自动启动画中画，注册stateChange和controlPanelActionEvent回调
    this.pipController.setAutoStartEnabled(false /*or true if necessary*/); // 默认为false
    this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
      this.onStateChange(state, reason, detailScroller, avPlayer);
    });
    this.pipController.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
      this.onActionEvent(event, status, avPlayer);
    });
  }

  onStateChange(state: PiPWindow.PiPState, reason: string, detailScroller: Scroller, avPlayer?: media.AVPlayer) {
    let curState: string = '';
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = 'ABOUT_TO_START';
        break;
      case PiPWindow.PiPState.STARTED:
        curState = 'STARTED';
        if (avPlayer?.state === 'playing') { // 如果视频正在播放，设置视频播放控制面板中播放/暂停控件为播放状态
          let controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
          let status: PiPWindow.PiPControlStatus = PiPWindow.PiPControlStatus.PLAY;
          this.pipWindowModel.videoPlayerStatus = 'playing';
          if (this.pipController !== undefined) {
            this.pipController.updatePiPControlStatus(controlType, status);
          }
        } else if (avPlayer?.state === 'paused' || avPlayer?.state === 'completed') { // 如果视频正在暂停，设置视频播放控制面板中播放/暂停控件为暂停状态
          let controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
          let status: PiPWindow.PiPControlStatus = PiPWindow.PiPControlStatus.PAUSE;
          this.pipWindowModel.videoPlayerStatus = 'paused';
          if (this.pipController !== undefined) {
            this.pipController.updatePiPControlStatus(controlType, status);
          }
        }
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        curState = 'ABOUT_TO_STOP';
        this.pipUINodeController?.dispose();
        break;
      case PiPWindow.PiPState.STOPPED:
        curState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        detailScroller.scrollEdge(Edge.Top);
        curState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR:
        curState = 'ERROR';
        break;
      default:
        break;
    }
    Logger.info(`[${TAG}] onStateChange: ${curState}, reason: ${reason}`);
  }

  onActionEvent(event: PiPWindow.PiPActionEventType, status?: number, avPlayer?: media.AVPlayer) {
    const controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
    switch (event) {
      case 'playbackStateChanged':
        // 开始或停止视频
        if (status === 0) {
          // 停止视频
          if(avPlayer) {
            this.pipWindowModel.videoPlayerStatus = 'paused';
            avPlayer.pause().catch((err: BusinessError) => {
              Logger.error(`${TAG}: avPlayer pause failed,error message is = ${JSON.stringify(err.message)}`);
            });
          }
        } else if (status === 1) {
          // 播放视频
          if(avPlayer) {
            this.pipWindowModel.videoPlayerStatus = 'playing';
            avPlayer.play().catch((err: BusinessError) => {
              Logger.error(`${TAG}: avPlayer play failed,error message is = ${JSON.stringify(err.message)}`);
            });
          }
        }
        break;
      default:
        break;
    }
  }

  // 步骤3：视频内容变化时，向画中画控制器更新视频尺寸信息，用于调整画中画窗口比例
  updateContentSize(width: number, height: number) {
    if (this.pipController) {
      this.pipController.updateContentSize(width, height);
    }
  }
  // 步骤4：当不再需要显示画中画时，通过stopPiP接口关闭画中画
  stopPip() {
    if (this.pipController) {
      let promise: Promise<void> = this.pipController.stopPiP();
      promise.then(() => {
        Logger.info(`Succeeded in stopping pip.`);
        this.pipController?.off('stateChange'); // 如果已注册stateChange回调，停止画中画时取消注册该回调
        this.pipController?.off('controlPanelActionEvent'); // 如果已注册controlPanelActionEvent回调，停止画中画时取消注册该回调
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to stop pip. Cause:${err.code}, message:${err.message}`);
      });
    }
  }
}