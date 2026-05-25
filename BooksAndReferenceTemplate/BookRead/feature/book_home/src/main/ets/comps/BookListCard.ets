import {
  BookHomeCard,
  BookInfo,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  FontModel,
  MinorsMode,
  MinorsProtectionUtils,
  TCRouter
} from 'common';
import { LazyDataVM } from 'swiper_card'
import { AppStorageV2 } from '@kit.ArkUI';
import { fp2pxUtil } from 'base_common'

@ComponentV2
export struct BookListCard {
  // 今日力荐 展示两行书本 + 换一批按钮
  @Param categoryName: ResourceStr = '';
  @Param @Require books: LazyDataVM<BookInfo>
  @Local prep: number = 0;
  @Local angel: number = 0;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  @Builder
  bookCategoryBar(category: ResourceStr) {
    Row() {
      Text(category)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(this.fontModel.getFg(20))
        .fontWeight(FontWeight.Medium)
      Row() {
        Text($r('app.string.more'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(this.fontModel.getFg(14))
        Image($r('app.media.arrow_right'))
          .width(20)
          .height(20)
      }
      .onClick(() => {
        TCRouter.push(Constants.BOOK_LIST_ROUTE, { category: this.categoryName, books: this.books.getAllData() })
      })
    }
    .width('100%')
    .height(30)
    .margin({ top: 12, bottom: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  aboutToAppear(): void {
  }

  build() {
    Column() {
      if (!this.minorsMode.isMinorsMode) {
        this.bookCategoryBar(this.categoryName)
      }
      Grid() {
        LazyForEach(this.books, (item: BookInfo) => {
          GridItem() {
            BookHomeCard({ info: item })
          }
        }, (item: BookInfo) => item.id + '_' + item.name)
      }
      .layoutWeight(this.minorsMode.isMinorsMode ? 1 : 0)
      .cachedCount(6)
      .columnsTemplate(this.curBreakpoint.value === BreakpointTypeEnum.SM ? '1fr 1fr 1fr' : '1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate(this.minorsMode.isMinorsMode ? 'repeat(auto-fill,200)' :
        this.curBreakpoint.value === BreakpointTypeEnum.SM ? '1fr 1fr' : '1fr')
      .height(this.minorsMode.isMinorsMode ? 'auto' : this.curBreakpoint.value === BreakpointTypeEnum.SM ? 400 : 192)
      .rotate({ y: 1, angle: this.angel, perspective: this.prep })

      if (!this.minorsMode.isMinorsMode) {
        Row() {
          Text('换一批')
            .fontSize(fp2pxUtil(16))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .height(28)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .margin({ left: 24, right: 24, top: 12 })
        .onClick(() => {
          this.getUIContext().animateTo({
            duration: 1000,
            curve: Curve.EaseIn,
            iterations: 1,
            playMode: PlayMode.Normal,
            onFinish: () => {
              console.info('play end')
            }
          }, () => {
            this.angel += 360
          })
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_primary'))
  }
}