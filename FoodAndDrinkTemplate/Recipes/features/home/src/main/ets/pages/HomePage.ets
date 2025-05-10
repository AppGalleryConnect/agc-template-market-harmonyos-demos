import { Banner } from '../components/Banner';
import { HomePageVM } from '../viewModels/HomePageVM';
import { TabItem } from '../types/Index';
import { FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { emitter } from '@kit.BasicServicesKit';
import { RecipeBriefInfo } from 'network';

@Builder
export function HomePageBuilder() {
  HomePage();
}

@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance;

  aboutToAppear(): void {
    this.vm.getDishesList()
  }

  build() {
    NavDestination() {
      Row({ space: 8 }) {
        if (!this.vm.isSearchVisible) {
          Row() {
            Image($r('app.media.ic_glass')).width(24).height(24);
          }
          .width(40)
          .height(40)
          .backgroundColor('#0D000000')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
        }
        Text(this.vm.isSearchVisible ? '首页' : '菜谱').fontSize(24).fontColor($r('app.string.font_color_black'));
      }
      .height(56)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .shadow({
        offsetX: 0,
        offsetY: 4,
        color: '#1A000000',
        radius: this.vm.isSearchVisible ? 0 : 4,
      })
      .padding({ left: 24 })
      .onClick(() => {
        if (!this.vm.isSearchVisible) {
          RouterModule.push({ url: RouterMap.SEARCH });
        }
      });

      Scroll() {
        Column() {
          Column() {
            Banner();
          }.width('100%');

          Row({ space: 8 }) {
            Image($r('app.media.ic_glass')).width(16);
            Text('今天想吃点什么？').fontColor($r('app.string.font_color_gray'));
          }
          .width('100%')
          .backgroundColor('#0D000000')
          .height(40)
          .margin({ top: 12 })
          .padding(12)
          .borderRadius(24)
          .onClick(() => {
            RouterModule.push({ url: RouterMap.SEARCH });
          })
          .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
            if (currentRatio === 0) {
              this.vm.isSearchVisible = false;
            } else {
              this.vm.isSearchVisible = true;
            }
          });

          Row() {
            ForEach(this.vm.tabList, (item: TabItem, index) => {
              Column({ space: 2 }) {
                Image(item.icon).height(32).width(32);
                Text(item.label).fontSize(10).fontColor($r('app.string.font_color_black'));
              }.onClick(() => {
                if ((this.vm.tabList.length - 1) !== index) {
                  RouterModule.push({ url: RouterMap.SEARCH, param: { keyword: item.label } });
                } else {
                  emitter.emit('jumpPage');
                }

              });
            });
          }
          .height(56)
          .margin({ top: 8, bottom: 8 })
          .padding({ top: 4, left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%');

          Text('精选推荐')
            .margin({ bottom: 12 })
            .fontColor($r('app.string.font_color_black'))
            .fontSize(16)
            .width('100%');

          WaterFlow() {
            ForEach(this.vm.dishesList, (item: RecipeBriefInfo) => {
              FlowItem() {
                Column() {
                  Image($r(`app.media.${item.thumbnail}`))
                    .width('100%')
                    .objectFit(ImageFit.Cover)
                    .height(160)
                    .borderRadius(8);
                  Text(item.title)
                    .width('100%')
                    .margin({ top: 8, bottom: 4 })
                    .fontColor($r('app.string.font_color_black'))
                    .fontSize(14);
                  Row() {
                    Row({ space: 4 }) {
                      Image($r(`app.media.${item.authorAvatar}`)).width(16).height(16).borderRadius(8);
                      Text(item.author).fontSize(12).fontColor($r('app.string.font_color_gray'));
                    };

                    Row({ space: 5 }) {
                      Image($r('app.media.ic_public_star_plain'))
                        .fillColor($r('app.string.font_color_gray'))
                        .width(15)
                        .height(14);
                      Text(FormatUtil.formatCollection(item.likes))
                        .fontSize(12)
                        .fontColor($r('app.string.font_color_gray'));
                    };
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);
                };
              }.onClick(() => {
                RouterModule.push({ url: RouterMap.DISHES, param: { id: item.id } })
              })
            }, (item: RecipeBriefInfo) => item.id.toString());
          }
          .columnsGap(8)
          .rowsGap(8)
          .columnsTemplate('1fr 1fr');

        }.padding({ left: 16, right: 16 });
      }.align(Alignment.Top)
      .height('calc(100% - 56vp)')
      .scrollBar(BarState.Off);
    }.hideTitleBar(true);
  }
}

