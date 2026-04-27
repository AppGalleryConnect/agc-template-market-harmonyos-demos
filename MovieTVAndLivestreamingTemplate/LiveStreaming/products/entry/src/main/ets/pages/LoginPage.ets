import { Channel, LoginService, LoginType } from '@agctemplate/module_login';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { AccountUtil } from '@agctemplate/widgets';
import { UserInfo } from 'live_interaction'

@ComponentV2
export struct LoginPage {
  @Local nextRouter: string = '';
  @Local popResult: boolean = false;

  aboutToAppear(): void {
    this.getRouterParams();

  }

  getRouterParams() {
    let temp = RouterModule.getNavParam({ url: RouterMap.LOGIN_PAGE });
    if (temp) {
      this.popResult = temp as boolean;
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        LoginService({
          icon: $r('app.media.app_icon'),
          privacyPolicyEvent: () => {
            RouterModule.push({ url: RouterMap.PRIVACY_PAGE });
          },
          loginBtnBgColor: $r('sys.color.alert'),
          termOfServiceEvent: () => {
            RouterModule.push({ url: RouterMap.TERMS_SERVICE_PAGE });
          },
          loginTypes: [new Channel(LoginType.WECHAT, '微信登录', {
            appId: 'wxd5a474c635b8fd17',
            scope: 'snsapi_userinfo,snsapi_friend,snsapi_message,snsapi_contact',
            transaction: 'test123',
            state: 'none',
          }, $r('app.media.wechat'))],
          loginFinishedCb: (flag: boolean, unionID?: string) => {
            // 模板忽略登录失败场景
            this.loginSuccess(unionID || '0');
          },
        });
      }
      .backgroundColor($r('sys.color.background_secondary')).height('100%').scrollBar(BarState.Off)
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(()=>{
      this.onBack()
      return true;
    })
  }

  loginSuccess(unionID: string) {
    // 模拟登录
    let data: UserInfo = {
      id: 0,
      avatar: $r('app.media.path'),
      name: '华为用户',
      nickname: '华为用户',
      sex: '女',
      cellphone: '130****0000',
      birthday: '',
      code: unionID,
      isLogin: true,
      bio: '',
      followingList: [],
      followersList: [],
      likesCount: 0,
      realNameAuthFlag:false
    };
    AccountUtil.updateUserInfo(data);
    this.onBack()
  }
  onBack(){
    if (this.popResult) {
      RouterModule.pop('')
    } else {
      RouterModule.pop();
    }
  }
}

@Builder
export function LoginPageBuilder() {
  LoginPage()
}