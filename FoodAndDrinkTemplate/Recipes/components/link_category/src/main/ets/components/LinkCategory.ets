import { RecipeBriefInfo, RecipeCategory } from '../types/Index';
import { BreakpointModel, BreakpointType } from 'base_ui';
import { AppStorageV2 } from '@kit.ArkUI';
import { UISkeleton, SkeletonTheme as ThemeType, AnimateType } from '@hw-agconnect/ui-skeleton';

@ComponentV2
export struct LinkCategory {
  @Param recipeCategoryList: RecipeCategory[] = [];
  @Param currentIndex: number = 0;
  @Param gridCount: number = 3;
  titleItemScroller: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  @Event onRecipeClick: (recipeDetail: RecipeBriefInfo, index: number, name: string) => void = () => {
  }
  @Event changeCurrentIndex: (currentIndex: number) => void = () => {
  }
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 3,
    md: 6,
    lg: 8,
    xl: 8,
  });
  sizeOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 90,
    md: 100,
    lg: 110,
    xl: 110,
  });
  @Local filterRecipes: Array<number> = [7002, 30001];
  // 切换动画
  @Local animate: AnimateType = AnimateType.GRADIENT;
  @Local loading: boolean = true;
  @Local titleWid: number | string = 100;

  aboutToAppear(): void {
    setTimeout(()=>{
      this.loading = false;
      this.titleWid = '100%';
    },1000)
  }

  // 下标索引处理
  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      this.changeCurrentIndex(index);
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.titleItemScroller.scrollToIndex(index);
      }
    }
  }

  @Computed
  get listLanes() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  @Computed
  get imageSize() {
    return this.sizeOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  // 分类列表
  @Builder
  leftListBuilder(typeName: string, index: number) {
    Row() {
      Text(typeName)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === index ? $r('sys.color.font_on_primary') : Color.Black)
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentIndex === index ? '#FF0000' : '#00000000')
    .width('100%')
    .height(40)
    .padding({
      left: 12,
      right: 4,
      top: 12,
      bottom: 12,
    })
    .margin({ right: 4 })
    .constraintSize({ maxWidth: '100%' })
    .borderRadius({ topRight: 12, bottomRight: 12 })
    .onClick(() => {
      this.currentIndexChangeAction(index, true);
    })
  }

  // 右列表分类标题
  @Builder
  listTitleBuilder(title: string) {
    Row() {
      UISkeleton({ options: [1], loading: this.loading }) {
        Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'))
      }
    }
    .width(this.titleWid)
    .height(26)
    .margin({ bottom: 12, top: 0 })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    Column() {
      // 列表页
      Row() {
        List({ space: 12, scroller: this.scroller }) {
          ForEach(this.recipeCategoryList, (item: RecipeCategory) => {
            ListItemGroup({
              header: this.listTitleBuilder(item.name),
            }) {
              ListItem() {
                Grid() {
                  ForEach(item.recipeList, (listItem: RecipeBriefInfo, index) => {
                    if(!this.filterRecipes.includes(listItem.id)) {
                      GridItem() {
                        Column() {
                          Stack({ alignContent: Alignment.Bottom }) {
                            UISkeleton({ options: [{ width: '100%', height: this.imageSize },1],
                              loading: this.loading }){
                              Image($r(`app.media.${listItem.thumbnail}`))
                                .height(this.imageSize)
                                .width('100%')
                                .borderRadius(8)
                              // 底部渐变遮罩层（修复LinearGradient调用方式）
                              Row()
                                .width('100%')
                                .height(36)
                                .linearGradient({
                                  angle: 180,
                                  colors: listItem.linearColor ?
                                    listItem.linearColor : [['rgba(216, 158, 84, 0)', 0],['rgba(216, 158, 84, 1)', 1]],
                                })
                                .align(Alignment.Bottom)
                                .borderRadius({
                                  bottomLeft: 8,
                                  bottomRight: 8
                                })

                              Text(listItem.title)
                                .fontSize(12)
                                .fontWeight(FontWeight.Medium)
                                .fontColor(Color.White)
                                .textAlign(TextAlign.Center)
                                .constraintSize({ maxWidth: 76 })
                                .maxLines(1)
                                .margin({ top: 4 })
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                            }
                          }
                        }
                      }
                      .clip(true)
                      .width('100%')
                      .height(this.imageSize)
                      .id(`recipes_flow_${listItem.id}_${item.name}_${index}`)
                      .onClick(() => {
                        this.onRecipeClick(listItem, index, item.name)
                      })
                    }
                  }, (listItem: RecipeBriefInfo) => `${item.id}${listItem.id}`)
                }
                .rowsGap(8)
                .columnsGap(8)
                .columnsTemplate(Array(this.listLanes).fill('1fr').join(' '))
              }
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .borderRadius(16)
              .padding(12)
            }
          }, (item: RecipeCategory) => item.id.toString())
          ListItem() {}
          .width('100%')
          .height(88)
        }
        .layoutWeight(1)
        .height('100%')
        .margin({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.Header | StickyStyle.Footer)
        .onScrollIndex((start: number) => this.currentIndexChangeAction(start, false))
      }.layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .constraintSize({ maxHeight: '100%' })
  }
}