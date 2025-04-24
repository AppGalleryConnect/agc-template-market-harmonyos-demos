import { TaskItem } from '../types/Types';
import { i18n } from '@kit.LocalizationKit';
import { ConfirmView, DateTimeElement, TitleBar } from '@ohos_agcit/office_attendance_component_lib';
import {
  DateUtils,
  DialogMap,
  FormatUtil,
  RouterMap,
  RouterModule,
  StringUtils
} from '@ohos_agcit/office_attendance_common_lib';
import { PlanTimeSetting } from './components/PlanTimeSetting';
import { AttachUpload } from './components/AttachUpload';
import { RequestProxy } from '../api/RequestProxy';
import { promptAction } from '@kit.ArkUI';

@Builder
function editAgencyTaskBuilder() {
  EditAgencyTask();
}

@ComponentV2
export struct EditAgencyTask {
  scroller: Scroller = new Scroller()
  @Local taskID: string | undefined = '';
  @Provider() fullPathImages: Array<string> = [];
  @Provider() planDatetime: string = '';
  @Provider() planTime: DateTimeElement | undefined;
  @Local parentAgencyTask: TaskItem = {}
  @Local agencyTask: TaskItem = {}
  @Local subAgencyTasks: TaskItem[] = []
  @Local isEdit: boolean = false;

  init(): void {
    this.taskID = RouterModule.getNavParam({ url: RouterMap.EDIT_AGENCY_TASK });
    this.load();
  }

  load() {
    if (this.taskID) {
      this.subAgencyTasks.length = 0;
      RequestProxy.querySubTasks(this.taskID).then(data => {
        this.subAgencyTasks = data;
      })
      RequestProxy.queryTaskByID(this.taskID).then(data => {
        if (data) {
          this.agencyTask = data;
          if (this.agencyTask?.parentID) {
            RequestProxy.queryTaskByID(this.agencyTask.parentID).then(data => {
              if (data) {
                this.parentAgencyTask = data;
              }
            })
          }
          if (this.agencyTask.imgList) {
            this.fullPathImages = this.agencyTask.imgList;
          }
          if (this.agencyTask.planTime) {
            let date = new Date(this.agencyTask.planTime);
            let calendar = i18n.getCalendar('en-US');
            calendar.setTime(date);
            this.planTime =
              new DateTimeElement(calendar.get(DateUtils.YEAR), calendar.get(DateUtils.MONTH),
                calendar.get(DateUtils.DATE),
                calendar.get('hour_of_day'), calendar.get('minute'));
            this.planDatetime = FormatUtil.formatDate(this.planTime.getDate(), FormatUtil.DATE_YYYY_MM_DD_24H_mm_ss);
          }
        }
      })
    }
  }

  aboutToAppear(): void {
    this.init();
  }

  hide() {
    animateTo({
      duration: 300,
      curve: Curve.Friction,
      onFinish: () => {
        RouterModule.popWithParam([], true);
      },
    }, () => {
    });
  }

  gotoAgencyTask(task: TaskItem): void {
    RouterModule.push({
      url: RouterMap.EDIT_AGENCY_TASK, param: task.taskID, onPop: () => {
        this.load();
      }
    })
  }

  addSubTask(): void {
    RouterModule.openDialog(DialogMap.NEW_AGENCY_TASK,
      {
        param: this.taskID,
        onPop: () => {
          this.load();
        }
      }
    )
  }

  editTask() {
    if (this.isEdit) {
      if (StringUtils.isBlank(this.agencyTask.title)) {
        promptAction.showToast({ message: $r('app.string.agency_title_empty_tip') })
        this.getUIContext().getFocusController().requestFocus('titleID');
        return;
      }
      this.saveTask(this.agencyTask)
    }
  }

  saveTask(task: TaskItem) {
    RequestProxy.editTask(task).then(() => {
      promptAction.showToast({ message: $r('app.string.edit_success') })
    })
    this.load();
  }

  build() {
    NavDestination() {
      Column() {

        Row() {
          Column().width('4%');
          Column() {
            /******************头部信息******************/
            TitleBar({
              leftImgResID: 'app.media.ic_public_small_left',
              rightImgResID: '',
              titleResID: 'app.string.edit_agency_task',
              bgColor: Color.White,
              hide: () => {
                this.hide()
              },
              callback: () => {
              }
            })
          }.layoutWeight(1)

          Column().width('4%');
        }.backgroundColor(Color.White)

        Column({ space: 8 }) {
          /******************父节点信息******************/
          Row() {
            Column().width('4%')
            Column() {
              Column().height('2%')
              Row() {
                Row() {
                  Text($r('app.string.agency_parent_tip')).fontSize(14).fontWeight(FontWeight.Regular).opacity(0.6)
                  Text(this.parentAgencyTask?.title)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .opacity(0.6)
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .layoutWeight(1)

                Column() {
                  Image($r('app.media.ic_public_small_right'))
                    .height(12)
                    .width(12)
                    .opacity(0.2)
                }.alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.End)
              }
              .height(48)
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .backgroundColor(Color.White)
              .visibility(this.agencyTask.parentID ? Visibility.Visible : Visibility.None)
              .onClick(() => {
                this.gotoAgencyTask(this.parentAgencyTask);
              })

              /******************标题+备注信息******************/
              Column() {
                Row() {
                  Checkbox({ name: 'checkBox', group: 'checkBoxGroup' })
                    .select(this.agencyTask.isFinished)
                    .width(20)
                    .height(20)
                    .borderRadius(4)
                    .backgroundColor($r('app.color.white'))
                    .border({ color: $r('app.color.black_1'), style: BorderStyle.Solid })
                    .selectedColor($r('app.color.sys_default_blue'))
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .margin({ bottom: 16 })
                    .onClick(() => {
                      this.agencyTask.isFinished = !this.agencyTask.isFinished;
                      this.isEdit = true;
                    })

                  TextArea({ text: this.agencyTask.title })
                    .placeholderFont({ size: 20, weight: 'Bold' })
                    .backgroundColor(Color.White)
                    .id('titleID')
                    .fontSize(16)
                    .borderRadius(0)
                    .fontWeight(FontWeight.Medium)
                    .opacity(0.9)
                    .padding({ left: '2%', right: 0 })
                    .layoutWeight(1)
                    .maxLength(50)
                    .showCounter(true)
                    .onChange((value: string) => {
                      if (this.agencyTask.title !== value) {
                        this.isEdit = true;
                      }
                      this.agencyTask.title = value;
                    })
                }.width('100%')
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .constraintSize({ maxHeight: 96 })

                Divider().height(1).width('100%')

                Column() {
                  TextArea({ text: this.agencyTask.taskDesc, placeholder: $r('app.string.new_agency_desc_tip') })
                    .placeholderFont({ size: 16 })
                    .backgroundColor(Color.White)
                    .padding({ left: 0, right: 0 })
                    .fontSize(16)
                    .fontWeight(FontWeight.Regular)
                    .opacity(0.9)
                    .borderRadius(0)
                    .maxLength(100)
                    .showCounter(true)
                    .onChange((value: string) => {
                      if (this.agencyTask.title !== value) {
                        this.isEdit = true;
                      }
                      this.agencyTask.taskDesc = value;
                    })
                }
                .constraintSize({ maxHeight: 128 })
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .width('100%')
              }
              .width('100%')
              .constraintSize({ maxHeight: 256 })
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Start)
            }.layoutWeight(1)

            Column().width('4%')
          }.backgroundColor(Color.White)

          Row() {
            Column().width('4%')
            Column() {
              /******************截止时间信息******************/
              Row() {
                PlanTimeSetting({
                  onDateChange: (d: DateTimeElement) => {
                    this.planTime = d;
                    this.agencyTask.planTime =
                      FormatUtil.formatDate(this.planTime.getDate(), FormatUtil.DATE_YYYY_MM_DD_24H_mm_ss);
                    if (this.planDatetime !== this.agencyTask.planTime) {
                      this.isEdit = true;
                    }
                    this.planDatetime = this.agencyTask.planTime;
                  }
                })
              }
              .borderRadius(16)
              .height(48)
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .backgroundColor(Color.White)

              Divider().width('100%').height(1)

              /******************子任务信息******************/
              Column() {
                Row() {
                  /*****子待办进度****/
                  Row() {
                    Text($r('app.string.agency_new_subtask'))
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .borderColor(Color.White)
                      .opacity(0.9)
                  }
                  .width('50%')
                  .height(21)
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)


                  Row() {
                    Text($r('app.string.select_add_attach'))
                      .fontColor('#3093FA')
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .onClick(() => {
                        this.addSubTask();
                      })
                  }
                  .layoutWeight(1)
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.End)
                  .height(21)
                }.height(48)
                .width('100%')
                .alignItems(VerticalAlign.Center)

                /*****显示子待办****/
                Scroll(this.scroller) {
                  List() {
                    ForEach(this.subAgencyTasks, (task: TaskItem) => {
                      ListItem() {
                        Row() {
                          Checkbox()
                            .select(task.isFinished)
                            .width(20)
                            .height(20)
                            .borderRadius(4)
                            .backgroundColor($r('app.color.white'))
                            .border({ color: $r('app.color.black_1'), style: BorderStyle.Solid })
                            .selectedColor($r('app.color.sys_default_blue'))
                            .shape(CheckBoxShape.ROUNDED_SQUARE)
                            .onClick(() => {
                              task.isFinished = !task.isFinished;
                              this.saveTask(task);
                            })
                          Text(task.title)
                            .width('100%')
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .onClick(() => {
                              this.gotoAgencyTask(task)
                            })
                            .layoutWeight(1)
                        }.width('100%')
                        .height(48)
                        .alignItems(VerticalAlign.Center)
                        .justifyContent(FlexAlign.Start)
                      }
                    })
                  }.constraintSize({ maxHeight: 150 })
                }.scrollable(ScrollDirection.Vertical)
                .scrollBar(BarState.Auto)
                .scrollBarWidth(1)
              }
              .width('100%')
              .constraintSize({ maxHeight: 200 })
              .justifyContent(FlexAlign.Start)
            }.layoutWeight(1)

            Column().width('4%')
          }.backgroundColor(Color.White)

          Row() {
            Column().width('4%')
            Column() {
              /******************附件信息******************/
              Row() {
                AttachUpload({
                  onImageChange: (images: Array<string>) => {
                    this.agencyTask.imgList = images;
                    this.isEdit = true;
                  }
                })
              }
              .borderRadius(16)
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
            }.width('100%')
            .layoutWeight(1)

            Column().width('4%')
          }.backgroundColor(Color.White)
        }.layoutWeight(1)

        Column() {
          Row() {
            Column().width('4%')

            Column() {
              Button($r('app.string.btn_save'))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .height(40)
                .backgroundColor(Color.Transparent)
                .fontColor(Color.White)
            }
            .height(40)
            .layoutWeight(1)
            .backgroundColor('rgba(48,147,250,1.00)')
            .opacity(this.isEdit ? 1 : 0.4)
            .borderRadius(20)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.editTask();
            })

            Column().width('4%')
          }
        }
        .width('100%')
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 80 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }.width('100%')
      .height('100%')
      .backgroundColor($r('app.color.window_background'))
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ top: 35 })
    .mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
  }
}