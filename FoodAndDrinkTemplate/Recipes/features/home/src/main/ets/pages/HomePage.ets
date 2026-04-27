import { HomePageVM } from '../viewModels/HomePageVM';
import { BaseHeader, PushUtils, RdbManager, RouterMap, RouterModule } from 'commonlib';
import { FeaturedRecipes } from 'featured_recipes';
import { common } from '@kit.AbilityKit';
import uiObserver from '@ohos.arkui.observer';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function HomePageBuilder() {
  HomePage();
}

@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);
  navDesInfo: uiObserver.NavDestinationInfo | undefined;
  private swiperController: SwiperController = new SwiperController();

  async aboutToAppear() {
    this.vm.getDishesList()
    this.rdbManager.initDatabase(this.context);
    // 初始化push token
    PushUtils.getTokenSyn()
  }

  refresh(): void {
    setTimeout(() => {
      this.vm.isRefreshing = false;
    }, 1000)
  }

  private onColumnClicked(indexValue: string, index: number, snapShotComponentId: string): void {
    let param: Record<string, Object> = {};
    let clickedIndex = parseInt(indexValue);
    let isVip = this.vm.dishesList.getData(index).isVip;
    param.id = clickedIndex;
    param.indexValue = clickedIndex;
    param.snapShotId = snapShotComponentId;

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), snapShotComponentId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    if (isVip && !this.vm.userInfo.isMembership) {
      if(!this.vm.userInfo.isLogin) {
        RouterModule.push(RouterMap.QUICK_LOGIN_PAGE);
      } else {
        RouterModule.push(RouterMap.MEMBER_CENTER_PAGE);
      }
    } else {
      RouterModule.push(RouterMap.DISHES, param);
    }
  }

  changeRecipes(index: number, item: string): void {
    this.vm.subTabIndex = index;
    this.vm.tabBarScroller.scrollToIndex(index, true);
    this.vm.scroller.scrollToIndex(0, true);
    this.vm.recipesTitle = item;
    this.vm.getDishesList(item)
  }

  @Builder
  subBarItemBuilder(item: string, index: number) {
    Button({ type: ButtonType.Capsule, stateEffect: true }) {
      Row() {
        Text(item)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(this.vm.subTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.vm.subTabIndex === index ?
            $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      }
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor(this.vm.subTabIndex === index ?
      this.vm.themeColor : $r('sys.color.comp_background_primary'))
    .onClick(() => {
      this.changeRecipes(index, item)
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
    NavDestination() {
      if(this.vm.gridCount === 4) {
        BaseHeader({
          showSearch: this.vm.isSearchVisible,
          showRightMenu: this.vm.isSearchVisible,
          searchResults: this.vm.searchResults,
          subTabIndex: this.vm.subTabIndex,
          themeColor: this.vm.themeColor,
          showButton: true,
          showBgColor: this.vm.showBgColor,
          gridCount: this.vm.gridCount,
          changeRecipes: async (index: number, item: string) => {
            this.changeRecipes(index, item)
          },
        })
          .backgroundColor($r('sys.color.comp_background_gray'))
      }

      Stack({ alignContent: Alignment.TopStart }) {
        Scroll(this.vm.scroller) {
          Column() {
            Swiper(this.swiperController) {
              ForEach(this.vm.bannerUrl, (item: ResourceStr, index: number) => {
                Stack({ alignContent: Alignment.Bottom }) {
                  Image(item)
                    .width('100%')
                    .height('100%')
                    .objectFit(ImageFit.Cover)
                }
                .borderRadius(this.vm.gridCount === 4 ? 16 : 0)
                .clip(true)
                .height('100%')
              }, (item: ResourceStr) => JSON.stringify(item));
            }
            .width('100%')
            .height(this.vm.gridCount === 2 ? 320 : 270)
            .itemSpace(12)
            .prevMargin(this.vm.getMargin)
            .nextMargin(this.vm.getMargin)
            .displayCount(this.vm.gridCount / 2)
            .autoPlay(true)
            .loop(true)
            .indicator( // 设置圆点导航点样式
              new DotIndicator()
                .itemWidth(62)
                .itemHeight(2)
                .selectedItemWidth(62)
                .selectedItemHeight(2)
                .color('rgba(255, 255, 255, 0.2)')
                .bottom(LengthMetrics.vp(15), true)
                .selectedColor('#fff')
            )

            Column() {
              Row() {
                List({ space: 8, scroller: this.vm.tabBarScroller }) {
                  ForEach(this.vm.searchResults, (item: string, index: number) => {
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
                .listDirection(Axis.Horizontal)
                .scrollBar(BarState.Off)
              }
              .height(56)
              .margin({ top: 8, bottom: 8 })
              .padding({ top: 4, left: 16, right: 16 })
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
              .onVisibleAreaChange([0.0, 0.5, 1.0], (isExpanding: boolean, currentRatio: number) => {
              })
            }
            .width('100%')

            FeaturedRecipes({
              dishesList: this.vm.dishesList,
              showTitle: true,
              isLoading: this.vm.isLoading,
              hasMore: this.vm.hasMore,
              features: 'home',
              title: this.vm.recipesTitle,
              isFill: true,
              onClickCb: async (id: number, index: number) => {
                this.onColumnClicked(id.toString(), index, `recipes_flow_${id}_${index}_home`)
              },
              jumpBloggerInfo: (id: number) => {
                RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE, { 'id': id } as Record<string, number>)
              },
              loadMore: () => {
                this.vm.loadMore();
              },
              deleteAds: (id: number, index: number) => {
                this.vm.deleteMyRecipe(id, index)
              }
            })
          }
          .backgroundColor($r('sys.color.comp_background_gray'))
        }
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onDidScroll(() => {
          const yOffset = this.vm.scroller.currentOffset().yOffset;
          if (yOffset > 120 && yOffset < 220) {
            this.vm.showBgColor = true;
            this.vm.isSearchVisible = false;
            this.vm.bgOpacity = 0.9;
          } else if (yOffset >= 220 && yOffset < 276) {
            this.vm.isSearchVisible = false;
            this.vm.bgOpacity = 1;
          } else if (yOffset >= 276) {
            this.vm.isSearchVisible = true;
            this.vm.bgOpacity = 1;
          } else {
            this.vm.showBgColor = false;
            this.vm.isSearchVisible = false;
            this.vm.bgOpacity = 1;
          }
        })

        if(this.vm.gridCount === 2) {
          BaseHeader({
            showSearch: this.vm.isSearchVisible,
            showRightMenu: this.vm.isSearchVisible,
            searchResults: this.vm.searchResults,
            subTabIndex: this.vm.subTabIndex,
            themeColor: this.vm.themeColor,
            showButton: true,
            showBgColor: this.vm.showBgColor,
            changeRecipes: async (index: number, item: string) => {
              this.changeRecipes(index, item)
            },
          })
            .linearGradient({
              angle: 180,
              colors: this.vm.showBgColor ?
                [['rgba(0, 0, 0, 0)', 0],['rgba(0, 0, 0, 0)', 1]] : [['rgba(0, 0, 0, 0.6)', 0],['rgba(0, 0, 0, 0)', 1]],
            })
            .backgroundColor(this.vm.isSearchVisible || this.vm.showBgColor ? $r('sys.color.comp_background_gray') : '')
            .opacity(this.vm.bgOpacity)
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}

