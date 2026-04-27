import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { CustomShareParams, RouterModule } from 'lib_foundation';
import { DateSelect } from '../components/DateSelect';
import { NewsSwiper } from '../components/NewsSwiper';
import { LayoutView } from '../components/LayoutView';
import { DirectoryView } from '../components/DirectoryView';
import { NewsSourceView } from '../components/NewsSourceView';
import { NewsArea } from '../model/NewsArea';
import { NewsSource } from '../model/NewsSource';
import { NewsPage, NewsPageWithAreaInfo } from '../model/NewspaperPage';
import { Constant, RouterMap } from '../common/Constant';
import { CircleButtonModifier } from '../common/CircleButtonModifier';
import { AreaModel } from '../model/AreaModel';
import { FormCardRouter } from '../widget/common/Types';

@ComponentV2
export struct DigitalNews {
  // 报纸版面列表
  @Param newspaperPages: NewsPage[] = [];
  // 报纸来源列表
  @Param newsSourceList: NewsSource[] = [];
  // 主题色
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  // 所选择的日期
  @Param selectDate: Date = new Date();
  // 所选择的报纸来源
  @Param selectNewsSource: NewsSource = new NewsSource();
  // 日期变化回调
  @Event onDateChange: (date: Date) => void = () => {
  };
  // 新闻来源变化回调
  @Event onNewsSourceChange: (source: NewsSource) => void = () => {
  };
  // 版面数字变化回调
  @Event onLayoutPageChange: (pageNum: number) => void = () => {
  };
  // 新闻区域点击回调
  @Event onAreaClick: (area: NewsArea) => void = () => {
  };
  @Provider() containerSize: AreaModel = new AreaModel();
  @Local newsPaperList: NewsPageWithAreaInfo[] = [];
  @Local swiperController: SwiperController = new SwiperController();
  @Local currentPage: number = 0;
  @Local btnModifier: CircleButtonModifier = new CircleButtonModifier();
  @Local isDirectionRow: boolean = false;
  @Local shareRouter: CustomShareParams =
    AppStorageV2.connect(CustomShareParams, 'handleShare', () => new CustomShareParams())!;
  @Local instance: CustomShareParams =
    AppStorageV2.connect(CustomShareParams, 'shareInstance', () => new CustomShareParams())!;
  @Local formCardRouter: FormCardRouter = AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
  private readonly BAR_HEIGHT: number = 2 * Constant.BOTTOM_LAYOUT_HEIGHT;
  private readonly TIP_HEIGHT: number = 32;

  aboutToAppear(): void {
    this.setSource();
    this.onListChange();
    this.onShareJump();
    this.onFormCardClick();
  }

  aboutToDisappear(): void {
    this.resetShareParams();
  }

  @Monitor('shareRouter.id')
  onShareJump() {
    if (this.shareRouter.id) {
      if (this.shareRouter.pageName === RouterMap.NEWS_DETAIL) {
        const currentName: string[] = RouterModule.getStack().getAllPathName();
        if (currentName.length && currentName[currentName.length-1] === RouterMap.NEWS_DETAIL) {
          RouterModule.replace({ url: RouterMap.NEWS_DETAIL, param: this.shareRouter.newsId });
        } else {
          RouterModule.push({ url: RouterMap.NEWS_DETAIL, param: this.shareRouter.newsId });
        }
      } else if (this.shareRouter.pageName === 'Main_Newspaper') {
        this.selectNewsSource.id = this.shareRouter.sourceId;
        this.selectNewsSource.name = this.shareRouter.sourceName;
        this.currentPage = this.newspaperPages.findIndex(item => item.id === this.shareRouter.newspaperId);
      } else {
        RouterModule.popToName(RouterMap.MAIN);
      }
    }
  }

  @Monitor('newspaperPages')
  onListChange() {
    this.newsPaperList = this.newspaperPages.map(v => new NewsPageWithAreaInfo(v));
    this.currentPage = 0;
    if (this.newspaperPages[this.currentPage]) {
      this.onCurrentPageChange();
    }
  }

  @Monitor('formCardRouter.id')
  onFormCardClick() {
    if (this.formCardRouter.id && this.formCardRouter.newsId && this.formCardRouter.pageUrl === RouterMap.NEWS_DETAIL) {
      const currentName: string[] = RouterModule.getStack().getAllPathName();
      if (currentName.length && currentName[currentName.length-1] === RouterMap.NEWS_DETAIL) {
        RouterModule.replace({ url: RouterMap.NEWS_DETAIL, param: this.formCardRouter.newsId });
      } else {
        RouterModule.push({ url: RouterMap.NEWS_DETAIL, param: this.formCardRouter.newsId });
      }
      this.formCardRouter.id = 0;
    }
  }

  @Monitor('currentPage')
  onCurrentPageChange() {
    this.instance.pageName = 'Main_Newspaper';
    this.instance.sourceId = this.selectNewsSource.id;
    this.instance.sourceName = this.selectNewsSource.name;
    this.instance.newspaperId = this.newspaperPages[this.currentPage].id;
  }

  setSource() {
    if (!this.selectNewsSource.id && this.newsSourceList.length) {
      this.selectNewsSource.id = this.newsSourceList[0].id;
      this.selectNewsSource.name = this.newsSourceList[0].name;
    }
  }

  resetShareParams() {
    this.instance.pageName = '';
    this.instance.sourceId = '';
    this.instance.sourceName = '';
    this.instance.newspaperId = 0;
  }

  onMainAreaChange(area: Area) {
    this.containerSize.bottomHeight = this.BAR_HEIGHT;
    this.containerSize.width = area.width as number;
    this.containerSize.height = area.height as number - this.containerSize.bottomHeight;
    const containerRatio = this.containerSize.width / this.containerSize.height;
    this.isDirectionRow = containerRatio >= Constant.WIDE_SCREEN_RATIO
    if (!this.isDirectionRow) {
      this.containerSize.bottomHeight = this.BAR_HEIGHT + this.TIP_HEIGHT;
      this.containerSize.height = area.height as number - this.containerSize.bottomHeight;
    }
  }

  @Computed
  get swiperTipRule() {
    if (this.isDirectionRow) {
      return {
        center: { anchor: Constant.SWIPER_ID, align: VerticalAlign.Center },
        left: { anchor: Constant.SWIPER_ID, align: HorizontalAlign.End },
      } as AlignRuleOption;
    }
    return {
      top: { anchor: Constant.SWIPER_ID, align: VerticalAlign.Bottom },
      middle: { anchor: Constant.SWIPER_ID, align: HorizontalAlign.Center },
    } as AlignRuleOption;
  }

  build() {
    Column() {
      this.topToolBuilder()
      this.mainBuilder()
      this.bottomToolBuilder()
    }
    .width(Constant.FULL_PERCENT)
    .layoutWeight(1)
  }

  @Builder
  topToolBuilder() {
    Row({ space: Constant.PADDING_S }) {
      DateSelect({
        selectedDate: this.selectDate,
        themeColor: this.themeColor,
        onDateSelected: (date: Date) => {
          this.onDateChange(date);
        },
      })
    }
    .width(Constant.FULL_PERCENT)
    .padding({
      top: Constant.PADDING_S,
      bottom: Constant.PADDING_S,
    })
  }

  @Builder
  mainBuilder() {
    Column() {
      RelativeContainer() {
        Column() {
          NewsSwiper({
            controller: this.swiperController,
            currentPage: this.currentPage!!,
            newspaperPages: this.newsPaperList,
            jumpNewsDetail: (area) => {
              this.onAreaClick(area);
            },
          })
        }
        .id(Constant.SWIPER_ID)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
        })

        Row({ space: Constant.PADDING_S }) {
          Flex({
            direction: this.isDirectionRow ? FlexDirection.Column : FlexDirection.Row,
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center,
            space: { main: new LengthMetrics(Constant.PADDING_S) },
          }) {
            Text('滑动查看下一版')
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            SymbolGlyph($r('sys.symbol.arrow_down'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor([$r('sys.color.font_primary')])
          }
          .width(this.isDirectionRow ? 16 : Constant.DEFAULT_AUTO)
          .margin({
            left: this.isDirectionRow ? Constant.PADDING_TIP : 0,
            top: this.isDirectionRow ? 0 : Constant.PADDING_S,
            bottom: this.isDirectionRow ? 0 : Constant.PADDING_S,
          })
        }
        .id(Constant.SWIPER_TIP_ID)
        .alignRules(this.swiperTipRule)
      }
      .visibility(this.newspaperPages.length > 0 ? Visibility.Visible : Visibility.Hidden)
    }
    .layoutWeight(1)
    .padding({
      top: Constant.PADDING_S,
      bottom: Constant.PADDING_S,
    })
    .onAreaChange((_o, n) => {
      this.onMainAreaChange(n);
    })
  }

  @Builder
  bottomToolBuilder() {
    Row() {
      LayoutView({
        totalCount: this.newsPaperList.length,
        curIndex: this.currentPage,
        themeColor: this.themeColor,
        onItemClick: (index: number) => {
          this.currentPage = index;
          this.swiperController.changeIndex(index, true);
          this.onLayoutPageChange(index);
        },
      })

      DirectoryView({
        content: this.newsPaperList,
        curIndex: this.currentPage,
        text: '目录',
        contentIcon: $r('sys.symbol.doc_plaintext'),
        themeColor: this.themeColor,
        onItemClick: (area: NewsArea) => {
          this.onAreaClick(area);
        },
        onPageChange: (index: number) => {
          this.currentPage = index;
        },
      })

      NewsSourceView({
        list: this.newsSourceList,
        curNewsSource: this.selectNewsSource,
        text: '报纸',
        newsIcon: $r('sys.symbol.doc_text'),
        themeColor: this.themeColor,
        onItemClick: (item: NewsSource) => {
          this.onNewsSourceChange(item);
        },
      })
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceAround)
    .padding({
      bottom: Constant.PADDING_S,
    })
  }
}