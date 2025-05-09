import { CommonConstants } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';

@Builder
export function IntroducePageBuilder() {
  IntroducePage();
}


@ComponentV2
struct IntroducePage {
  @Local vm: HomePageVM = HomePageVM.instance;

  aboutToAppear(): void {
    this.vm.getIntroduceText();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 24 }) {
            Text(this.vm.introduceText.total).fontColor(CommonConstants.FONT_COLOR_BLACK).lineHeight(22);
            Column() {
              ForEach(this.vm.introduceText.content, (item: string) => {
                Text(item).fontColor(CommonConstants.FONT_COLOR_BLACK).lineHeight(22);
              }, (item: string) => item);
            }.alignItems(HorizontalAlign.Start);

          }
          .padding({
            top: 10,
            bottom: 10,
            left: 20,
            right: 20,
          })
          .alignItems(HorizontalAlign.Start);
        }.height('100%').scrollBar(BarState.Off).backgroundColor(CommonConstants.BG_COLOR_WHITE).width('100%')
      }
      .width('100%')
      .height(CommonConstants.FULL_HEIGHT)
      .backgroundColor(CommonConstants.BG_COLOR_GRAY)
      .padding({ top: 10 });
    }.title('省博介绍');

  }
}