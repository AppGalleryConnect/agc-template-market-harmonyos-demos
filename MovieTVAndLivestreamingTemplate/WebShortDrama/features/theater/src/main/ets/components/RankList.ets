import { WindowManager } from '@agctemplate/utils'
import { AppStorageKeys, BreakPoint, BreakPointType, BreakPointValue } from '@agctemplate/widgets'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { onDramaClick } from './BannerPanel'
import { DramaCover } from './DramaCover'
import { AppStorageV2 } from '@kit.ArkUI'
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition'

@ComponentV2
export struct RankList {
  @Param @Require dramaList: Array<DramaCoverVM>
  @Param scroller: Scroller | undefined = undefined
  @Event loadNextPage: Function
  @Param @Require isVertical: boolean
  @Local currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;

  build() {
    List({ space: this.isVertical ? 16 : 0 }) {
      ForEach(
        this.dramaList,
        (drama: DramaCoverVM, index: number) => {
          ListItem() {
            DramaCover({ drama: drama, index: index + 1, isVertical: this.isVertical })
          }
          .padding( { bottom: index === this.dramaList.length - 1 ? 100 : 0})
          .id('RankList' + drama.dramaId)
          .margin({
            top: this.isVertical ? 0 : 12,
            // 水平排列时：让后两个元素的右侧加6个像素
            right: this.isVertical ? 0 :
              ([this.dramaList.length - 1, this.dramaList.length].indexOf(index + 1) !== -1 ? 12 : 6),
            bottom: this.isVertical ? 0 : 12,
            // 水平排列时：让前两个元素的左侧加6个像素
            left: this.isVertical ? 0 : ([1, 2].indexOf(index + 1) !== -1 ? 12 : 6)
          })
          .onClick(async () => {
            const longTakeTransitionParam: LongTakeTransitionParam | undefined =
              await LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(),
                'RankList' + drama.dramaId, 8);
            if (longTakeTransitionParam) {
              drama.longTakeTransitionParam = longTakeTransitionParam;
            }
            onDramaClick(drama,
              () => {
                WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
              })
          })
        },
        (drama: DramaCoverVM, index: number) => drama.dramaId + index
      )
    }
    .width('100%')
    .height(this.isVertical ? 'auto' : 176)
    .listDirection(this.isVertical ? Axis.Vertical : Axis.Horizontal)
    .lanes(new BreakPointType<number>({ sm: 1, md: 2, lg: 3 }).getValue(this.currentBreakpoint.value),
      new BreakPointType<number>({ sm: 0, md: 16, lg: 12 }).getValue(this.currentBreakpoint.value))
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .onScrollIndex((start: number, end: number) => {
      if (end >= this.dramaList.length - 1) {
        this.loadNextPage()
      }
    })
  }
}