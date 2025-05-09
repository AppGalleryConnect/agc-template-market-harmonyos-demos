import { DialogMap, RouterModule, CommonConstants, RouterMap } from 'commonlib';
import { PerformanceVM } from '../viewModels/PerformanceVM';
import { PerformanceNotice } from '../types/Index';

@Builder
export function PerformanceDetailBuilder() {
  PerformanceDetail();
}


@ComponentV2
struct PerformanceDetail {
  vm: PerformanceVM = PerformanceVM.instance;

  build() {
    NavDestination() {
      if (this.vm.isLoading) {
        LoadingProgress().width(40);
      } else {
        Column() {
          Scroll() {
            Column() {
              Image(this.vm.performanceInfo?.img).width('100%').height(240);
              Column({ space: 10 }) {
                Column({ space: 10 }) {
                  Row() {
                    Text('¥')
                      .fontColor($r('app.color.font_color_red'))
                      .fontSize(CommonConstants.FONT_SIZE_S)
                      .margin({ bottom: 2 });
                    Text(this.vm.performanceInfo?.price.toString() ?? '')
                      .fontColor($r('app.color.font_color_red'))
                      .fontWeight(500)
                      .fontSize(20);
                  }
                  .height(24)
                  .justifyContent(FlexAlign.End)
                  .width('100%')
                  .alignItems(VerticalAlign.Bottom)
                  .position({ x: 0, y: 0 });

                  Text(this.vm.performanceInfo?.title)
                    .fontWeight(500)
                    .fontSize(CommonConstants.FONT_SIZE_L)
                    .fontColor(CommonConstants.FONT_COLOR_BLACK);
                  Text(this.vm.performanceInfo?.desc)
                    .fontSize(CommonConstants.FONT_SIZE_S)
                    .fontColor(CommonConstants.FONT_COLOR_GRAY);
                  Row({ space: 6 }) {
                    Image($r('app.media.icon_public_position')).width(12);
                    Text('举办地点：' + this.vm.performanceInfo?.location)
                      .fontSize(CommonConstants.FONT_SIZE_S)
                      .fontColor(CommonConstants.FONT_COLOR_BLACK);
                  };

                  Row({ space: 6 }) {
                    Image($r('app.media.icon_public_clock')).width(12);
                    Text('展览时间：' + this.vm.performanceInfo?.duration)
                      .fontSize(CommonConstants.FONT_SIZE_S)
                      .fontColor(CommonConstants.FONT_COLOR_BLACK);
                  };
                }.commonContainerStyle();

                Column({ space: 10 }) {
                  ForEach(this.vm.performanceInfo?.notice, (item: PerformanceNotice) => {
                    Text(item.title)
                      .fontColor(CommonConstants.FONT_COLOR_BLACK)
                      .fontWeight(500)
                      .fontSize(CommonConstants.FONT_SIZE_M);
                    ForEach(item.content, (v: string[]) => {
                      Column() {
                        ForEach(v, (str: string) => {
                          Text(str)
                            .width('100%')
                            .fontSize(CommonConstants.FONT_SIZE_S)
                            .fontColor(CommonConstants.FONT_COLOR_BLACK)
                            .lineHeight(22);
                        }, (str: string) => str);
                      };

                    }, (v: string[], index: number) => index.toString());
                  }, (item: PerformanceNotice) => item.title);

                }.commonContainerStyle();

                Column({ space: 10 }) {
                  Text('展览概述')
                    .fontColor(CommonConstants.FONT_COLOR_BLACK)
                    .fontWeight(500)
                    .fontSize(CommonConstants.FONT_SIZE_M);
                  ForEach(this.vm.performanceInfo?.overview, (item: string) => {
                    Text(item)
                      .width('100%')
                      .fontSize(CommonConstants.FONT_SIZE_S)
                      .fontColor(CommonConstants.FONT_COLOR_BLACK)
                      .lineHeight(22);

                  }, (item: string) => item);
                }.commonContainerStyle();

              }.padding(10);
            };

          }.width('100%').height('calc(100% - 75vp)').scrollBar(BarState.Off);

          Row() {
            Button('立即购买')
              .backgroundColor(CommonConstants.FONT_COLOR_GREEN)
              .fontWeight(500)
              .fontSize(CommonConstants.FONT_SIZE_L)
              .width('100%')
              .onClick(() => {
                RouterModule.push({
                  url: RouterMap.BUY_TICKET,
                  param: {
                    performanceId: this.vm.performanceInfo?.performanceId,
                    performanceName: this.vm.performanceInfo?.title,
                  },
                });
              });
          }.width('100%').height(75).padding(10).backgroundColor(CommonConstants.BG_COLOR_WHITE);
        }.width('100%').height(CommonConstants.FULL_HEIGHT).backgroundColor(CommonConstants.BG_COLOR_GRAY);
      }


    }.title('展览详情').onReady(() => {
      this.vm.getPerformanceInfo();
    });

  }
}

@Extend(Column)
function commonContainerStyle() {
  .borderRadius(8)
  .padding(10)
  .backgroundColor(CommonConstants.BG_COLOR_WHITE)
  .width('100%')
  .alignItems(HorizontalAlign.Start);
}
