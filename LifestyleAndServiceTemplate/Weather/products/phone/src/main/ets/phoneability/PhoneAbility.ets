import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { RainEffectResumeUtil } from 'module_weather_core';

const DOMAIN = 0xff00;
const TAG = '[PhoneAbility]';

export default class PhoneAbility extends UIAbility {
  private resumeUtils: RainEffectResumeUtil = new RainEffectResumeUtil();

  public onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground.');
    this.resumeUtils.notifyForeground();
  }

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
      });
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'windowStage loadContent failed, error: ' + JSON.stringify(e));
    }
  }
}