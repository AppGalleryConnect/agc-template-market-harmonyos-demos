import {
  AccountUtil,
  DialogMap,
  OrderTabsMap,
  RouterMap,
  RouterModule,
  StoreInfo,
  UserInfoModel,
} from 'commonlib';
import { StoreInfoTypeMap, StudyServiceMap } from '../constants/Enums';
import { StoreInfoItem } from '../types/Types';
import { STORE_INFO_LIST } from '../constants/Constants';

@ObservedV2
export class MineVM {
  private static _instance: MineVM;
  // 用户信息
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace storeInfo: StoreInfoItem[] = [];

  @Computed
  public get phoneLabel() {
    const phone = this.userInfo.phone;
    if (phone) {
      return phone.substring(0, 3) + '****' + phone.substring(7);
    }
    return '';
  }

  public static get instance() {
    if (!MineVM._instance) {
      MineVM._instance = new MineVM();
    }
    return MineVM._instance;
  }

  @Computed
  public get isBind() {
    return Boolean(this.userInfo.phone);
  }

  public initStoreInfo(storeInfo: StoreInfo) {
    this.storeInfo = STORE_INFO_LIST.map((item) => {
      let value = '';
      switch (item.type) {
        case StoreInfoTypeMap.LOCATION:
          value = storeInfo.address;
          break;
        case StoreInfoTypeMap.PHONE:
          value = storeInfo.phoneNumber;
          break;
        case StoreInfoTypeMap.BUSINESS_TIME:
          value = storeInfo.businessTime;
          break;
      }
      item.value = value;
      return item;
    });
  }

  public jumpToInfoEditPage() {
    if (this.userInfo.phone) {
      RouterModule.push({
        url: RouterMap.MINE_INFO_EDIT,
      });
    }
  }

  public jumpToOrderList(status: OrderTabsMap = OrderTabsMap.ALL) {
    RouterModule.push({
      url: RouterMap.MINE_ORDER_LIST,
      param: status,
    });
  }

  public jumpToStudyService(type: StudyServiceMap) {
    let url = '';
    switch (type) {
      case StudyServiceMap.COURSES:
        url = RouterMap.MINE_MY_COURSES;
        break;
      case StudyServiceMap.TIMETABLE:
        url = RouterMap.MINE_TIMETABLE;
        break;
      case StudyServiceMap.CHECK_IN:
        url = RouterMap.MINE_MY_CHECK_IN;
        break;
      case StudyServiceMap.ID_CARD:
        url = RouterMap.MINE_STUDENT_ID_CARD;
        break;
      default:
        break;
    }
    RouterModule.push({
      url: url as RouterMap,
    });
  }

  public handleMerchantInfoClick(item: StoreInfoItem) {
    switch (item.type) {
      case StoreInfoTypeMap.PHONE:
        RouterModule.push({
          url:DialogMap.CONTACT_CUSTOM_SERVICE,
          param:item.value,
        });
        break;
      case StoreInfoTypeMap.ABOUT_US:
        RouterModule.push({
          url: RouterMap.MINE_ABOUT_US,
        });
        break;
    }
  }
}