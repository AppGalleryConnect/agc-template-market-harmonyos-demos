import { emitter } from '@kit.BasicServicesKit';
import { EmptyView } from '../components/EmptyView';
import { DiaryItemCard } from '../components/DiaryItemCard';
import { Diary } from '../models/Diary';
import { DiaryPageVM } from '../viewmodel/DiaryPageVM';
import { MoreMenuView } from '../components/MoreMenuView';
import { WindowUtil } from '../utils/WindowUtil';
import { Logger } from '../utils/Logger';

@Builder
export function DiaryPageBuilder() {
  DiaryPage();
}

@ComponentV2
export struct DiaryPage {
  vm: DiaryPageVM = new DiaryPageVM(this.getUIContext());

  aboutToAppear(): void {
    WindowUtil.init(this.getUIContext());
    try {
      emitter.on('refreshDiaryListEvent', () => {
        this.vm.initData()
      })
    } catch (e) {
      Logger.error('[DiaryPage]', `emitter on refreshDiaryListEvent failed. error: ${JSON.stringify(e)}`)
    }
  }

  aboutToDisappear(): void {
    this.vm.pageDestroy()
  }

  build() {
    NavDestination() {
      Column() {
        // 日期筛选栏
        this.filterBarBuilder()
        // 日记列表
        if (this.vm.diaryList.length) {
          this.diaryListView()
        } else {
          EmptyView()
        }
        // 新增日记按钮
        Button() {
          SymbolGlyph($r('sys.symbol.pencil_waveform_fill'))
            .fontColor([$r('sys.color.white')])
            .fontSize(24)
        }
        .width(40)
        .height(40)
        .zIndex(10)
        .position({ right: 24, bottom: 110 })
        .backgroundColor($r('app.color.diary_primary_color'))
        .onClick(() => {
          this.vm.createDiary()
        })
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .height('100%')
    }
    .title('日记')
    .menus(this.moreView())
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx) => {
      this.vm.pathStack = ctx.pathStack;
      this.vm.initData()
    })
  }

  @Builder
  filterBarBuilder() {
    Row() {
      Row() {
        Text(this.vm.dateLabel)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium);
        Image($r('app.media.ic_arrow_bottom'))
          .width(24)
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding({
        left: 16,
        right: 8,
        top: 8,
        bottom: 8,
      })
      .borderRadius(50)
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.vm.openDiaryFilterSheet();
      })
    }
    .width('100%')
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  diaryListView() {
    Column() {
      List({ space: 12, scroller: this.vm.listScroller }) {
        Repeat(this.vm.diaryList)
          .each((diaryItem: RepeatItem<Diary>) => {
            ListItem() {
              DiaryItemCard({
                item: diaryItem.item,
                onClickAction: ()=> {
                  this.vm.clickItemCard(diaryItem.item);
                },
                onDeleteAction: () => {
                  this.vm.deleteDiary(diaryItem.item);
                },
                onHandlePrivacyAction: () => {
                  this.vm.handlePrivacyDiary(diaryItem.item);
                }
              })
            }
            .transition({ type: TransitionType.Delete, opacity: 0 })
            .swipeAction({
              end: this.ItemEnd(diaryItem.item)
            })
          })
          .key((item: Diary) => JSON.stringify(item))
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      })
    }
    .width('100%')
    .padding({ top: 12 })
    .layoutWeight(1)
  }

  @Builder
  ItemEnd(item: Diary) {
    Row() {
      ItemEndBtnView({
        symbol: item.isPrivacy ? 'sys.symbol.lock_open_fill' : 'sys.symbol.lock_fill',
        text: item.isPrivacy ? '取消私密' : '设为私密',
        onClickAction: () => {
          this.vm.handlePrivacyDiary(item);
        }
      })

      ItemEndBtnView({
        symbol: 'sys.symbol.trash_fill',
        text: '删除',
        onClickAction: () => {
          this.vm.deleteDiary(item)
        }
      })
        .margin({ left: 8 })
    }
    .padding({ left: 16 })
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  moreView() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontColor([$r('sys.color.font_primary')])
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .bindMenu(this.moreMenuView)
    }
    .height('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .margin({ right: 16 });
  }

  @Builder
  moreMenuView() {
    MoreMenuView({
      list: this.vm.moreMenuList,
      menuWidth: 224
    })
  }
}


@ComponentV2
struct ItemEndBtnView {
  @Param symbol: string = '';
  @Param text: string = '';
  @Event onClickAction: () => void = () => {}

  build() {
    Column({ space: 4 }) {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r(this.symbol))
          .fontColor([$r('sys.color.white')])
          .fontSize(14)
      }
      .width(20)
      .height(20)
      .backgroundColor('#ef94a9')

      Text(this.text)
        .fontColor(Color.White)
        .fontSize(10)
    }
    .width(56)
    .height('100%')
    .borderRadius(16)
    .backgroundColor($r('app.color.diary_primary_color'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onClickAction?.()
    })
  }
}