import { RecipeBriefInfo } from '../types/Index';
import { BreakpointModel, BreakpointType } from 'base_ui';
import LazyDataSource from '../utils/LazyDataSource';
import { RecommendedCard } from './RecommendedCard';
import { AppStorageV2 } from '@kit.ArkUI';


@ComponentV2
export struct FeaturedRecipes {
  @Param dishesList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Param showTitle: boolean = false;
  @Param canDelete: boolean = false;
  @Param isToDelete: boolean = false;
  @Param isLoading: boolean = false;
  @Param hasMore: boolean = true;
  @Param features: string = '';
  @Param title: string = '';
  @Param isFill: boolean = false;
  @Event onClickCb: (id: number, index: number) => void = () => {
  }
  @Event jumpBloggerInfo: (id: number) => void = () => {
  }
  @Event deleteRecipes: (ids: number[]) => void = () => {
  }
  @Event changeSelect: (id: number, flag: boolean) => void = () => {
  }
  @Event changeDeleteState: (isToDelete: boolean) => void = () => {
  }
  @Event loadMore: () => void = () => {
  }
  @Event deleteAds: (id: number, index: number) => void = () => {
  }
  @BuilderParam uploadBuilderParam: () => void = this.uploadBuilder;
  // 新增参数
  scroller: Scroller = new Scroller();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 6,
    xl: 6,
  });

  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  @Builder
  uploadBuilder() {
  }

  @Builder
  itemFoot(params: Record<string, boolean>) {
    if (params.isLoading) {
      Row({ space: 8 }) {
        LoadingProgress()
          .height(32)
          .width(48)
        Text('正在加载')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .height(params.isLoading ? 40 : 0)
      .justifyContent(FlexAlign.Center)
    } else if (!params.hasMore && this.gridCount < 6) { // 导航栏位置
      Row().width('100%').height(90)
    }
  }

  build() {
    Column() {
      Text(this.title)
        .margin({ bottom: 12 })
        .fontColor($r('sys.color.font_primary'))
        .fontSize(16)
        .width('100%')
        .visibility(this.showTitle ? Visibility.Visible : Visibility.None)
      WaterFlow({
        scroller: this.scroller,
        footer: this.itemFoot({ 'isLoading': this.isLoading, 'hasMore': this.hasMore })
      }) {
        this.uploadBuilderParam()
        LazyForEach(this.dishesList, (item: RecipeBriefInfo, index: number) => {
          FlowItem() {
            RecommendedCard({
              recipe: item,
              canDelete: this.canDelete,
              isToDelete: this.isToDelete,
              recipeIndex: index,
              jumpBloggerInfo: () => {
                this.jumpBloggerInfo(item.authorId)
              },
              changeDeleteState: (isToDelete: boolean) => {
                this.changeDeleteState(isToDelete)
              },
              onClickCb: (id: number) => {
                this.onClickCb(id, index)
              },
              changeSelect: (id: number, flag: boolean) => {
                this.changeSelect(id, flag)
              },
              deleteAds: (id: number, index: number) => {
                this.deleteAds(id, index)
              },
            })
          }
          .clip(true)
          .id(`recipes_flow_${item.id}_${index}_${this.features}`)
        }, (item: RecipeBriefInfo) => item.id.toString())
      }
      .cachedCount(25)
      .columnsGap(8)
      .rowsGap(8)
      .height('100%') //影响其他页面
      .columnsTemplate(Array(this.gridCount).fill('1fr').join(' '))
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
      .onReachEnd(() => {
        this.loadMore()
      })
    }
    .padding({ left: 16, right: 16 })
  }
}
