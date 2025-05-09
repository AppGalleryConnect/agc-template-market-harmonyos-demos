import { CommonConstants } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';
import { ExplainTextItem } from '../types/Index';

@Builder
export function ExplainPageBuilder() {
  ExplainPage();
}


@ComponentV2
struct ExplainPage {
  @Local vm: HomePageVM = HomePageVM.instance;

  aboutToAppear(): void {
    this.vm.getExplainText();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 24 }) {
            ForEach(this.vm.explainText, (item: ExplainTextItem, index) => {
              Column() {
                Text(item.title).fontColor(CommonConstants.FONT_COLOR_BLACK).lineHeight(22);
                ForEach(item.content, (v: string, i) => {
                  Text(v).fontColor(CommonConstants.FONT_COLOR_BLACK).lineHeight(22);
                }, (v: string, i) => v);
              }.alignItems(HorizontalAlign.Start);

            }, (item: ExplainTextItem, index) => item.title);

          }
          .padding({
            top: 10,
            bottom: 10,
            left: 20,
            right: 20,
          })
          .alignItems(HorizontalAlign.Start);
        }
        .height('calc(100% - 10vp)')
        .scrollBar(BarState.Off)
        .margin({ top: 10 })
        .backgroundColor(CommonConstants.BG_COLOR_WHITE);
      }.width('100%').height(CommonConstants.FULL_HEIGHT).backgroundColor(CommonConstants.BG_COLOR_GRAY);
    }.title('讲解服务');

  }
}

