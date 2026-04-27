import { BreakpointModel, BreakpointType } from 'base_ui';
import { RecipeBriefInfo, SortType, TabItem } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct SearchResult {
  @Param curTabIndex: number = 0;
  @Param resultList: RecipeBriefInfo[] = [];
  @Param keyword: string = '';
  @Local tabList: TabItem[] =
    [{ label: '综合', sortType: SortType.General }, { label: '收藏最多', sortType: SortType.Grade },
      { label: '浏览最多', sortType: SortType.Cooked }];
  @Event changeIndex: (index: number) => void = () => {
  }
  @Event changeRecipes: (name: string) => void = () => {
  }
  @Event goRecipeDetail: (id: number, index:number) => void = () => {
  }
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });
  @Local tabBarScroller: Scroller = new Scroller();
  @Local subTabIndex: number = 0;
  @Local searchResults: string[] = ['全部', '热门菜肴', '家常菜', '下饭菜', '快手菜', '减脂餐', '蔬菜'];
  @Local themeColor: ResourceColor = '#FD4238';
  @Local scroller: Scroller = new Scroller();
  @Local newResultList: RecipeBriefInfo[] = JSON.parse(JSON.stringify(this.resultList));

  aboutToAppear(): void {
  }

  @Monitor('curTabIndex')
  onResultListChange(monitor: IMonitor) {
    this.newResultList = JSON.parse(JSON.stringify(this.resultList));
  }

  @Computed
  get getLanes() {
    let lanes = this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
    return lanes;
  }

  @Builder
  subBarItemBuilder(item: string, index: number) {
    Button(item)
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(this.subTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.subTabIndex === index ?
        $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .backgroundColor(this.subTabIndex === index ?
        this.themeColor : $r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.subTabIndex = index;
        this.tabBarScroller.scrollToIndex(index, true);
        this.scroller.scrollToIndex(0, true);
        if(item === '全部') {
          this.newResultList = JSON.parse(JSON.stringify(this.resultList))
        } else {
          this.newResultList = this.resultList.filter((res) => res.category.includes(item))
        }
      })
      .height(36)
      .padding({
        top: 8,
        bottom: 8,
        right: 16,
        left: 16
      })
  }

  build() {
    Column() {
      Row({ space: 32 }) {
        ForEach(this.tabList, (item: TabItem, index) => {
          Text(item.label)
            .height(37)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.curTabIndex === index ? '#FD4238' : $r('sys.color.font_primary'))
            .onClick(() => {
              this.changeIndex(index)
            });
        }, (item: TabItem) => item.label);
      }.width('100%').margin({ top: 12, left: 12});

      List({ space: 8, scroller: this.tabBarScroller }) {
        ForEach(this.searchResults, (item: string, index: number) => {
          ListItem() {
            this.subBarItemBuilder(item, index)
          }
        }, (item: string) => JSON.stringify(item))
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .padding({
        top: 10,
        bottom: 10,
      })
      .height(56)
      .width('100%')
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)

      if (this.newResultList.length === 0) {
        Column({ space: 12 }) {
          Image($r('app.media.SearchNoResult'))
            .width(120)
            .height(120)

          Text('没有符合条件的内容')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .fontColor($r('sys.color.font_secondary'))
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .width('100%')
      } else {
        List({ space: 16 }) {
          ForEach(this.newResultList, (item: RecipeBriefInfo, index) => {
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
                      .fontColor($r('sys.color.font_primary'));
                    Row({ space: 4 }) {
                      Text(item.cookingTime + '分钟左右').labelBaseExtend();

                      Text('难度' + item.difficulty)
                        .labelBaseExtend();

                    }.width('100%');
                  }.alignItems(HorizontalAlign.Start);


                  Text(item.likes > 0 ? `${item.likes}人收藏过` : '').fontSize(12);
                  Row({ space: 4 }) {
                    Image($r(`app.media.${item.authorAvatar}`)).width(20).height(20).borderRadius(10);
                    Text(item.author).fontSize(12).fontColor($r('sys.color.font_secondary'));
                  };
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ top: 10, bottom: 10 })
                .justifyContent(FlexAlign.SpaceBetween)
                .height(120);
              };
            }
            .id(`recipes_flow_${item.id}_${index}`)
            .onClick(() => {
              this.goRecipeDetail(item.id, index);
            });
          }, (item: RecipeBriefInfo) => item.id.toString());
        }
        .height('calc(100% - 49vp)')
        .scrollBar(BarState.Off)
        .padding({ bottom: 20 })
        .layoutWeight(1)
        .lanes(this.getLanes)
      }
    }
  }
}

@Extend(Text)
function labelBaseExtend() {
  .fontSize(10)
  .padding({ left: 4, right: 4 })
  .borderRadius(4)
  .height(14)
  .fontColor($r('sys.color.font_secondary'));
}
