import { TaskItem } from '../types/Types'
import { AgencyTaskListItem } from './AgencyTaskListItem';
import {
  CommonConstants,
  AppStorageData,
  RouterModule,
  DialogMap,
  MainEntryVM
} from '@ohos_agcit/office_attendance_common_lib';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { RequestProxy } from '../api/RequestProxy';
import { ConfirmView } from '@ohos_agcit/office_attendance_component_lib';

@ComponentV2
export struct AgencyTaskView {
  vm: MainEntryVM = MainEntryVM.instance;
  private controller: Scroller = new Scroller();
  @Local myStorage: AppStorageData =
    AppStorageV2.connect(AppStorageData, CommonConstants.APP_STORAGE_DATA_KEY, () => new AppStorageData())!;
  @Local agencyTasks: TaskItem[] = [];
  @Local selectIdx: number = 0;
  @Local searchTxt: string = '';
  taskID: string | undefined;

  public newAgencyTask() {
    RouterModule.openDialog(DialogMap.NEW_AGENCY_TASK, {
      onPop: () => {
        this.load();
      }
    });
  }

  aboutToAppear(): void {
    this.load();
  }

  edit(item: TaskItem) {
    RequestProxy.editTask(item).then(resp => {
      promptAction.showToast({ message: $r('app.string.edit_success') })
    });
  }

  load() {
    let isQueryFinishedTask = this.selectIdx === 1;
    this.agencyTasks.length = 0;
    RequestProxy.queryTasks(this.searchTxt, isQueryFinishedTask).then((data) => {
      data.forEach(t => {
        this.agencyTasks.push(t);
      })
    })
  }

  search() {
    this.load();
  }

  isUnfinishedPage() {
    return this.selectIdx === 0;
  }

  isEmptyTasks() {
    return this.agencyTasks.length === 0;
  }

  private dController: CustomDialogController = new CustomDialogController({
    builder: ConfirmView({
      titleResID: $r('app.string.delete_agency_title'),
      contentResID: $r('app.string.delete_agency_content'),
      btnConfirmResID: $r('app.string.btn_delete'),
      btnConfirmFontColor: $r('app.color.crimson'),
      confirm: () => {
        let taskID = this.taskID;
        this.taskID = undefined;
        if (taskID) {
          RequestProxy.deleteTask(taskID);
          this.agencyTasks = this.agencyTasks.filter(t => t.taskID !== taskID);
        }
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: false
  })

  @Builder
  deleteButton(taskID: string) {
    Column() {
      Text($r('app.string.btn_delete'))
        .fontColor(Color.White)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
    }
    .width(48)
    .height(56)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Red)
    .onClick(() => {
      this.taskID = taskID;
      this.dController.open();
    })
  }

  build() {
    Stack() {
      Row() {
        Column() {
          Blank().height('2%').width('100%')

          Search({ placeholder: $r('app.string.search_tip') })
            .height(40)
            .width('100%')
            .textFont({ size: 16, weight: FontWeight.Regular })
            .margin({ top: 0, bottom: 0 })
            .onChange((data: string) => {
              this.searchTxt = data;
              this.search();
            })
            .onSubmit((data: string) => {
              this.searchTxt = data;
              this.search();
            })

          Blank().height('2%').width('100%')

          Row() {
            ForEach(CommonConstants.AGENCY_TASK_TABS, (item: string, index: number) => {
              Column() {
                Text(item)
                  .fontSize('14')
                  .fontWeight(FontWeight.Medium)
                  .fontColor(index === this.selectIdx ? '#3093FA' : '#000000')
                  .opacity(index === this.selectIdx ? 1 : 0.6)
                  .width(42)
                  .borderRadius(4)
              }
              .width('50%')
              .justifyContent(FlexAlign.Start)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.selectIdx = index;
                this.load();
              })
            }, (item: string, index: number) => index + item)
          }
          .height(19)
          .width('100%')

          Row() {
            Column() {
              Blank().width(42).height(2).color(this.selectIdx === 0 ? '#3093FA' : Color.White)
            }.width('50%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Blank().width(42).height(2).color(this.selectIdx === 1 ? '#3093FA' : Color.White)
            }.width('50%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)
          }.width('100%')

          List({ scroller: this.controller }) {
            ForEach(this.agencyTasks, (item: TaskItem, index) => {
              ListItem() {
                AgencyTaskListItem({
                  checkCallback: (checked: boolean) => {
                    item.isFinished = checked;
                    this.edit(item);
                    this.load();
                  },
                  editCallback: () => {
                    this.load()
                  },
                  item: item
                })
              }.swipeAction({ end: this.deleteButton(item.taskID) })
            })
          }
          .height('100%')
          .width('100%')
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Auto)
          .padding({ left: 12, right: 8 })
          .edgeEffect(EdgeEffect.Spring)
          .multiSelectable(false)
          .chainAnimation(true)
          .layoutWeight(1)
          .visibility(this.isEmptyTasks() ? Visibility.None : Visibility.Visible)

          Column() {
            Blank().width('100%').height('13%')
            Column() {
              Column() {
                Image($r('app.media.ic_no_schedule')).width(120).height(120);
              }.width('100%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)

              Column() {
                Text($r('app.string.no_agency')).fontSize(14).fontWeight(FontWeight.Regular)
              }.width('100%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
          }.visibility(this.isEmptyTasks() && this.isUnfinishedPage() ? Visibility.Visible : Visibility.None)
        }.height('100%')
        .width('92%')
      }.height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)


      Image($r('app.media.ic_plus_filled'))
        .height(60)
        .width(60)
        .onClick(() => {
          this.newAgencyTask();
        }).position({ x: this.myStorage.windowWidthVp * 0.8, y: this.myStorage.windowHeightVp * 0.7 })

    }
  }
}