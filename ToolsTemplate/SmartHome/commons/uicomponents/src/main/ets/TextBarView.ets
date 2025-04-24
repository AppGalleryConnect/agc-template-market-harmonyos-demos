import { SettingBarView } from './SettingBarView';

@ComponentV2
export struct TextBarView {
  @Param startImage?: ResourceStr = '';
  @Require @Param name: string = '';
  @Require @Param value: string = '';

  @Builder
  BuildValue() {
    Text(this.value);
  }

  build() {
    SettingBarView({
      startImage: this.startImage,
      name: this.name,
      value: () => {
        this.BuildValue();
      },
    });
  }
}