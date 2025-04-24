import { promptAction } from '@kit.ArkUI';
import { DialogMap, FormatUtil, RouterModule, StringUtils } from '@ohos_agcit/office_attendance_common_lib';
import { BlankBackground, DateTimeElement, TitleBar } from '@ohos_agcit/office_attendance_component_lib';
import { AttachUpload } from './components/AttachUpload';
import { PlanTimeSetting } from './components/PlanTimeSetting';
import { TaskItem } from '../types/Types';
import { RequestProxy } from '../api/RequestProxy';

@Builder
export function addAgencyTaskBuilder() {
  AddAgencyTask();
}

@ComponentV2
export struct AddAgencyTask {
  @Provider() fullPathImages: Array<string> = [];
  @Local parentID: string = '';
  @Local title: string = '';
  @Local desc: string = '';
  @Provider() planTime: DateTimeElement | undefined;
  @Provider() planDatetime: string = '';

  save() {
    if (StringUtils.isBlank(this.title)) {
      promptAction.showToast({ message: $r('app.string.agency_title_empty_tip') })
      this.getUIContext().getFocusController().requestFocus('titleID');
      return;
    }
    let planTime: string | undefined;
    if (this.planTime) {
      planTime = FormatUtil.formatDate(this.planTime.getDate(), FormatUtil.DATE_YYYY_MM_DD_24H_mm_ss);
    }
    let taskItem: TaskItem = {
      parentID: this.parentID,
      title: this.title,
      taskDesc: this.desc,
      isFinished: false,
      planTime: planTime,
      imgList: this.fullPathImages
    };
    RequestProxy.addTask(taskItem).then(()=>{
      promptAction.showToast({ message: $r('app.string.new_success') })
    })
    RouterModule.closeDialog({});
  }

  init() {
    this.parentID = RouterModule.getNavParam({ url: DialogMap.NEW_AGENCY_TASK }).param;
  }

  aboutToAppear(): void {
    this.init();
  }

  hide() {
    animateTo({
      duration: 300,
      curve: Curve.Friction,
      onFinish: () => {
        RouterModule.closeDialog();
      },
    }, () => {
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {

        /********弹框空背景***********/
        BlankBackground()

        Row() {
          Column().width('4%')

          Column() {
            Column() {
              Column()
                .width('48')
                .height(4)
                .backgroundColor('#000000')
                .opacity(0.2)
                .borderRadius(2)
            }.alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height(16)

            TitleBar({
              titleResID: 'app.string.new_agency_task',
              hide: () => {
                this.hide()
              },
              callback: () => {
                this.save()
              }
            });

            Column().width('100%').height('3%')

            Column() {
              Column() {
                Row() {
                  Column().width('3%')
                  Column() {
                    TextArea({ placeholder: $r('app.string.new_agency_title_tip'), text: $$this.title })
                      .placeholderFont({ size: 16, weight: FontWeight.Medium })
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .opacity(0.9)
                      .padding({ left: 0, right: 0 })
                      .backgroundColor(Color.White)
                      .borderRadius(0)
                      .maxLength(50)
                      .showCounter(true)
                      .constraintSize({ minHeight: 36, maxHeight: 96 })
                      .id('titleID')
                  }.layoutWeight(1)
                  .justifyContent(FlexAlign.Center)

                  Column().width('3%')
                }.width('100%')

                Divider().width('100%').height(1)

                Row() {
                  Column().width('3%')
                  Column() {
                    TextArea({ placeholder: $r('app.string.new_agency_desc_tip'), text: $$this.desc })
                      .placeholderFont({ size: 16, weight: FontWeight.Regular })
                      .fontSize(16)
                      .fontWeight(FontWeight.Regular)
                      .opacity(0.9)
                      .backgroundColor(Color.White)
                      .padding({ left: 0, right: 0 })
                      .borderRadius(0)
                      .maxLength(100)
                      .showCounter(true)
                      .constraintSize({ minHeight: 64, maxHeight: 128 })
                  }.layoutWeight(1)

                  Column().width('3%')
                }.width('100%')
              }.backgroundColor(Color.White)
              .borderRadius(16)

              Column().width('100%').height('2%')

              /***********时间设置*************/
              Row() {
                Column().width('3%');

                PlanTimeSetting({
                  onDateChange: (planTime: DateTimeElement) => {
                    this.planTime = planTime;
                  }
                }).layoutWeight(1)
                  .borderRadius(16)

                Column().width('3%');
              }.backgroundColor(Color.White)
              .borderColor(16)

              Column().width('100%').height('2%')
              /*********附件上传***********/
              Row() {
                Column().width('3%')

                AttachUpload({
                  onImageChange: (fullPathImages: Array<string>) => {
                    this.fullPathImages = fullPathImages;
                  }
                }).layoutWeight(1)
                  .borderRadius(16)

                Column().width('3%');
              }.backgroundColor(Color.White)
              .borderColor(16)

            }.height('100%')
          }.layoutWeight(1)

          Column().width('4%')
        }.height('75%')
        .borderRadius({ topLeft: 32, topRight: 32 })
        .backgroundColor('#FAFAFA')
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}