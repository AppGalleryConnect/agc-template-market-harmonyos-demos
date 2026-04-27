import { NewsArea } from '../model/NewsArea';
import { NewsPageWithAreaInfo } from '../model/NewspaperPage';
import { BasicDataSource } from '../common/BasicDataSource';
import { Constant } from '../common/Constant';
import { ContentTag } from './ContentTag';
import { NewsDetailViewModel } from '../viewmodels/NewsDetailViewModel';

@ComponentV2
export struct DirectoryView {
  @Param content: NewsPageWithAreaInfo[] = [];
  @Param curIndex: number = 0;
  @Param contentIcon: ResourceStr = '';
  @Param text: string = '目录';
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Event onItemClick: (area: NewsArea) => void = () => {
  };
  @Event onPageChange: (index: number) => void = () => {
  };
  @Local private showSheet: boolean = false;
  @Local private scrollStatus: boolean = true;
  @Local private scroller: Scroller = new Scroller();
  @Local private dataSource: BasicDataSource<NewsPageWithAreaInfo> = new BasicDataSource();
  private vm: NewsDetailViewModel = new NewsDetailViewModel();

  aboutToAppear(): void {
    this.dataSource.setData(this.content);
    this.vm.listenSizeChange(this.getUIContext());
  }

  @Monitor('content')
  onIndexChange() {
    this.dataSource.setData(this.content);
  }

  @Computed
  get modelHeight() {
    if (this.vm.winHeight === 0 || this.vm.winHeight > 500) {
      return 660;
    }
    if (this.vm.winHeight >= 400) {
      return 400;
    }
    if (this.vm.winHeight >= 300) {
      return 280;
    }
    return 160;
  }

  build() {
    ContentTag({
      icon: this.contentIcon,
      label: this.text,
      onClickEvent: () => {
        this.showSheet = !this.showSheet;
        this.scrollStatus = true;
      },
    })
      .bindSheet($$this.showSheet, this.sheetBuilder(), {
        title: { title: this.text },
        height: this.modelHeight,
        showClose: true,
        preferType: SheetType.CENTER,
        mode: SheetMode.EMBEDDED,
      })
  }

  @Builder
  sheetBuilder() {
    List({ space: 0, scroller: this.scroller }) {
      LazyForEach(this.dataSource, (item: NewsPageWithAreaInfo) => {
        ListItemGroup({
          header: this.listTitleBuilder(item),
        }) {
          ListItem() {
            Column() {
              ForEach(item.newsAreas, (area: NewsArea, index: number) => {
                this.itemBuilderParam(area, index !== item.newsAreas.length - 1)
              }, (area: NewsArea) => area.newsId + area.left + area.top)
            }
          }
          .width(Constant.FULL_PERCENT)
        }
      }, (item: NewsPageWithAreaInfo) => item.id + item.newsName)
    }
    .width(Constant.FULL_PERCENT)
    .height(Constant.FULL_PERCENT)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .scrollBar(BarState.Off)
    .sticky(StickyStyle.None)
    .cachedCount(2)
    .onAppear(() => {
      this.scroller.scrollToIndex(this.curIndex);
      setTimeout(() => {
        this.scrollStatus = false;
      }, 50);
    })
    .onScrollIndex((index: number) => {
      if (!this.scrollStatus) {
        this.onPageChange(index);
      }
    })
    .padding({
      left: Constant.PADDING_L,
      right: Constant.PADDING_L,
      bottom: Constant.PADDING_L,
    })
  }

  @Builder
  listTitleBuilder(item: NewsPageWithAreaInfo) {
    Row({ space: Constant.PADDING_S }) {
      Divider()
        .strokeWidth(4)
        .vertical(true)
        .height(16)
        .color(this.themeColor)

      Text(item.newsName)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(24)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(Constant.FULL_PERCENT)
    .height(56)
    .padding({
      top: Constant.PADDING_XXL,
      bottom: Constant.PADDING_S,
    })
  }

  @Builder
  itemBuilderParam(item: NewsArea, showDivider: boolean) {
    Column() {
      Text(item.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .lineHeight(20)
        .lineSpacing({ value: 8, unit: 1 })
        .margin({ top: 14, bottom: 14 })
        .width(Constant.FULL_PERCENT)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
        .onClick(() => {
          this.onItemClick(item);
        })

      Divider().visibility(showDivider ? Visibility.Visible : Visibility.None)
    }
  }
}
