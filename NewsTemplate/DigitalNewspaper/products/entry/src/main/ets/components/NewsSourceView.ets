import { Constant } from '../common/Constant';
import { NewsSource } from '../model/NewsSource'
import { ContentTag } from './ContentTag'

@ComponentV2
export struct NewsSourceView {
  @Param list: NewsSource[] = []
  @Param curNewsSource: NewsSource = new NewsSource();
  @Param newsIcon: ResourceStr = '';
  @Param text: string = '报纸';
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Event onItemClick: (item: NewsSource) => void = () => {
  };
  @Local showPopup: boolean = false;
  @Local scroller: Scroller = new Scroller();

  build() {
    ContentTag({
      icon: this.newsIcon,
      label: this.text,
      onClickEvent: () => {
        this.showPopup = !this.showPopup
      },
    })
      .bindPopup(this.showPopup, {
        builder: this.popupBuilder(),
        width: 120,
        arrowWidth: 16,
        arrowHeight: 9,
        offset: { x: -20 },
        placement: Placement.Top,
        popupColor: $r('sys.color.background_primary'),
        mask: { color: $r('sys.color.mask_secondary') },
        onStateChange: (event) => {
          this.showPopup = event.isVisible ? true : false
        },
      })
  }

  @Builder
  popupBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.list, (item: NewsSource) => {
        ListItem() {
          this.NewsBuilder(item.id, item.name)
        }
        .onClick(() => {
          this.showPopup = false;
          this.onItemClick(item);
        })
      }, (item: NewsSource) => item.id + item.name)
    }
    .onAppear(() => {
      setTimeout(() => {
        const index = this.list.findIndex(v => v.id === this.curNewsSource.id);
        if (index !== -1) {
          this.scroller.scrollToIndex(index, false, ScrollAlign.CENTER);
        }
      }, 50);
    })
    .width(Constant.FULL_PERCENT)
    .constraintSize({ maxHeight: 400 })
    .alignListItem(ListItemAlign.Center)
    .scrollBar(BarState.Off)
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
    })
    .padding({
      top: Constant.PADDING_XS,
      bottom: Constant.PADDING_XS,
      left: Constant.PADDING_M,
      right: Constant.PADDING_M,
    })
  }

  @Builder
  NewsBuilder(id: string, sourceName: string) {
    Text(sourceName)
      .fontSize($r('sys.float.Subtitle_M'))
      .fontColor(this.curNewsSource.id === id ? this.themeColor : $r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .lineHeight(24)
      .textAlign(TextAlign.Center)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width(Constant.FULL_PERCENT)
      .padding({
        top: Constant.PADDING_M,
        bottom: Constant.PADDING_M,
      })
  }
}
