import { AlertDialog } from '@kit.ArkUI';
import { TitleBar } from '../components/TitleBar';
import { HistoryInfo } from '../model/History';
import { TranLogger } from '../util/TranLogger';
import { HistoryPageVM } from '../viewmodel/HistoryPageVM';

@Builder
export function HistoryPageBuilder() {
  HistoryPage();
}

@ComponentV2
export struct HistoryPage {
  vm: HistoryPageVM = HistoryPageVM.instance;
  private scroller: ListScroller = new ListScroller();
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '是否删除此文件？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.dialogControllerConfirm.close();
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.removeHistory();
          this.dialogControllerConfirm.close();
        },
      },
    }),
  });
  dialogControllerAllConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '是否删除所有文件？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.dialogControllerAllConfirm.close();
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.history.clear()
          this.dialogControllerAllConfirm.close();
        },
      },
    }),
  });

  @Builder
  itemEnd(id: string) {
    Row() {
      Image($r('app.media.tran_envelope'))
        .width(40)
        .height(40)
        .margin({ left: 16 })
        .onClick(() => {
          this.vm.delId = id;
          this.dialogControllerConfirm.open();
        });
    }
  }

  aboutToAppear(): void {
    this.vm.expandIndex = -1;
  }

  aboutToDisappear(): void {
    this.vm.expandIndex = -1;
  }

  build() {
    NavDestination() {
      TitleBar({
        name: `翻译记录`,
        img: $r('sys.symbol.trash'),
        onClear: () => {
          if (this.vm.history.list.length > 0) {
            this.dialogControllerAllConfirm.open()
          }
        }
      })
      if (this.vm.history.list.length) {
        List({ scroller: this.scroller }) {
          ForEach(this.vm.history.list, (item: HistoryInfo, index) => {
            ListItem() {
              Column({ space: 16 }) {
                Row() {
                  Text(item.input)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontWeight(FontWeight.Medium)
                    .maxLines(5)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .width('100%')
                .padding({ top: 8 })

                Divider()

                Row() {
                  Text(item.output)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontWeight(FontWeight.Medium)
                    .maxLines(5)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .width('100%')
                .padding({ bottom: 8 })
              }
              .width('100%')
              .borderRadius(16)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .padding({ left: this.vm.expandIndex === index ? 36 : 12, right: 12 })
              .animation({
                duration: 300,
                curve: Curve.Linear,
                playMode: PlayMode.Normal,
              });
            }
            .borderRadius(16)
            .margin({ bottom: 12 })
            .swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(item.id);
                },
                onStateChange: (state: SwipeActionState) => {
                  if (state === SwipeActionState.COLLAPSED) {
                    this.vm.expandIndex = -1;
                  }
                  if (state === SwipeActionState.EXPANDED) {
                    this.vm.expandIndex = index;
                  }
                },
              }, edgeEffect: SwipeEdgeEffect.Spring,
            });
          }, (item: HistoryInfo) => item.id);
        }
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .scrollBar(BarState.Off);
      } else {
        Text('——暂无记录——').margin({ top: 40 }).fontColor($r('sys.color.font_secondary'));
      }
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      try {
        this.scroller.closeAllSwipeActions();
      } catch (e) {
        TranLogger.error(JSON.stringify(e))
      }
      return false
    })
  }
}


