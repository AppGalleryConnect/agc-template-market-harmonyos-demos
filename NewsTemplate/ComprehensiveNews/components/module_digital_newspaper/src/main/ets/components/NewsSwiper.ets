import { UtilLog } from '@hw-agconnect/util-log';
import { BasicDataSource } from '../common/BasicDataSource';
import { Constant } from '../common/Constant';
import { AreaModel } from '../common/AreaModel';
import { NewsArea } from '../model/NewsArea';
import { NewsPageWithAreaInfo } from '../model/NewspaperPage';

const TAG = '[NewsSwiper]';

@ComponentV2
export struct NewsSwiper {
  @Param newspaperPages: NewsPageWithAreaInfo[] = [];
  @Param currentPage: number = 0;
  @Param controller: SwiperController = new SwiperController();
  @Event $currentPage: (pageNum: number) => void = () => {
  };
  @Event jumpNewsDetail: (area: NewsArea) => void = () => {
  };
  @Consumer() containerSize: AreaModel = new AreaModel();
  @Local dataSource: BasicDataSource<NewsPageWithAreaInfo> = new BasicDataSource();
  @Local imgRatio: number = Constant.NEWSPAPER_RATIO;
  @Local imgW: Length = Constant.FULL_PERCENT;
  @Local imgH: Length = Constant.DEFAULT_AUTO;
  @Local swiperH: Length = Constant.DEFAULT_AUTO;
  @Local imgRenderSize: AreaModel = new AreaModel();

  aboutToAppear(): void {
    this.dataSource.setData(this.newspaperPages);
  }

  @Monitor('newspaperPages')
  onIndexChange() {
    this.dataSource.setData(this.newspaperPages);
  }

  @Monitor('containerSize.width', 'containerSize.height')
  onContainerChange() {
    const containerRatio = this.containerSize.width / this.containerSize.height;
    if (this.imgRatio > containerRatio) {
      this.imgW = Constant.FULL_PERCENT;
      this.imgH = Constant.DEFAULT_AUTO;
      this.swiperH = Constant.DEFAULT_AUTO;
    } else {
      this.imgW = Constant.DEFAULT_AUTO;
      this.imgH = Constant.FULL_PERCENT;
      this.swiperH = `calc(100% - ${this.containerSize.bottomHeight}vp)`;
    }
  }

  onReachEnd(index: number, targetIndex: number) {
    try {
      if (index === targetIndex && targetIndex === this.newspaperPages.length - 1) {
        this.getUIContext().getPromptAction().showToast({ message: '已到底部，可选择往期' });
      }
    } catch (e) {
      UtilLog.error(TAG, `Fail to . Code: ${e.code}, message: ${e.message}`);
    }
  }

  @Builder
  imageView(newspaperPage: NewsPageWithAreaInfo) {
    Stack() {
      Image(newspaperPage.preloadImg || newspaperPage.newsImg)
        .width(this.imgW)
        .height(this.imgH)
        .aspectRatio(this.imgRatio)
        .autoResize(true)
        .backgroundColor($r('app.color.img_bg'))
        .onComplete((event) => {
          if (event) {
            if (event.loadingStatus === 1) {
              this.imgRenderSize.width = this.getUIContext().px2vp(event.contentWidth);
              this.imgRenderSize.height = this.getUIContext().px2vp(event.contentHeight);
            }
            this.onContainerChange();
          }
        })
        .onSizeChange((_oldValue, newValue) => {
          if (newValue.width !== 0) {
            this.imgRenderSize.width = newValue.width as number;
            this.imgRenderSize.height = newValue.height as number;
          }
        })

      ForEach(newspaperPage.newsAreas, (area: NewsArea) => {
        Column()
          .width((area.right - area.left) * this.imgRenderSize.width)
          .height((area.bottom - area.top) * this.imgRenderSize.height)
          .stateStyles({
            normal: {
              .backgroundColor(Color.Transparent)
            },
            clicked: {
              .backgroundColor($r('app.color.pressed_bg'))
            },
          })
          .position({
            x: area.left * this.imgRenderSize.width,
            y: area.top * this.imgRenderSize.height,
          })
          .onClick(() => {
            this.jumpNewsDetail(area);
          })
      }, (area: NewsArea) => area.newsId + area.left + area.top)
    }
    .height(this.swiperH)
  }

  build() {
    Column() {
      Swiper(this.controller) {
        LazyForEach(this.dataSource, (v: NewsPageWithAreaInfo) => {
          this.imageView(v)
        }, (v: NewsPageWithAreaInfo) => v.id + v.paperId + v.newsName)
      }
      .height(this.swiperH)
      .vertical(true)
      .itemSpace(0)
      .index(this.currentPage)
      .loop(false)
      .indicator(false)
      .curve(Curve.Ease)
      .duration(500)
      .effectMode(EdgeEffect.Fade)
      .cachedCount(2)
      .onAnimationStart((index: number, targetIndex: number) => {
        this.$currentPage(targetIndex);
        this.onReachEnd(index, targetIndex);
      })

      Row()
        .width(this.imgRenderSize.width - 16)
        .height(Constant.BOTTOM_LAYOUT_HEIGHT)
        .backgroundColor($r('app.color.bottom_bar_1'))
      Row()
        .width(this.imgRenderSize.width - 32)
        .height(Constant.BOTTOM_LAYOUT_HEIGHT)
        .backgroundColor($r('app.color.bottom_bar_2'))
    }
  }
}
