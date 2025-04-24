import {
  AppointmentInfo,
  AppointState,
  CommonConstants,
  UIEmpty,
  getAppointmentList,
  GetUserInfoResp,
  Logger,
  RouterMap,
  RouterModule,
} from 'utils';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common, EnvironmentCallback, Configuration } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { BookCard } from '../components/BookCard';

@Builder
export function appointmentListBuilder() {
  AppointmentList()
}

@ComponentV2
export struct AppointmentList {
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local systemLanguage: string = '';
  @Local isRefreshing: boolean = false;
  @Local appointInfoList: AppointmentInfo[] = [];
  @Local status: AppointState = AppointState.NEW;

  @Monitor('userInfo.mobile')
  onBindStatusChange(monitor: IMonitor) {
    this.getAppointInfoList();
  }

  private context = getContext(this) as common.UIAbilityContext;
  // 注册订阅系统环境变化的ID
  private callbackId: number = 0;

  aboutToAppear(): void {
    Logger.info('AppointmentList aboutToAppear');
    const paramList: AppointState[] = RouterModule.getNavParam({ url: RouterMap.MY_APPOINTMENT_LIST });
    if (paramList.length) {
      this.status = paramList[paramList.length - 1];
    }
    this.subscribeConfigurationUpdate();
    this.getAppointInfoList();
  }

  aboutToDisappear(): void {
    this.unsubscribeConfigurationUpdate();
  }

  getAppointInfoList() {
    const param = this.status === AppointState.NEW ? [AppointState.NEW, AppointState.CANCEL, AppointState.OVER_TIME] :
      [AppointState.FINISH];
    getAppointmentList(param).then((resp) => {
      this.appointInfoList = (resp as AppointmentInfo[]).map(v => {
        if (v.reserveTime <= new Date().getTime()) {
          v.state = AppointState.OVER_TIME;
        }
        return new AppointmentInfo(v);
      });
      Logger.info('getAppointInfoList success');
    }).catch((error: BusinessError) => {
      this.appointInfoList = [];
      Logger.error('getAppointInfoList error:' + JSON.stringify(error));
    }).finally(() => {
      setTimeout(() => {
        this.isRefreshing = false;
      }, 500);
    });
  }

  subscribeConfigurationUpdate(): void {
    // 获取系统当前语言
    this.systemLanguage = this.context.config.language || i18n.System.getFirstPreferredLanguage();

    // 1.获取ApplicationContext
    let applicationContext = this.context.getApplicationContext();

    // 2.通过applicationContext订阅环境变量变化
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated: (newConfig: Configuration) => {
        if (this.systemLanguage !== newConfig.language) {
          this.systemLanguage = newConfig.language || '';
        }
      },
      onMemoryLevel: (level) => {
      },
    }
    try {
      this.callbackId = applicationContext.on('environment', environmentCallback);
    } catch (err) {
      Logger.error('applicationContext.on(environment error: ' + JSON.stringify(err));
    }
  }

  unsubscribeConfigurationUpdate() {
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.off('environment', this.callbackId);
    } catch (err) {
      Logger.error('applicationContext.off(environment error: ' + JSON.stringify(err));
    }
  }

  @Computed
  get isBindPhone() {
    return this.userInfo?.mobile !== '';
  }

  @Computed
  get pageTitle() {
    return this.status === AppointState.NEW ? '已预约' : '已完成';
  }

  build() {
    NavDestination() {
      Column() {
        if (!this.isBindPhone || this.appointInfoList.length === 0) {
          UIEmpty({
            emptyDesc: this.isBindPhone ? $r('app.string.empty_history') : $r('app.string.empty_history_need_login'),
          })
            .margin({ top: 140, bottom: 20 })
        } else {
          Refresh({ refreshing: $$this.isRefreshing }) {
            Scroll() {
              Column({ space: 10 }) {
                ForEach(this.appointInfoList, (v: AppointmentInfo) => {
                  BookCard({
                    appointInfo: v,
                    systemLanguage: this.systemLanguage,
                    updateSchedule: (value) => {
                      v.setSchedule = value;
                    },
                    updateSubscribe: (value) => {
                      v.setSubscription = value;
                    },
                    reQueryList: () => {
                      this.appointInfoList = [];
                      this.getAppointInfoList();
                    },
                  })
                }, (v: AppointmentInfo) => JSON.stringify(v))
              }
            }
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
            .align(Alignment.Top)
            .scrollBar(BarState.Auto)
            .edgeEffect(EdgeEffect.Spring)
            .padding({
              left: 10,
              right: 10,
              top: 10,
              bottom: 20,
            })
          }
          .layoutWeight(1)
          .onRefreshing(() => {
            this.getAppointInfoList();
          })
        }
      }

    }
    .title(this.pageTitle, { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))

  }
}