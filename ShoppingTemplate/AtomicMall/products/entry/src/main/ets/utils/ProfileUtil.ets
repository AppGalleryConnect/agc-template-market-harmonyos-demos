import { AddressManageUtil} from 'address_management';
import { FeedbackRouteMap } from 'feedback';
import { iData, RouterMap, routerStack } from 'lib_foundation';
import { CustomServiceSheet } from 'lib_widget';
import { NoticeRouterMap } from 'module_notice_center';
import { MainMenuOption, SubMenuOption } from '../commons/Enums';
import { MainMenuItem, SubMenuItem } from '../commons/Types';

export class ProfileUtil {
  public static readonly MAIN_MENU_LIST: MainMenuItem[] = [
    {
      type: MainMenuOption.COUPON,
      icon: $r('app.media.ic_mine_coupon'),
      label: '优惠券',
    },
    {
      type: MainMenuOption.COLLECTION,
      icon: $r('app.media.ic_mine_collection'),
      label: '我的收藏',
    },
    {
      type: MainMenuOption.MESSAGE,
      icon: $r('app.media.ic_mine_message'),
      label: '我的消息',
    },
    {
      type: MainMenuOption.ADDRESS,
      icon: $r('app.media.ic_mine_address'),
      label: '地址管理',
    },
  ];
  public static readonly SUB_MENU_LIST: SubMenuItem[] = [
    {
      type: SubMenuOption.VIEW_HISTORY,
      icon: $r('sys.symbol.arrow_counterclockwise_clock'),
      label: '浏览历史',
    },
    {
      type: SubMenuOption.FEEDBACK,
      icon: $r('sys.symbol.doc_plaintext_and_pencil'),
      label: '意见反馈',
    },
    {
      type: SubMenuOption.CUSTOM_SERVICE,
      icon: $r('sys.symbol.service'),
      label: '联系客服',
    },
    {
      type: SubMenuOption.SETTINGS,
      icon: $r('sys.symbol.gearshape'),
      label: '设置',
    },
  ];

  public static handleMainMenuClick(menu: MainMenuOption) {
    if (!iData.global.isLogin) {
      routerStack.pushPath({ name: RouterMap.USER_LOGIN });
      return;
    }

    switch (menu) {
      case MainMenuOption.COUPON:
        routerStack.pushPath({ name: RouterMap.USER_COUPON_PAGE });
        break;
      case MainMenuOption.COLLECTION:
        routerStack.pushPath({ name: RouterMap.USER_COLLECTION });
        break;
      case MainMenuOption.MESSAGE:
        routerStack.pushPath({ name: NoticeRouterMap.NOTICE_CENTER });
        break;
      case MainMenuOption.ADDRESS:
        AddressManageUtil.goToAddressListPage(routerStack.getActiveStack());
        break;
      default:
        break;
    }
  }

  public static handleSubMenuClick(menu: SubMenuOption) {
    switch (menu) {
      case SubMenuOption.VIEW_HISTORY:
        if (!iData.global.isLogin) {
          routerStack.pushPath({ name: RouterMap.USER_LOGIN });
          return;
        }
        routerStack.pushPath({ name: RouterMap.USER_VIEW_HISTORY });
        break;
      case SubMenuOption.FEEDBACK:
        routerStack.pushPath({ name: FeedbackRouteMap.FeedbackSubmit });
        break;
      case SubMenuOption.CUSTOM_SERVICE:
        CustomServiceSheet.show();
        break;
      case SubMenuOption.SETTINGS:
        routerStack.pushPathByName(RouterMap.SETTING, undefined);
        break;
      default:
        break;
    }
  }

  public static login() {
    routerStack.pushPath({ name: RouterMap.USER_LOGIN });
  }
}
