import { RecordItem } from '../common/RecordItem';
import { getBmiNavPathStack, setRouteParams } from '../common/Route';

@Extend(Text)
function mediumTextStyle() {
  .fontSize(16)
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
}

@Extend(Text)
function smallTextStyle() {
  .fontSize(12)
  .fontColor($r('sys.color.font_primary'))
}

@Extend(Text)
function titleTextStyle() {
  .fontSize(16)
  .fontColor($r('sys.color.font_primary'))
}

@Extend(Text)
function subtitleTextStyle() {
  .fontSize(14)
  .fontColor($r('sys.color.font_secondary'))
}

class RecordsDataSource implements IDataSource {
  private records: RecordItem[] = [];
  private listeners: DataChangeListener[] = [];
  constructor(records: RecordItem[]) {
    this.records = records;
  }
  totalCount(): number {
    return this.records.length;
  }
  getData(index: number): RecordItem {
    return this.records[index];
  }
  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }
  deleteRecordById(id: string): void {
    const index = this.records.findIndex(item => item.id === id);
    if (index >= 0) {
      this.records.splice(index, 1);
      this.notifyDataDelete(index);
    }
  }
  updateAllRecords(newRecords: RecordItem[]): void {
    this.records = newRecords;
    this.notifyDataReload();
  }
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }
}

@CustomDialog
struct DeleteConfirmDialog {
  controller?: CustomDialogController;
  item?: RecordItem;
  cancel: () => void = () => {};
  confirm: () => void = () => {};
  build() {
    Column() {
      Text('是否删除此数据？')
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 24, bottom: 24 })
        .width('100%')
        .textAlign(TextAlign.Center)

      Row() {
        Text('取消')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .height(44)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.cancel();
            if (this.controller !== undefined) {
              this.controller.close();
            }
          })

        Divider()
          .strokeWidth('2px')
          .color($r('sys.color.comp_divider'))
          .vertical(true)
          .height(24)
          .margin({ left: 8, right: 8 })

        Text('删除')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.warning'))
          .layoutWeight(1)
          .height(44)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.confirm();
            if (this.controller !== undefined) {
              this.controller.close();
            }
          })
      }
      .width('100%')
      .height(44)
      .margin({ bottom: 16 })
    }
    .width('90%')
    .borderRadius(24)
    .padding({ left: 16, right: 16 })
  }
}

@ComponentV2
export struct HistoryModal {
  @Param records: RecordItem[] = [];
  @Param @Require onDelete?: (id: string) => void;
  @Param @Require onClose?: () => void;
  @Local isSheetVisible: boolean = true;
  @Local dialogController?: CustomDialogController;
  @Local currentDialogItem?: RecordItem;

  private recordsDataSource: RecordsDataSource = new RecordsDataSource([]);
  aboutToDisappear() {
    this.dialogController = undefined;
  }
  aboutToAppear(): void {
    this.isSheetVisible = true;
    this.recordsDataSource.updateAllRecords([...this.records]);
  }
  build() {
    Column() {}
    .bindSheet(this.isSheetVisible, this.buildSheetContent(), {
      height: SheetSize.LARGE,
      preferType: SheetType.CENTER,
      backgroundColor: '#FAFAFA',
      title: { title: '历史记录' },
      dragBar: true,
      shouldDismiss: () => {
        this.onClose?.();
        return true;
      }
    })
    .onAppear(() => {
      this.isSheetVisible = true;
    })
  }

  @Builder
  buildSheetContent() {
    Column() {
      if (this.recordsDataSource.totalCount() > 0) {
        List({ space: 12 }) {
          LazyForEach(this.recordsDataSource, (item: RecordItem) => {
            ListItem() {
              this.HistoryItem(item)
            }
            .height(113)
          }, (item: RecordItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      } else {
        Column() {
          Image($r('app.media.ic_empty_bmi'))
            .width(100)
            .height(100)
            .margin({ bottom: 16 })
          Text('暂无历史记录')
            .titleTextStyle()
          Text('开始计算BMI来创建记录吧！')
            .subtitleTextStyle()
            .margin({ top: 8 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HistoryItem(item: RecordItem) {
    Column() {
      Text(item.date)
        .titleTextStyle()
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ bottom: 15 })
      Row() {
        Column({ space: 3 }) {
          Row({ space: 4 }) {
            Text(`${item.bmiValue.toFixed(1)}`)
              .mediumTextStyle()
              .align(Alignment.Bottom)
            Text(item.evaluation)
              .smallTextStyle()
              .fontColor(this.getBMIColor(item.bmiValue))
              .align(Alignment.Bottom)
          }
          .width('40%')
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Bottom)

          Row({ space: 4 }) {
            Text(`${item.height.toFixed(1)}cm`)
              .subtitleTextStyle()
            Text(`${item.weight.toFixed(1)}kg`)
              .subtitleTextStyle()
          }
          .width('40%')
          .justifyContent(FlexAlign.Start)
        }

        Row() {
          Text(item.time)
            .subtitleTextStyle()
          Image($r('app.media.history_to_result'))
            .width(12)
            .height(24)
            .margin({ left: 2 })
            .onClick(() => {
              setRouteParams({ recordId: item.id });
              getBmiNavPathStack().pushPathByName('BmiResultPage', null);
              this.onClose?.();
            })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({ width: 1, color: '#e8e8e8' })
    .height(113)
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.showDeleteDialog(item);
        })
    )
  }
  private createDeleteDialog(item: RecordItem): void {
    this.currentDialogItem = item;
    this.dialogController = new CustomDialogController({
      builder: DeleteConfirmDialog({
        item: item,
        cancel: () => {
          this.onDialogCancel();
        },
        confirm: () => {
          this.onDialogConfirm();
        }
      }),
      cancel: this.existApp,
      autoCancel: true,
      backgroundColor: Color.White,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -136 },
      customStyle: false
    });
  }
  private showDeleteDialog(item: RecordItem): void {
    this.createDeleteDialog(item);
    if (this.dialogController != null) {
      this.dialogController.open();
    }
  }
  private onDialogCancel() {
    console.info('用户取消了删除操作');
    this.currentDialogItem = undefined;
  }
  private onDialogConfirm() {
    console.info('用户确认删除');
    if (this.currentDialogItem) {
      this.handleDeleteItem(this.currentDialogItem);
    }
    this.currentDialogItem = undefined;
  }
  private existApp() {
    console.info('点击了空白区域');
  }
  private async handleDeleteItem(item: RecordItem): Promise<void> {
    if (!this.onDelete) {
      return;
    }
    try {
      this.onDelete(item.id);
      this.recordsDataSource.deleteRecordById(item.id);
    } catch (error) {
      console.error('删除失败:', error);
    }
  }
  private getBMIColor(bmi: number): ResourceColor {
    if (bmi < 18.5) {
      return '#ED6F21';
    } else if (bmi < 24) {
      return '#64BB5C';
    } else if (bmi < 28) {
      return '#ED6F21';
    } else {
      return '#E84026';
    }
  }
}
