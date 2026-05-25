import { ExamService, EXAM_MANAGER_TYPE, ROUTE_PARAM } from '@ohos_agcit/driver_license_exam_datasource';
import { ExamDetail, getQuestionType } from 'exam';
import { SearchComponent, SearchController } from 'search';
import { LengthMetrics } from '@kit.ArkUI';
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { Context } from '@kit.AbilityKit';

@Builder
export function SearchPageBuilder() {
  SearchPage();
}

@ComponentV2
struct SearchPage {
  vm: CommonModel = CommonModel.instance;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  private searchController: SearchController = SearchController.instance;
  @Local searchKey: string = '';
  @Local textWidth: number = 0;
  scroller:Scroller = new Scroller();

  build() {
    NavDestination() {
      Column() {
        SearchComponent({
          appPathStack: this.vm.navStack,
          hotSearchBuilder: this.hotSearch.bind(this),
          historySearchBuilder: this.historySearch.bind(this),
          searchResultBuilder: this.searchResult.bind(this),
          getSearchResult: this.getSearchResult.bind(this),
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: this.getUIContext().px2vp(AppStorage.get('topRectHeight') || 0) + 12,
        left: '4%',
        right: '4%',
      });
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onBackPressed(() => {
      this.searchController.isShowResult = false;
      this.vm.navStack.pop();
      return true;
    })
  }

  @Builder
  hotSearch() {
    Column() {
      Row() {
        Text('热门搜索').fontSize(16).fontColor($r('sys.color.font_primary'));
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 17 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.searchController.hotSearch, (item: string) => {
          Text(item)
            .labelBaseStyle()
            .onClick(() => {
              this.searchController.searchCondition = item;
              this.searchController.isShowResult = true;
              this.searchController.updateHistorySearch(item);
              this.getSearchResult();
            });
        }, (item: string, index) => item + index.toString());
      };
    };
  }

  @Builder
  historySearch() {
    Column() {
      Row() {
        Text('搜索历史').fontSize(16).fontColor($r('sys.color.font_primary'));

        Blank();

        Image($r('app.media.trash'))
          .width(16)
          .height(16)
          .onClick(() => {
            this.searchController.historySearch = [];
          });
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      List({scroller: this.scroller}) {
        ForEach(this.searchController.historySearch, (item: string, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.history_clock'))
                  .width(16);

                Text(item)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .padding({
                    left: '4%',
                  })
                  .width('82%');

                Blank();

                Row() {
                  SymbolGlyph($r('sys.symbol.xmark'))
                    .fontSize(16)
                    .fontColor([$r('sys.color.font_secondary')])
                    .onClick(() => {
                      this.searchController.historySearch.splice(index, 1);
                    });
                }
                .width('10%')
                .justifyContent(FlexAlign.End);
              }
              .height(25)
              .width('100%')
              .margin({
                top: 7,
                bottom: 7,
              });
            }
            .onClick(() => {
              this.searchController.searchCondition = item;
              this.searchController.isShowResult = true;
              this.searchController.updateHistorySearch(item);
              this.getSearchResult();
            });
          };
        }, (item: string) => JSON.stringify(item));
      }
      .divider({
        strokeWidth: 1
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .layoutWeight(1);
    }
    .layoutWeight(1)
    .padding({
      bottom: this.getUIContext().px2vp(AppStorage.get('bottomRectHeight')),
    });
  }

  @Builder
  searchResult() {
    Column() {
      if (this.searchController.searchResult.examDetails.length === 0){
        Image($r('app.media.no_search_result_found'))
          .width(120)
          .height(120)
          .margin({
            top: 120
          })

        Text('暂时没有搜索到您要找的内容呢')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
      } else {
        Scroll() {
          Column() {
            Text('搜索结果')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .alignSelf(ItemAlign.Start)
              .padding({
                top: 16,
                bottom: 16,
              });
            List({ space: 15 }) {
              ForEach(this.searchController.searchResult.examDetails, (item: ExamDetail, index: number) => {
                ListItem() {
                  Row() {
                    Text(getQuestionType(item.questionType))
                      .fontSize(12)
                      .fontColor(Color.White)
                      .backgroundColor('#64BB5C')
                      .position({ x: 0, y: 5 })
                      .padding({
                        top: 2,
                        bottom: 2,
                        left: 4,
                        right: 4,
                      })
                      .borderRadius(5)
                      .onAreaChange((oldValue, newValue: Area) => {
                        this.textWidth = Number(newValue.width);
                      });

                    Text(item.question)
                      .fontSize(14)
                      .textIndent(this.textWidth + 10)
                      .lineHeight(24);
                  };
                }
                .onClick(() => {
                  const param: ROUTE_PARAM = {
                    title: '试题详情',
                    type: EXAM_MANAGER_TYPE.search,
                    examManager: this.searchController.searchResult,
                  };
                  this.vm.navStack.pushPathByName('practiceView', param);
                });
              }, (item: ExamDetail) => JSON.stringify(item.id));
            }
            .scrollBar(BarState.Off);
          };
        }
        .scrollBar(BarState.Off);
      }

    }
    .layoutWeight(1);
  }

  getSearchResult() {
    this.searchController.searchResult =
      this.examService.getManagerByName(this.searchController.searchCondition, EXAM_MANAGER_TYPE.search);
  }
}

@Extend(Text)
function labelBaseStyle() {
  .padding({
    top: 6,
    bottom: 6,
    left: 12,
    right: 12,
  })
  .fontSize(14)
  .borderRadius(15)
  .fontColor($r('sys.color.font_secondary'))
  .backgroundColor($r('sys.color.comp_background_secondary'))
  .focusable(true)
  .focusOnTouch(true);
}
