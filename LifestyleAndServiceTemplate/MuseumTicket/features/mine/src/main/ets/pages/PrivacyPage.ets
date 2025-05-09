import { CommonConstants } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage();
}


@ComponentV2
struct PrivacyPage {
  vm: MinePageVM = MinePageVM.instance;

  aboutToAppear(): void {
    this.vm.getPrivacyText();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column({ space: 24 }) {
              ForEach(this.vm.privacyText, (item: string[]) => {
                Column() {
                  ForEach(item, (v: string) => {
                    Text(v)
                      .width('100%')
                      .fontColor(CommonConstants.FONT_COLOR_WHITE)
                      .fontColor(CommonConstants.FONT_COLOR_BLACK)
                      .fontSize(CommonConstants.FONT_SIZE_M)
                      .lineHeight(22);
                  }, (v: string) => v);
                };
              }, (item: string[], index: number) => index.toString());

            }.width('100%').padding(20).backgroundColor(CommonConstants.BG_COLOR_WHITE);

          }.width('100%');
        }.height(CommonConstants.FULL_HEIGHT).scrollBar(BarState.Off);
      }.padding({ top: 10 }).backgroundColor(CommonConstants.BG_COLOR_GRAY);
    }.title('隐私政策');

  }
}

