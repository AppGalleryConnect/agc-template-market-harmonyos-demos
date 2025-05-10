import { RouterMap, RouterModule } from 'commonlib';
import { SearchPageVM } from '../viewModels/SearchPageVM';
import { TabItem } from '../types/Index';
import { LengthMetrics } from '@kit.ArkUI';
import { RecipeBriefInfo } from 'network';

@Builder
export function SearchPageBuilder() {
  SearchPage();
}

@Preview
@ComponentV2
struct SearchPage {
  vm: SearchPageVM = SearchPageVM.instance;

  aboutToAppear(): void {
    this.vm.getHotkeys();
    this.vm.getDefaultSearch();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Search({ placeholder: '今天想吃什么？', value: this.vm.keyword })
            .width('100%')
            .onChange((res) => {
              this.vm.keyword = res;
            })
            .onSubmit(() => {
              this.vm.searchDishes();
            })
            .searchButton('搜索', {
              fontColor: '#0A59F7',
              fontSize: 14,
            })
            .defaultFocus(true)
            .onFocus(() => {
              this.vm.isShowResult = false;
            })
            .margin({ top: 8 });


          if (this.vm.isShowResult) {
            this.searchResultBuilder();
          } else {
            this.searchRecordBuilder();
          }


        }.padding({ left: 16, right: 16 });

      }.height('100%').scrollBar(BarState.Off).align(Alignment.Top);
    }.title('搜索');
  }

  @Builder
  searchResultBuilder() {
    Column() {
      Row({ space: 8 }) {
        ForEach(this.vm.tabList, (item: TabItem, index) => {
          Text(item.label)
            .height(37)
            .textAlign(TextAlign.Center)
            .width(80)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.vm.curTabIndex === index ? '#FD4238' : $r('app.string.font_color_black'))
            .onClick(() => {
              this.vm.curTabIndex = index;
              if (index === 1) {
                this.vm.resultList = this.vm.resultList.sort((a, b) => b.likes - a.likes);
              } else if (index === 2) {
                this.vm.resultList = this.vm.resultList.sort((a, b) => b.views - a.views);
              } else {
                this.vm.searchDishes();
              }
            });
        }, (item: TabItem) => item.label);
      }.width('100%').margin({ top: 12 });

      if (this.vm.resultList.length === 0) {
        Text('~~暂无数据~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
      } else {
        List({ space: 16 }) {
          ForEach(this.vm.resultList, (item: RecipeBriefInfo, index) => {
            ListItem() {
              Row({ space: 8 }) {
                Image($r(`app.media.${item.thumbnail}`))
                  .width(120)
                  .height(120)
                  .borderRadius(8)
                  .alt($r('app.media.food_img'));
                Column() {
                  Column({ space: 5 }) {
                    Text(item.title)
                      .width(200)
                      .fontSize(16)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .fontColor($r('app.string.font_color_black'));
                    Row({ space: 4 }) {
                      Text(item.cookingTime + '分钟左右').labelBaseExtend();

                      Text('难度' + item.difficulty)
                        .labelBaseExtend();

                    }.width('100%');
                  }.alignItems(HorizontalAlign.Start);


                  Text(item.likes > 0 ? `${item.likes}人收藏过` : '').fontSize(12);
                  Row({ space: 4 }) {
                    Image($r(`app.media.${item.authorAvatar}`)).width(16).height(16).borderRadius(8);
                    Text(item.author).fontSize(12).fontColor($r('app.string.font_color_gray'));
                  };
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ top: 10, bottom: 10 })
                .justifyContent(FlexAlign.SpaceBetween)
                .height(120);
              };
            }.onClick(() => {
              RouterModule.push({ url: RouterMap.DISHES, param: { id: item.id } });
            });
          });
        }.height('calc(100% - 49vp)').scrollBar(BarState.Off);
      }

    }.height('calc(100% - 40vp)');
  }

  @Builder
  searchRecordBuilder() {
    if (this.vm.historyInfo.length) {
      Row() {
        Text('搜索历史').fontSize(12).fontColor($r('app.string.font_color_black'));
        Text('清空')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.string.font_color_black'))
          .height(28)
          .width(72)
          .textAlign(TextAlign.Center)
          .backgroundColor('#0D000000')
          .borderRadius(14)
          .onClick(() => {
            this.vm.historyInfo = [];
          });
      }.justifyContent(FlexAlign.SpaceBetween).margin({ top: 16, bottom: 12 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.vm.historyInfo, (item: string, index) => {
          Text(item)
            .labelBaseStyle()
            .onClick(() => {
              this.vm.keyword = item;
              this.vm.searchDishes();
            });
        }, (item: string, index) => item + index.toString());
      };
    }


    Text('热门搜索')
      .fontSize(12)
      .fontColor($r('app.string.font_color_black'))
      .margin({ top: 24, bottom: 14 })
      .width('100%');
    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
      ForEach(this.vm.hotInfo, (item: string, index) => {
        Text(item)
          .labelBaseStyle()
          .onClick(() => {
            this.vm.keyword = item;
            this.vm.searchDishes();
          });
      }, (item: string, index) => item + index.toString());
    };

  }
}


@Extend(Text)
function labelBaseExtend() {
  .fontSize(10)
  .backgroundColor('#F1F3F5')
  .padding({ left: 4, right: 4 })
  .borderRadius(4)
  .height(14)
  .fontColor($r('app.string.font_color_gray'));
}

@Extend(Text)
function labelBaseStyle() {
  .padding({
    top: 4,
    bottom: 4,
    left: 8,
    right: 8,
  })
  .fontSize(14)
  .borderRadius(14)
  .backgroundColor('#0D000000')
  .focusable(true)
  .focusOnTouch(true);
}
