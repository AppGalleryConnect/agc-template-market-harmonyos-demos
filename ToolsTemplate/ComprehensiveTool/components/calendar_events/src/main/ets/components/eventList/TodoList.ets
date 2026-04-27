import { ListEndSwiperAction } from '../common/ListEndSwiperAction';
import { UserEventItem } from '../../model/UserEventModel';
import CalendarEventVM from '../../viewModel/ViewModel';
import { TodoListBox } from '../common/TodoListBox';

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
    List() {
      ListItem() {
        Column() {
          Image($r('app.media.no_data')).width(120).height(120)
          Text('暂无重要提醒')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .margin({ top: '40%' })
      }
      .visibility(this.todoList.length ? Visibility.None : Visibility.Visible)

      ListItem() {
        Column() {
          Text('未完成')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ bottom: 12 })
          List({ space: 12 }) {
            ForEach(this.todoInfoList, (item: UserEventItem) => {
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
                },
              })
            }, (item: UserEventItem) => JSON.stringify(item))
          }
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }.visibility(this.todoList.length ? Visibility.Visible : Visibility.None)

      ListItem() {
        Column() {
          Text('已完成')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ bottom: 12 })
          List({ space: 12 }) {
            ForEach(this.doneInfoList, (item: UserEventItem) => {
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
                },
              })
            }, (item: UserEventItem) => JSON.stringify(item))
          }
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .margin({ top: 16 })
        .alignItems(HorizontalAlign.Start)
      }.visibility(this.todoList.length ? Visibility.Visible : Visibility.None)
    }
    .layoutWeight(1)
    .padding({ bottom: 16 })
    .scrollBar(BarState.Off)
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    Column() {
      List() {
        ListItem() {
          this.todoListBuilder()
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .margin({ top: 12 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
  }
}