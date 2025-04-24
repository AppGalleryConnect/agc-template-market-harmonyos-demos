import { ImageSettingBarView, TextSettingBarView, TextShowBarView } from 'uicomponents';
import { Constants } from 'utils';
import { PersonalCenterViewModel } from '../viewmodel/PersonalCenterViewModel';
import { AppStorageV2, CustomContentDialog } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function PersonalCenterPageBuilder(name: string, param: Object) {
  PersonalCenterPage();
}

@ComponentV2
export struct PersonalCenterPage {
  pathStack: NavPathStack = new NavPathStack();
  personalCenterViewModel: PersonalCenterViewModel = new PersonalCenterViewModel();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '确定退出？',
      contentBuilder: () => {
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.dialogController.close()
          },
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            AppStorageV2.remove('isLogin')
            emitter.emit('loginUpdate')
            this.pathStack.pop()
          },
        },
      ],
    }),
    backgroundColor: Color.White,
  });

  @Builder
  BuildAccountSetting() {
    TextShowBarView({
      startImage: $r('app.media.account'),
      name: '账号',
      value: this.personalCenterViewModel.phone
    });
  }

  @Builder
  BuildNickNameSetting() {
    TextSettingBarView({
      startImage: $r('app.media.nickname'),
      name: '昵称',
      value: this.personalCenterViewModel.nickName,
      valueChangeCb: (value: string) => {
        this.personalCenterViewModel.setNickName(value);
      },
    });
  }

  @Builder
  BuildAvatarSetting() {
    ImageSettingBarView({
      startImage: $r('app.media.picture'),
      name: '头像',
      value: this.personalCenterViewModel.avatar,
      valueChangeCb: (value: ResourceStr) => {
        this.personalCenterViewModel.setAvatar(value);
      },
    });
  }

  @Builder
  BuilderLogoutBar(){
    Row() {
      Image($r('app.media.ic_public_person'))
        .size({ width: 18, height: 18 })
        .margin({ left: 20 });
      Text('退出登录')
      .margin({ left: 5 });
      Blank();
      Image($r('app.media.ic_public_exit'))
        .size({ width: 16, height: 16 })
        .opacity(0.6)
        .margin({ right: 15 });
    }
    .width('90%')
    .height(50)
    .borderRadius(12)
    .backgroundColor(Constants.COMMON_BAR_BACKGROUND_COLOR)
    .margin({ top: 20 })
    .onClick(()=>{
      this.dialogController.open()
    })
  }

  @Builder
  BuildSetting() {
    List() {
      ListItem() {
        this.BuildAccountSetting();
      }.margin({ left: 10, right: 10 }).height(50);

      ListItem() {
        this.BuildNickNameSetting();
      }.margin({ left: 10, right: 10 }).height(50);

      ListItem() {
        this.BuildAvatarSetting();
      }.margin({ left: 10, right: 10 }).height(50);
    }
    .alignListItem(ListItemAlign.Center)
    .divider({
      strokeWidth: 1,
      color: '#F1F3F5',
      startMargin: 10,
      endMargin: 10,
    })
    .width('90%')
    .borderRadius(16)
    .backgroundColor(Constants.COMMON_BAR_BACKGROUND_COLOR)
    .margin({ top: 10 });

    this.BuilderLogoutBar()
  }

  build() {
    NavDestination() {
      Column() {
        this.BuildSetting();
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('个人中心')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR);
  }
}