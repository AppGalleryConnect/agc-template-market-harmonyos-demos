import { common, Permissions } from '@kit.AbilityKit';
import { StoreListClass } from '../model/StoreListClass';
import { StoreModel } from '../model/StoreModel';
import { StoreBookingRecordItem } from '../model/StoreBookingRecordItem';
import { STORE_LIST } from '../constants/Constants';
import {
  AccountUtil,
  ActivityBookingRecordModel,
  BookingUtil,
  CalendarUtil,
  DialogMap,
  LocateUtil,
  LocationPermissionUtil,
  Logger,
  RouterModule,
  ServiceItem,
  UserInfoModel,
} from '@ohos_agcit/postpartum_care_center_utils';
import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { sceneMap } from '@kit.MapKit';

const TAG: string = 'testTagMainEntryVM';

@ObservedV2
export class MainEntryVM {
  @Trace navStack: NavPathStack = RouterModule.getStack();
  @Trace curIndex: number = 0;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace storeList: StoreListClass = new StoreListClass();
  @Trace storeListNearby: StoreListClass = new StoreListClass();
  @Trace locationServiceMessage: string | Resource = $r('app.string.obtain_location_permission');
  @Trace storeBookingRecord: StoreBookingRecordItem[] = [];
  @Trace activityBookingList : ActivityBookingRecordModel[] = BookingUtil.getActivityBookingRec();
  @Trace serviceItems: Array<ServiceItem> = [
    new ServiceItem('app.media.ic_store_booking', '门店预约', 'StoreBookingRecordsPage',
      `${this.storeBookingRecord.length}条记录`),
    new ServiceItem('app.media.ic_schedule_conference_lined', '活动预约', 'ActivityBookingListPage', `${this.activityBookingList.length}条记录`),
    new ServiceItem('app.media.feedback', '意见反馈', 'FeedbackPage', ''),
    new ServiceItem('app.media.ic_about', '关于我们', 'PrivacyListPage', '隐私条款'),
  ];
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  public getActivityBookingNumbers(): number {
    if (BookingUtil.getActivityBookingRec() === null || BookingUtil.getActivityBookingRec() === undefined) {
      return 0;
    }
    return BookingUtil.getActivityBookingRec()!.length;
  }

  public getActivityBookingRec() : ActivityBookingRecordModel[]{
    return BookingUtil.getActivityBookingRec();
  }

  // 获取位置授权
  public requestLocationPermission() {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
    LocationPermissionUtil.hasAllPermissions(permissions, () => {
      Logger.debug(TAG, 'already has all permissions');
      LocationPermissionUtil.requestGlobalLocationSwitch(() => {
        this.refreshStoreDistance();
      });
    }, () => {
      LocationPermissionUtil.requestLocationPermissions(permissions, () => {
        LocationPermissionUtil.requestGlobalLocationSwitch(() => {
          this.refreshStoreDistance();
        });
        Logger.debug(TAG, 'request location permission finished');
      });
    });
  }

  // 获取日历授权
  public requestCalendarPermission(event: calendarManager.Event, callback: Callback<void>) {
    const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
    CalendarUtil.hasAllPermissions(permissions, () => {
      Logger.debug(TAG, 'already has all permissions');
      CalendarUtil.addCalendarEvent(event, (err: BusinessError): void => {
        if (!err) {
          promptAction.showToast({ message: '您的出行安排已更新至系统日历中', alignment: Alignment.Center });
          callback();
        }
      });
    }, () => {
      CalendarUtil.requestCalendarPermissions(permissions, () => {
        CalendarUtil.addCalendarEvent(event, (err: BusinessError): void => {
          if (!err) {
            promptAction.showToast({ message: '您的出行安排已更新至系统日历中', alignment: Alignment.Center });
            callback();
          }
        });
        Logger.debug(TAG, 'request calendar permission finished');
      });
    });
  }

  // 绑定手机号
  public requestPhoneNumber() {
    RouterModule.openDialog(DialogMap.BIND_PHONE_DIALOG);
  }

  // 刷新门店距离
  public refreshStoreDistance() {
    let storeListNearby: StoreModel[] = STORE_LIST;

    let storeList: StoreModel[] = STORE_LIST;

    LocateUtil.getLocationPosition(() => {
      Logger.info(TAG,
        `getLocationPosition result, latitude: ${LocateUtil.userLatitude}, longitude: ${LocateUtil.userLongitude}`);
      storeList.forEach((store: StoreModel) => {
        store.getStoreDistance();
      });
      this.storeList.storeList = storeList;
      Logger.debug(TAG, 'getLocation and distance finished');
    });

    LocateUtil.getLocationPosition(() => {
      Logger.info(TAG,
        `getLocationPosition result, latitude: ${LocateUtil.userLatitude}, longitude: ${LocateUtil.userLongitude}`);
      storeListNearby.forEach((store: StoreModel) => {
        store.getStoreDistance();
      });
      this.storeListNearby.storeList = storeListNearby;
      Logger.debug(TAG, 'getLocation and distance finished');
    });

    this.storeListNearby.needSortStore = true;
    this.storeList.needSortStore = true;
  }

  public queryLocation(store: StoreModel) {
    try {
      let option: sceneMap.LocationQueryOptions = {
        name: store.name,
        location: { latitude: store.storeLatitude, longitude: store.storeLongitude },
        address: store.address,
        language: 'zh',
        showBusiness: true,
      };
      sceneMap.queryLocation(getContext() as common.UIAbilityContext, option).then(() => {
        console.info(TAG, 'queryLocation success:');
      }).catch((err: BusinessError) => {
        console.error(TAG, 'queryLocation fail err=' + JSON.stringify(err));
      });
    } catch (err) {
      console.error(TAG, 'queryLocation fail err=' + JSON.stringify(err));
    }
  }
}
