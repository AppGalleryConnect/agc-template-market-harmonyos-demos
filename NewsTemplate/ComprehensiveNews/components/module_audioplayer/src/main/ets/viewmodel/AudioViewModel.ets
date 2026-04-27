import { window, display } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { WindowPosition } from '../model/WindowPosition';
import { ControlStateModel } from '../model/ControlStateModel';
import { MediaViewModel } from './MediaViewModel';
import { PlayerAnimation } from '../animation/PlayerAnimation';
import { AudioConstants } from '../constants/Constants';
import { Utils } from '../utils/Utils';
import { EventMap } from '../constants/EventMap';

const TAG = '[AudioViewModel]';

@ObservedV2
export class AudioViewModel {
  @Trace uiContext: UIContext | undefined = undefined;
  @Trace subWindowValue: window.Window | undefined = undefined;
  @Trace windowPosition: WindowPosition = { x: 0, y: 0 };
  @Trace controlState: ControlStateModel =
    AppStorageV2.connect<ControlStateModel>(ControlStateModel, () => new ControlStateModel())!;
  @Trace mediaService: MediaViewModel = MediaViewModel.getInstance()
  @Trace start: boolean = true;
  @Trace viewState: number = 0
  @Trace playerAnimation: PlayerAnimation = new PlayerAnimation()
  @Trace taskId?: number
  @Trace step: number = 5;
  @Trace loop: number = Number.POSITIVE_INFINITY;
  @Trace fromStart: boolean = true;
  @Trace panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });

  constructor(uiContext: UIContext) {
    try {
      this.uiContext = uiContext;
      this.windowPosition = { x: this.vp2px(16), y: display.getDefaultDisplaySync().height - this.vp2px(200) };
      this.subWindowValue = window.findWindow(AudioConstants.AUDIO_SUB_NAME);
    } catch (e) {
      UtilLog.error(TAG, 'new AudioViewModel fail, error: ' + JSON.stringify(e));
    }
  }

  @Computed
  get subWindow() {
    return this.subWindowValue as window.Window;
  }

  public vp2px(value: number): number {
    return this.uiContext?.vp2px(value) ?? 0;
  }

  public initSubWindow() {
    Utils.changeFocus(MediaViewModel.windowStage!, AudioConstants.AUDIO_SUB_NAME)
    this.taskId = setTimeout(() => {
      this.viewState = 1
      this.resetPosition()
    }, 3000);
  }

  public moveWindow() {
    this.subWindow.moveWindowTo(this.windowPosition.x, this.windowPosition.y).catch((e: BusinessError) => {
      UtilLog.error(TAG, 'moveWindowTo fail, error: ' + JSON.stringify(e));
    });
  }

  public async resetPosition() {
    try {
      if (this.viewState === 0) {
        await this.subWindow.resize(this.vp2px(AudioConstants.SUB_WIN_STATE_0_WIDTH),
          this.vp2px(AudioConstants.SUB_WIN_HEIGHT));

        if (this.windowPosition.x + this.vp2px(AudioConstants.SUB_WIN_HEIGHT) * 0.5 >=
          display.getDefaultDisplaySync().width / 2) {
          this.windowPosition.x = display.getDefaultDisplaySync().width -
          this.vp2px(AudioConstants.SUB_WIN_STATE_0_WIDTH) - this.vp2px(AudioConstants.SUB_WIN_PADDING);
        } else {
          this.windowPosition.x = this.vp2px(AudioConstants.SUB_WIN_PADDING);
        }

        clearTimeout(this.taskId)
        this.taskId = setTimeout(() => {
          this.viewState = 1
          this.resetPosition()
        }, 3000);

      } else {
        await this.subWindow.resize(this.vp2px(AudioConstants.SUB_WIN_HEIGHT),
          this.vp2px(AudioConstants.SUB_WIN_HEIGHT));

        if (this.windowPosition.x + this.vp2px(AudioConstants.SUB_WIN_STATE_0_WIDTH) * 0.5 >=
          display.getDefaultDisplaySync().width / 2) {
          this.windowPosition.x = display.getDefaultDisplaySync().width -
          this.vp2px(AudioConstants.SUB_WIN_HEIGHT) - this.vp2px(AudioConstants.SUB_WIN_PADDING);
        } else {
          this.windowPosition.x = this.vp2px(AudioConstants.SUB_WIN_PADDING);
        }
      }
      this.moveWindow();
    } catch (e) {
      UtilLog.error(TAG, 'resetPosition fail, error: ' + JSON.stringify(e));
    }
  }

  public onPlayerEvent() {
    if (this.viewState) {
      this.viewState = 0
      this.resetPosition()
    } else {
      let eventData: emitter.GenericEventData<string> = {
        data: this.mediaService.audioList[this.mediaService.audioIndex].id,
      };
      emitter.emit(EventMap.ON_SUB_WINDOW, eventData)
    }
    Utils.changeFocus(MediaViewModel.windowStage!, AudioConstants.AUDIO_SUB_NAME)
  }

  public audioPlay() {
    if (this.controlState.isPlay) {
      MediaViewModel.getInstance().pause();
    } else {
      if (MediaViewModel.getInstance().getFirst()) {
        MediaViewModel.getInstance().loadAssent(0);
      } else {
        MediaViewModel.getInstance().play();
      }
    }
    this.controlState.pageShowTime = 0;
    Utils.changeFocus(MediaViewModel.windowStage!, AudioConstants.AUDIO_SUB_NAME)
  }

  public async onActionUpdate(event: GestureEvent) {
    try {
      this.windowPosition.x += event.offsetX;
      this.windowPosition.y += event.offsetY;
      let top = this.vp2px(56);
      let bottom =
        display.getDefaultDisplaySync().height - this.subWindow.getWindowProperties().windowRect.height - top;
      if (this.windowPosition.y < top) {
        this.windowPosition.y = top;
      } else if (this.windowPosition.y > bottom) {
        this.windowPosition.y = bottom;
      }
      await this.subWindow.moveWindowTo(this.windowPosition.x, this.windowPosition.y);
    } catch (e) {
      UtilLog.error(TAG, ' fail, error: ' + JSON.stringify(e));
    }
  }

  public async onActionEnd(event: GestureEvent) {
    try {
      if (this.windowPosition.x + this.subWindow.getWindowProperties().windowRect.width * 0.5 >=
        display.getDefaultDisplaySync().width / 2) {
        this.windowPosition.x = display.getDefaultDisplaySync().width -
        this.subWindow.getWindowProperties().windowRect.width - this.vp2px(16);
      } else if (event.offsetX < display.getDefaultDisplaySync().width / 2) {
        this.windowPosition.x = this.vp2px(16);
      }
      let top = this.vp2px(56);
      let bottom =
        display.getDefaultDisplaySync().height - this.subWindow.getWindowProperties().windowRect.height - top;
      if (this.windowPosition.y < top) {
        this.windowPosition.y = top;
      } else if (this.windowPosition.y > bottom) {
        this.windowPosition.y = bottom;
      }
      await this.subWindow.moveWindowTo(this.windowPosition.x, this.windowPosition.y);
      Utils.changeFocus(MediaViewModel.windowStage!, AudioConstants.AUDIO_SUB_NAME)
      //清空倒计时任务
      clearTimeout(this.taskId)
      this.taskId = setTimeout(() => {
        this.viewState = 1
        this.resetPosition()
      }, 3000);
    } catch (e) {
      UtilLog.error(TAG, 'onActionEnd fail, error: ' + JSON.stringify(e));
    }
  }
}