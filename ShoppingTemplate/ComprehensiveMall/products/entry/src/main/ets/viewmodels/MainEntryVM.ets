import { common } from '@kit.AbilityKit';
import { iData, routerStack, WindowUtil } from 'lib_foundation';
import { ShoppingCartApis } from 'lib_network';
import { MemberStatusUtil } from 'membership';
import { SetupUtil } from '../utils/SetupUtil';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = routerStack.getActiveStack();
  // 当前页签
  @Trace curIndex: number = 0;
  @Trace firstBackTime: number = 0;

  public initData() {
    if (iData.global.isLogin) {
      ShoppingCartApis.getCartData().then((res) => {
        if(res.code === 0){
          iData.global.cartVersion = res.data.version;
          iData.global.cartTotal = res.data.total;
        }
      });
      MemberStatusUtil.queryPurchase(WindowUtil.globalContext as common.UIAbilityContext).then((list) => {
        if (list.nonRenewList.length) {
          iData.global.userInfo.isMember = true;
        }
      });
    }
    SetupUtil.jumpToTarget();
  }
}
