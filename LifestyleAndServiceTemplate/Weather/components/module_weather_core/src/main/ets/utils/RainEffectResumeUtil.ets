import { AppStorageV2 } from '@kit.ArkUI';
import { RainEffectResumeState } from '../common/RainEffectResumeState';

export class RainEffectResumeUtil {
  private _state: RainEffectResumeState = AppStorageV2.connect(
    RainEffectResumeState,
    'rainEffectResumeState',
    () => new RainEffectResumeState(),
  )!;

  public getState(): RainEffectResumeState {
    return this._state;
  }

  public notifyForeground(): void {
    this._state.version = Date.now();
  }
}
