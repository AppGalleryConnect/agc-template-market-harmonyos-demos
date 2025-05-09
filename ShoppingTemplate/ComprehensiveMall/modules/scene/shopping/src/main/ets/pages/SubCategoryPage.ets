import { TitleBar } from '@components/titlebar';
import { Style } from '@common/const';
import { buildProductGhostSearchBar } from '@guis/search';
import { router } from '@common/router';

import { SubCategoryPageLogic, CategoryTabVM } from '../logic/SubCategoryPageLogic';
import { IWaterFlow } from '@components/iwaterflow';

@ComponentV2
export struct SubCategoryPage {

  @Param
  public categoryId: string = '';

  private logic: SubCategoryPageLogic = new SubCategoryPageLogic();

  aboutToAppear(): void {
    this.logic.init(this.categoryId);
  }

  build(): void {
    NavDestination() {
      Column() {
        TitleBar({
          hideBackButton: false,
          barPadding: { right: Style.MENU_BAR_MARGIN_RIGHT },
          barColor: Color.White
        }) {
          Row() {
            buildProductGhostSearchBar('请输入搜索内容', () => router.pushPathByName('ProductSearchPage', null))
          }
          .padding({ left: 8 })
        }
        if (this.logic.isLoading) {
          Column() {
            LoadingProgress()
              .width(37)
              .height(37)
              .offset({ y: -50 })
          }
          .width('100%')
          .layoutWeight(1)
          .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
          .justifyContent(FlexAlign.Center)
        } else {
          Row() {
            Scroll() {
              Column() {
                ForEach(this.logic.tabs, (item: CategoryTabVM, index: number) => {
                  Row() {
                    Text(item.label)
                      .width('100%')
                      .fontSize(12)
                      .fontColor(item.isSelect ? '#FFFFFFFF' : '#99000000')
                      .fontWeight(item.isSelect ? 700 : 400)
                      .textAlign(TextAlign.Center)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.MARQUEE })
                  }
                  .width('100%')
                  .height(45)
                  .backgroundColor(item.isSelect ? '#FFE64566' : '#00E64566')
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => this.logic.onChange(index))
                })
              }
              .width(80)
              .constraintSize({ minHeight: '100%' })
              .justifyContent(FlexAlign.Start)
            }
            .height('100%')
            .scrollBar(BarState.Off)
            .backgroundColor('#0D979797')
            .edgeEffect(EdgeEffect.Spring)
            Swiper(this.logic.controller) {
              ForEach(this.logic.tabs, (tab: CategoryTabVM) => {
                IWaterFlow({
                  logic: tab.iWaterFlowLogic,
                  template: '1fr',
                  footerPadding: { bottom: 48, top: (170 - 48) * 0.4 },
                })
                  .padding({ right: 10, left: 10 })
              })
            }
            .index(this.logic.currentSelectIndex)
            .layoutWeight(1)
            .height('100%')
            .indicator(false)
            .loop(false)
            .vertical(true)
            .disableSwipe(true)
            .effectMode(EdgeEffect.None)
          }
          .width('100%')
          .layoutWeight(1)
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Start)
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(Color.White)
      //.padding({ bottom: Style.BOTTOM_NAV_HEIGHT })
    }
    .hideTitleBar(true)
  }
}

@Builder
export function buildSubCategoryPage(_: string, categoryId: string) {
  SubCategoryPage({ categoryId: categoryId })
}
