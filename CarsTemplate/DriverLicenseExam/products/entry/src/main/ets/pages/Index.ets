import { CommonModel} from '@ohos_agcit/driver_license_exam_commonlib';
import { ExamService } from '@ohos_agcit/driver_license_exam_datasource'
import { notificationManager } from '@kit.NotificationKit';
import { PushUtils , PushActionParams } from '@ohos_agcit/driver_license_exam_commonlib'
import { LoneTakeAnimationsTransition } from 'module_transition'
import { IndexVM } from '../viewmodels/IndexVM';

@Entry
@ComponentV2
struct Index {
  vm: CommonModel = CommonModel.instance;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  @Local isEnabled: boolean = true;
  indexVM: IndexVM = new IndexVM();

  aboutToAppear(): void {
    this.vm.navStack.replacePathByName('splashPage', true);
    this.sendPushNotice();
    this.indexVM.registerBreakpointListener(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.indexVM.unregisterBreakpointListener();
  }

  sendPushMessage() {
    let pushArticle:PushActionParams = {
      picVideoUrl: '',
      title: '驾考模板',
      id: '3445749589458989'
    }
    PushUtils.randomPushMessage(pushArticle, this.getUIContext().getHostContext() as Context)
  }

  sendPushNotice() {
    const isOn = notificationManager.isNotificationEnabledSync();
    if (isOn) {
      this.sendPushMessage();
    }
  }

  build() {

      Navigation(this.vm.navStack)
        .hideNavBar(true)
        .enabled(this.isEnabled)
        .hideTitleBar(true)
      .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
        return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
          onTransitionStart: () => {
            this.isEnabled = false;
          },
          onTransitionEnd: () => {
            this.isEnabled = true;
          }
        });
      })


  }
}
