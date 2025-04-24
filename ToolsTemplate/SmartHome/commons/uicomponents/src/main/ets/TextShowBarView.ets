import { CommonBarView } from './CommonBarView';

@ComponentV2
export struct TextShowBarView {
  @Param startImage?: ResourceStr = '';
  @Require @Param name: string = '';
  @Require @Param value: string = '';

  @Builder
  BuildBarStartImage(startImage?: ResourceStr) {
    if (startImage !== '') {
      Image(this.startImage)
        .size({ width: 18, height: 18 });
    }
  }

  @Builder
  BuildName() {
    Text(this.name);
  }

  @Builder
  BuildValue() {
    Text(this.value);
  }

  build() {
    CommonBarView({
      part0: () => {
        this.BuildBarStartImage(this.startImage);
      },
      part1: () => {
        this.BuildName();
      },
      part2: () => {
        this.BuildValue();
      },
      part3: () => {
      },
    });
  }
}