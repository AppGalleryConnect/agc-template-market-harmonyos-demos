import { emitter } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { Logger } from '../utils/Logger';
import { EventKey } from '../constants/EventKey';

export enum SliderType {
  VOLUME,
  BRIGHT
}

const TAG = '[PlayerSliderModel]';

@ObservedV2
export class PlayerSliderModel {
  @Trace volume: number = 0;
  @Trace bright: number = 0.5;
  // 是否显示音量调节进度
  @Trace showVolumeProgress: boolean = false;
  @Trace showBrightProgress: boolean = false;

  onSliderChange(type: SliderType, value: number, mode: SliderChangeMode) {
    switch (mode) {
      case SliderChangeMode.Begin:
        break;
      case SliderChangeMode.Click:
        break;
      case SliderChangeMode.Moving:
        if (type === SliderType.VOLUME) {
          this.handleVolumeChange(value)
        } else if (type === SliderType.BRIGHT) {
          this.handleBrightChange(value)
        }
        break;
      case SliderChangeMode.End:
        break;
      default:
        break;
    }
  }

  handleVolumeChange(value: number) {
    this.volume = value;
    emitter.emit(EventKey.SYSTEM_VOLUME_CHANGE, {
      data: {
        volume: value,
      },
    } as emitter.EventData)
  }

  async handleBrightChange(value: number) {
    try {
      this.bright = value;
      const windowClass = AppStorage.get<window.Window>('windowClass')
      await windowClass?.setWindowBrightness(value);
    } catch (e) {
      Logger.error(TAG, 'setWindowBrightness fail, error: ' + JSON.stringify(e));
    }
  }
}