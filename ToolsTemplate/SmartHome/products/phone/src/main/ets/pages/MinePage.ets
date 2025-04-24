import { Constants, StorageUtil } from 'utils';
import { PersonalProfileView } from 'device_service';
import { NavBarInfo, NavBarListView } from 'uicomponents';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct MinePage {
  @Param pathStack: NavPathStack = new NavPathStack();
  @Local isLogin:boolean = StorageUtil.exists('isLogin')
  navBarList: NavBarInfo[] = [
    {
      image: $r('app.media.config'),
      text: '权限管理',
      pageName: 'AccessControlPage',
    },
    {
      image: $r('app.media.advice'),
      text: '意见反馈',
      pageName: 'AdviceFeedbackPage',
    },
    {
      image: $r('app.media.help_center'),
      text: '帮助中心',
      pageName: 'HelpCenterPage',
    },
    {
      image: $r('app.media.about_us'),
      text: '关于我们',
      pageName: 'AboutUsPage',
    },
  ];

  @Builder
  BuildTitle() {
    Text('我的')
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
      .margin({ top: Constants.PAGE_MARGIN_TOP });
  }

  aboutToAppear(): void {
   emitter.on('loginUpdate',()=>{
     this.isLogin = StorageUtil.exists('isLogin')
   })
  }

  build() {
    Navigation(this.pathStack) {
      Scroll(){
        Column() {
          this.BuildTitle();
          PersonalProfileView({ pathStack: this.pathStack , isLogin: this.isLogin}).margin({ top: 24 });
          NavBarListView({ pathStack: this.pathStack, navBarList: this.navBarList });
        }
      }.scrollBar(BarState.Off)
    }
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR)
    .hideTitleBar(true);
  }
}