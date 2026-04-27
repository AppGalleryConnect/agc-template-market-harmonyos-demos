import { Constant } from '../common/Constant';
import { ContentTag } from './ContentTag';

@ComponentV2
export struct LayoutView {
  @Param totalCount: number = 0;
  @Param curIndex: number = 0;
  @Param text: string = '版面';
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Event onItemClick: (index: number) => void = () => {
  };
  @Local private showPopup: boolean = false;

  @Computed
  get generateList() {
    const list: string[] = [];
    for (let index = 0; index < this.totalCount; index++) {
      list.push((index + 1).toString().padStart(2, '0'));
    }
    return list;
  }

  build() {
    ContentTag({
      pageNum: this.curIndex + 1,
      label: this.text,
      onClickEvent: () => {
        this.showPopup = true;
      },
    })
      .bindPopup(this.showPopup, {
        builder: this.popupBuilder(),
        arrowWidth: 16,
        arrowHeight: 9,
        offset: { x: 20 },
        placement: Placement.Top,
        popupColor: $r('sys.color.background_primary'),
        mask: { color: $r('sys.color.mask_secondary') },
        onStateChange: (event) => {
          this.showPopup = event.isVisible ? true : false;
        },
      })
  }

  @Builder
  popupBuilder() {
    Grid() {
      ForEach(this.generateList, (item: string, index: number) => {
        GridItem() {
          this.numberBuilder(item, index)
        }
        .onClick(() => {
          this.onItemClick(index);
          this.showPopup = false;
        })
      }, (item: string) => item)
    }
    .scrollBar(BarState.Off)
    .padding({
      top: Constant.PADDING_M,
      bottom: Constant.PADDING_M,
      left: Constant.PADDING_XXL,
      right: Constant.PADDING_XXL,
    })
    .width(256)
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .maxCount(20)
    .rowsGap(Constant.PADDING_L)
    .columnsGap(Constant.PADDING_L)
  }

  @Builder
  numberBuilder(num: string, index: number) {
    Row() {
      Text(num)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(this.curIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
    }
    .borderRadius(Constant.HALF_PERCENT)
    .backgroundColor(this.curIndex === index ? this.themeColor : null)
    .justifyContent(FlexAlign.Center)
    .width(40)
    .height(40)
  }
}
