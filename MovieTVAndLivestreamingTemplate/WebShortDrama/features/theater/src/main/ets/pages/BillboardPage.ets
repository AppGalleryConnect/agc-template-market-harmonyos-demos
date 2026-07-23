import { getRankList } from '../mapper/DramaCoverMapper';
import { AiBarHeight, AppStorageKeys, StatusBarHeight } from '@agctemplate/widgets';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { DramaCoverVM } from '../viewmodels/DramaCoverVM';
import { RankList } from '../components/RankList';

@ComponentV2
struct BillboardPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local dramaList: Array<DramaCoverVM> = []
  @Consumer('rank') selectedCategory: string = ''
  @Local currentPageNum: number = 1
  @Consumer('scroll') scroller: Scroller = new Scroller()

  @Monitor('selectedCategory')
  async onSelectedCategoryChanged() {
    this.currentPageNum = 1
    this.dramaList = [] // 需要要设置为空，否则显示会异常
    this.scroller.scrollTo({
      xOffset: 0, yOffset: 0
    })
    this.dramaList = await getRankList(this.selectedCategory, this.currentPageNum)
  }

  async aboutToAppear() {
    this.dramaList = await getRankList(this.selectedCategory, this.currentPageNum)
  }

  build() {
    Flex({
      direction: FlexDirection.Column,
      space: {
        main: LengthMetrics.vp(8)
      }
    }) {
      Column() {
        RankList({
          dramaList: this.dramaList,
          scroller: this.scroller,
          loadNextPage: async () => {
            let arr = await getRankList(this.selectedCategory, ++this.currentPageNum)
            this.dramaList = this.dramaList.concat(arr)
          },
          isVertical: true
        })
      }
      .width('100%')
      .padding({ top: 8 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
  }
}

@Builder
export function BillboardPageBuilder(index: number) {
  BillboardPage()
}
