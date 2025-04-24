import { TextBarView } from './TextBarView';
import { common } from '@kit.AbilityKit';
import { jumpToAppSettings } from 'utils';

@ComponentV2
export struct AccessSettingBarView {
  @Param startImage?: ResourceStr = '';
  @Require @Param name: string = '';
  @Require @Param value: string = '';

  openAppInfo() {
    let context = getContext(this) as common.UIAbilityContext;
    jumpToAppSettings(context);
  };

  build() {
    TextBarView({
      startImage: this.startImage,
      name: this.name,
      value: this.value,
    })
      .onClick(() => {
        this.openAppInfo();
      });
  }
}