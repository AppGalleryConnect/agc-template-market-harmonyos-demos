import { DialogMap, RouterModule, StringUtils } from '@ohos_agcit/office_attendance_common_lib';
import { BlankBackground } from '@ohos_agcit/office_attendance_component_lib';
import { RequestProxy } from '../api/RequestProxy';
import { ScheduleInfo } from '../types/Types';
import { promptAction } from '@kit.ArkUI';
import { ScheduleUtils } from '../utils/ScheduleUtils';
import { ScheduleForm } from './components/ScheduleForm';

@Builder
export function editScheduleBuilder() {
  EditSchedule();
}

@ComponentV2
export struct EditSchedule {
  @Provider() schedule: ScheduleInfo = { title: '', startTime: '', endTime: '' };

  aboutToAppear(): void {
    this.init();
  }

  init(): void {
    this.schedule = RouterModule.getNavParam({ url: DialogMap.EDIT_SCHEDULE }).param as ScheduleInfo;
  }

  save() {
    if (StringUtils.isBlank(this.schedule.title)) {
      promptAction.showToast({ message: $r('app.string.schedule_title_empty_tip') })
      this.getUIContext().getFocusController().requestFocus('titleID');
      return;
    }
    ScheduleUtils.updateEvent(this.schedule);

    RequestProxy.saveOne(this.schedule);
    promptAction.showToast({ message: $r('app.string.edit_succ_tip') });
    RouterModule.closeDialog({});
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

  build() {

    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        /********弹框空背景***********/
        BlankBackground()

        ScheduleForm({
          hide: () => {
            this.hide()
          }, save: () => {
            this.save();
          }
        });
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
    .hideTitleBar(true)
  }
}