import { CommonBarView } from './CommonBarView';

@ComponentV2
export struct SettingBarView {
  @Param startImage?: ResourceStr = '';
  @Require @Param name: string = '';
  @BuilderParam value: () => void;

  @Builder
  BuildBarStartImage(startImage?: ResourceStr) {
    if (startImage !== '') {
      Image(this.startImage)
        .size({ width: 18, height: 18 });
    }
  }

  @Builder
  BuildName(name: string) {
    Text(name);
  }

  @Builder
  BuildBarEndImage() {
    Image($r('app.media.chevron_right'))
      .size({ width: 14, height: 14 })
      .opacity(0.6);
  }

  build() {
    CommonBarView({
      part0: () => {
        this.BuildBarStartImage(this.startImage);
      },
      part1: () => {
        this.BuildName(this.name);
      },
      part2: this.value,
      part3: () => {
        this.BuildBarEndImage();
      },
    });
  }
}