import { PersistenceV2 } from '@kit.ArkUI';
import { CanvasState, DrawHistory } from '../model/Model';
import { DrawBoardVM } from '../viewmodel/DrawVM';
import { TimeUtils } from '../utils/TimeUtils';
import { baseToast } from './ConfirmDialog';

@Builder
export function CanvasSaveListBuilder() {
  CanvasSaveList()
}

@ComponentV2
export struct CanvasSaveList {
  @Local drawHistory: DrawHistory = PersistenceV2.connect(DrawHistory, () => new DrawHistory())!;
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance

  @Builder
  drawTitle(index:number) {
    Column() {
      TextInput({
        text: this.drawHistory.drawInfoList[index]?.title,
        placeholder: '请输入名称',
      })
        .onChange((value) => {
          this.drawBoardVM.title = value
        })
    }
  }

  @Builder
  itemEnd(index: number) {
    Row() {
      Row() {
        Image($r('app.media.draw_delete'))
          .width(16)
          .height(18)
      }
      .onClick(() => {
        baseToast.show({
          type: 'dialog',
          hasTitle: '提示',
          message: '是否确认删除当前画布？',
          confirmAction: () => {
            baseToast.hide();
            this.drawHistory.drawInfoList.splice(index, 1)
            PersistenceV2.save(DrawHistory)
          },
        }, this.getUIContext());

      })
      .justifyContent(FlexAlign.Center)
      .width(40)
      .height(40)
      .borderRadius('50%')
      .margin({ left: 16 })
      .backgroundColor($r('sys.color.warning'))
      Row() {
        Image($r('app.media.draw_edit'))
          .width(16)
          .height(18)
      }
      .onClick(() => {
        baseToast.show({
          type: 'dialog',
          messageBuilder: () => {
            this.drawTitle(index)
          },
          confirmAction: () => {
            if (this.drawBoardVM.validate(this.getUIContext())) {
              this.drawHistory.drawInfoList[index].title =  this.drawBoardVM.title
              PersistenceV2.save(DrawHistory)
              this.drawBoardVM.title = ''
              baseToast.hide()
            }
          },
          cancelAction: () => {
            this.drawBoardVM.title = ''
          },
        }, this.getUIContext());
      })
      .justifyContent(FlexAlign.Center)
      .width(40)
      .height(40)
      .borderRadius('50%')
      .margin({ left: 16 })
      .backgroundColor($r('sys.color.alert'))
    }
  }

  build() {
    NavDestination() {
      List({ space: 16 }) {
        ListItem() {
          Column({ space: 12 }) {
            Image($r('app.media.draw_empty'))
              .width(200)
              .draggable(false)
            Text('暂无保存记录')
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .height('90%')
        }
        .visibility(this.drawHistory.drawInfoList.length ? Visibility.None : Visibility.Visible)

        ForEach(this.drawHistory.drawInfoList, (item: CanvasState, index: number) => {
          ListItem() {
            Row() {
              Column({ space: 8 }) {
                Text(item.title)
                Text(TimeUtils.formatDate(item.time))
              }
              .width('50%')
              .alignItems(HorizontalAlign.Start)

              Image(item.thumbnail)
                .width(48)
                .height(48)
                .borderRadius(16)
                .clip(true)
            }
            .padding(16)
            .width('100%')
            .backgroundColor($r('sys.color.background_primary'))
            .borderRadius(16)
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              let params: Record<string, string | CanvasState> = { 'mode': 'edit', 'canvasInfo': item }
              this.drawBoardVM.currentEditIndex = index
              this.drawBoardVM.pathStack.pop(params)
            })
          }
          .swipeAction({
            end: {
              builder: () => {
                this.itemEnd(index)
              },
            },
          })
        }, (item: CanvasState, index: number) => index + JSON.stringify(item))
      }
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('文件管理')
  }
}