import { ListEndSwiperAction } from '../common/ListEndSwiperAction';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { TodoListBox } from '../common/TodoListBox';
import { COL_SPAN, GRID_ROW_OPTIONS } from '../../constants/Constants';

@ComponentV2
export struct TodoList {
  @Local calendarEventVM: CalendarEventVM = CalendarEventVM.instance;
  @Param todoList: UserEventItem[] = []

  @Computed
  get todoInfoList() {
    return this.todoList.filter(item => !item.isDone)
  }

  @Computed
  get doneInfoList() {
    return this.todoList.filter(item => item.isDone)
  }

  @Builder
  todoHeader(text: string) {
    Column() {
      Text(text)
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 12 })
    }
  }

  @Builder
  itemEnd(item: UserEventItem) {
    ListEndSwiperAction({
      userEventInfo: item,
    })
  }

  @Builder
  todoListBuilder() {
    Scroll() {
      Column() {
        Column() {
          Column() {
            Image($r('app.media.no_data')).width(120).height(120)
            Text('暂无重要提醒')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .visibility(this.todoList.length ? Visibility.None : Visibility.Visible)

        Column() {
          Column() {
            Text('未完成')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ bottom: 12 })
            GridRow(GRID_ROW_OPTIONS) {
              ForEach(this.todoInfoList, (item: UserEventItem) => {
                GridCol({
                  span: COL_SPAN,
                }) {
                  List() {
                    ListItem() {
                      TodoListBox({
                        isBoxDone: false,
                        todoInfo: item,
                        onChange: () => {
                          item.isDone = true
                        },
                      })
                    }
                    .swipeAction({
                      end: {
                        builder: () => {
                          this.itemEnd(item)
                        },
                        onAction: () => {
                          this.getUIContext()?.animateTo({ duration: 1000 }, () => {
                            this.calendarEventVM.deleteUserEventInfo(this.getUIContext(), item)
                          });
                        },
                      },
                    })

                  }
                  .scrollBar(BarState.Off)
                  .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                }
              }, (item: UserEventItem) => JSON.stringify(item))
            }
          }.visibility(this.todoList.length ? Visibility.Visible : Visibility.None)
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column() {
            Column() {
              Text('已完成')
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ bottom: 12 })
              GridRow(GRID_ROW_OPTIONS) {
                ForEach(this.doneInfoList, (item: UserEventItem) => {
                  GridCol({
                    span: COL_SPAN,
                  }) {
                    List() {
                      ListItem() {
                        TodoListBox({
                          isBoxDone: true,
                          todoInfo: item,
                          onChange: () => {
                            item.isDone = false
                          },
                        })
                      }
                      .swipeAction({
                        end: {
                          builder: () => {
                            this.itemEnd(item)
                          },
                          onAction: () => {
                            this.getUIContext()?.animateTo({ duration: 1000 }, () => {
                              this.calendarEventVM.deleteUserEventInfo(this.getUIContext(), item)
                            });
                          },
                        },
                      })
                    }
                    .scrollBar(BarState.Off)
                    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                  }
                }, (item: UserEventItem) => JSON.stringify(item))
              }
            }
            .width('100%')
            .margin({ top: 16 })
            .alignItems(HorizontalAlign.Start)
          }.visibility(this.todoList.length ? Visibility.Visible : Visibility.None)
        }
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_primary'))
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
    .padding({ bottom: 16, top: 16 })
  }

  build() {
    this.todoListBuilder()
  }
}