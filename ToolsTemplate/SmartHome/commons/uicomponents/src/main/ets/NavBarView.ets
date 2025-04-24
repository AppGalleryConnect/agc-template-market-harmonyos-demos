import { CommonBarView } from './CommonBarView';

@ComponentV2
export struct NavBarView {
  @Require @Param pathStack: NavPathStack = new NavPathStack();
  @Param image?: ResourceStr = '';
  @Require @Param text: string;
  @Require @Param pageName: string;

  @Builder
  BuildText(text: string) {
    Text(text);
  }

  @Builder
  BuildEndImage() {
    Image($r('app.media.chevron_right'))
      .size({ width: 14, height: 14 })
      .opacity(0.6);
  }

  @Builder
  BuildStartImage(image?: ResourceStr) {
    if (image !== '') {
      Image(image)
        .size({ width: 18, height: 18 });
    }
  }

  build() {
    CommonBarView({
      part0: () => {
        this.BuildStartImage(this.image);
      },
      part1: () => {
        this.BuildText(this.text);
      },
      part2: () => {
      },
      part3: () => {
        this.BuildEndImage();
      },
    }).onClick(() => {
      this.pathStack.pushPathByName(this.pageName, null);
    });
  }
}