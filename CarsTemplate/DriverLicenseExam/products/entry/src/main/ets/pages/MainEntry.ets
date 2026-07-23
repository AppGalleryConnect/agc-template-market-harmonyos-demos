import { TAB_LIST } from '../constants/Constants';
import { HomeView } from './home/HomeView';
import { MineView } from './mine/MineView';
import { TabListItem } from '../types/Types';
import { CommonModel, CommonConstants, PreferencesUtil, Logger } from '@ohos_agcit/driver_license_exam_commonlib';
import { GuideService } from '@ohos_agcit/driver_license_exam_guide';
import { ExamService } from '@ohos_agcit/driver_license_exam_datasource'
import { notificationManager } from '@kit.NotificationKit';
import { PushUtils , PushActionParams } from '@ohos_agcit/driver_license_exam_commonlib'
import { formBindingData, formProvider} from '@kit.FormKit';
import { MainEntryVM } from '../viewmodels/MainEntryVM';

interface GeneratedObjectLiteralInterface_1 {
  index: number;
  didCount: number;
  totalCount: number;
}

@Builder
export function MainEntryBuilder() {
  MainEntry();
}

@ComponentV2
export struct MainEntry {
  vm: CommonModel = CommonModel.instance;
  mainEntryVm: MainEntryVM = new MainEntryVM();
  bottomRectHeight: number = 0;
  guideService: GuideService = GuideService.instance;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  @Local totalCount:number = 0;
  @Local didCount: number = 0;
  @Local accuracyRate: number = 0;
  @Local averageScore: number = 0;
  @Local projectIndex: number  = 0;
  @Local isEnabled: boolean = true;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.updateForm(0);
  }


  updateForm(index:number) {
    const newData: GeneratedObjectLiteralInterface_1 = {
      index: index,
      didCount: this.didCount,
      totalCount: this.totalCount
    };

    const preferencesUtil = PreferencesUtil.getInstance();
    const preference = preferencesUtil.getPreferences(this.getUIContext().getHostContext() as Context)
    const formIds  = preferencesUtil.getFormIds(preference);
    preferencesUtil.preferencesPut(preference, 'tabIndex', index);
    preferencesUtil.preferencesPut(preference, 'didCount', this.didCount)
    preferencesUtil.preferencesPut(preference, 'totalCount', this.totalCount)

    // 3. 封装并更新卡片
    const formInfo = formBindingData.createFormBindingData(newData);

    formIds.forEach((id:string) => {
      formProvider.updateForm(id, formInfo)
        .then(() => Logger.info('MainEntry', '更新成功'))
        .catch((err: ESObject) => Logger.error('MainEntry', '更新失败: %{public}s', JSON.stringify(err) ?? ''));
    })
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
    Stack({ alignContent: Alignment.TopStart }) {
      NavDestination() {
        Column() {
          Tabs({ index: this.vm.curIndex }) {
            TabContent() {
              HomeView({
                didCount: this.didCount,
                totalCount: this.totalCount,
                tabChange:(index:number) => {
                  this.updateForm(index);
                  this.projectIndex = index;
                }
              });
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

            TabContent() {
              MineView({
                didCount: this.didCount,
                accuracyRate: this.accuracyRate,
                averageScore: this.averageScore
              });
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));
          }
          .scrollable(false)
          .height(CommonConstants.FULL_HEIGHT)
          .barWidth(this.mainEntryVm.tabWidth)
          .barHeight(this.mainEntryVm.tabHeight)
          .vertical(this.mainEntryVm.tabModel.isTabVertical)
          .divider(this.mainEntryVm.showDivider)
          .barOverlap(!this.mainEntryVm.tabModel.isTabVertical)
          .barPosition(this.mainEntryVm.barPosition)
          .animationDuration(0)
          .barMode(BarMode.Fixed)
          .onChange((index: number) => {
            this.vm.curIndex = index;
          });
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .padding({
          bottom: this.getUIContext().px2vp(this.bottomRectHeight)
        })
      }
      .hideTitleBar(true)
      .hideToolBar(true)
      .hideBackButton(true)
      .enabled(this.isEnabled)
      .onShown(() => {
        this.totalCount = this.examService.getTotalCount();
        this.didCount = this.examService.getDidCount();
        this.accuracyRate = this.examService.calAccuracyRate();
        this.averageScore = this.examService.calculateAverageScore();
        this.updateForm(this.projectIndex)
      })
    };

  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.icon_color_highlight') :
          $r('sys.color.font_secondary'))
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_xs') });

    }.width(CommonConstants.FULL_WIDTH);
  }
}
