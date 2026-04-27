import { AtomicServiceEnhancedWeb } from '@atomicservice/ascfapi';
import { TextRead } from 'module_text_reader';
import { GridRowColSetting, loadingPage, RouterModule } from 'lib_foundation';
import { Constant } from '../common/Constant';
import { NewsDetailViewModel } from '../viewmodels/NewsDetailViewModel';


@Builder
export function NewsDetailBuilder() {
  NewsDetail()
}

@ComponentV2
struct NewsDetail {
  private vm: NewsDetailViewModel = new NewsDetailViewModel();

  @Monitor('vm.breakpoint')
  getNewWindowInfo() {
    this.vm.getWindowInfo(this.getUIContext())
  }

  aboutToAppear(): void {
    this.vm.init(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.vm.reset();
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
          Column() {
            if (!this.vm.isLoading) {
              loadingPage()
            } else {
              Stack({ alignContent: Alignment.BottomStart }) {
                Scroll() {
                  Column() {
                    AtomicServiceEnhancedWeb({
                      src: `data:text/html;charset=utf-8,${this.vm.generateHtml()}`,
                      controller: this.vm.atomicWebController,
                      navPathStack: RouterModule.getStack(),
                      darkMode: WebDarkMode.Auto,
                      forceDarkAccess: true,
                      bgColor: $r('sys.color.background_secondary'),
                      nestedScroll: {
                        scrollUp: NestedScrollMode.PARENT_FIRST, //向上滚动父组件优先
                        scrollDown: NestedScrollMode.SELF_FIRST, //向下滚动子组件优先
                      },
                    })
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .scrollBar(BarState.Off)
                .layoutWeight(1)
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

                Row() {
                  TextRead({
                    currentId: this.vm.newsArticle.id,
                    readInfoList: [
                      {
                        id: this.vm.newsArticle.id,
                        title: { text: this.vm.newsArticle.title, isClickable: true },
                        author: { text: this.vm.formatDate, isClickable: true },
                        bodyInfo: this.vm.readBody(),
                      },
                    ],
                    readerParam: {
                      isVoiceBrandVisible: true,
                      businessBrandInfo: { panelName: '数字报元服务' },
                    },
                    iconParams: {
                      iconWidth: Constant.ICON_SIZE,
                      iconHeight: Constant.ICON_SIZE,
                      iconBackgroundColor: $r('sys.color.comp_background_primary'),
                    }
                  })
                }
                .position({ x: this.vm.positionX, y: this.vm.positionY })
                .justifyContent(FlexAlign.Center)
                .height(Constant.ICON_ROW_SIZE)
                .width(Constant.ICON_ROW_SIZE)
                .borderRadius(Constant.HALF_PERCENT)
                .backgroundColor($r('sys.color.comp_background_primary'))
                .onTouch((event: TouchEvent) => {
                  if (event.type === TouchType.Down) {
                    this.vm.startX = event.touches[0].windowX;
                    this.vm.startY = event.touches[0].windowY;
                    this.vm.startLeft = this.vm.positionX;
                    this.vm.startTop = this.vm.positionY;
                  }
                  //手指拖动
                  else if (event.type === TouchType.Move) {
                    let touch = event.touches[0];
                    let curLeft = this.vm.startLeft + (touch.windowX - this.vm.startX);
                    //限制悬浮球不能移除屏幕左边
                    curLeft = Math.max(0, curLeft);
                    //限制悬浮球不能移除屏幕右边
                    this.vm.positionX = Math.min(this.vm.winWidth - Constant.ICON_ROW_SIZE, curLeft);
                    let curTop = this.vm.startTop + (touch.windowY - this.vm.startY);
                    //限制悬浮球不能移除屏幕上边
                    curTop = Math.max(0, curTop);
                    //限制悬浮球不能移除屏幕下边
                    this.vm.positionY =
                      Math.min(this.vm.winHeight - Constant.ICON_ROW_SIZE - this.vm.bottomAvoidAreaHeight -
                      this.vm.statusHeight - Constant.PADDING_L - 60,
                        curTop);
                  } else if (event.type === TouchType.Up) {
                    if (this.vm.positionX < (this.vm.winWidth / 2 - Constant.ICON_ROW_SIZE)) {
                      // 小球固定到左边
                      this.getUIContext()?.animateTo({
                        duration: 200,
                        curve: Curve.EaseOut,
                      }, () => {
                        this.vm.positionX = 0 + GridRowColSetting.getPageMargin(this.vm.breakpoint);
                      })
                    } else {
                      // 小球固定到右边
                      this.getUIContext()?.animateTo({
                        duration: 200,
                        curve: Curve.EaseOut,
                      }, () => {
                        this.vm.positionX =
                          this.vm.winWidth - GridRowColSetting.getPageMargin(this.vm.breakpoint) -
                          Constant.ICON_ROW_SIZE;
                      })
                    }
                  }
                })
              }
              .layoutWeight(1)
              .margin({
                top: Constant.PADDING_S,
                bottom: Constant.PADDING_L
              })
            }
          }
        }
      }
      .onBreakpointChange((bp) => {
        this.vm.breakpoint = bp;
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
  }
}