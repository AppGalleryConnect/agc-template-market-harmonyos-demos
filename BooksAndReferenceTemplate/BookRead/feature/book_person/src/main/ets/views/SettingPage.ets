import { BookApi, Constants, GetUserInfoRsp, NavHeaderBar, TCRouter, UserInfo } from 'common';
import { AvatarIcon, SelectAvatarCard } from '../comp/SelectAvatarCard';
import { emitter } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct SettingPage {
  @Local userInfo: UserInfo | undefined = undefined;
  @Local avatarIcon: AvatarIcon = new AvatarIcon('');
  @Local modifyContent: string = '';
  @Local nickName: string = '';
  @Local telephone: string = '';
  @Local isShowModifyBind: boolean = false;
  @Local isSelectCalendar: boolean = false;
  @Local isModifyNickName: boolean = false;
  @Local isModifyTelephone: boolean = false;

  async aboutToAppear(): Promise<void> {
    const rsp: GetUserInfoRsp = await BookApi.getUserInfo('123');
    this.userInfo = rsp.user;
    this.avatarIcon = new AvatarIcon(this.userInfo?.avatarUrl, 40, 40);

    this.telephone = this.userInfo.telephone as string;
    this.nickName = this.userInfo.nickName;
    emitter.on(Constants.LOGIN_CHANGE,()=>{
      this.avatarIcon.avatarUrl = AppStorage.get<UserInfo>('userInfo')?.avatarUrl as string
    })
  }
  submitModifyMsg(){
    if (this.userInfo) {
      if (this.isModifyNickName) {
        this.userInfo.nickName = this.modifyContent;
        this.nickName = this.modifyContent;
        this.isModifyNickName = false;
      } else if (this.isModifyTelephone) {
        this.userInfo.telephone = this.modifyContent;
        this.telephone = this.modifyContent;
        this.isModifyTelephone = false;
      }
    }
    emitter.emit(Constants.LOGIN_CHANGE);
    AppStorage.set('userInfo', this.userInfo);
    this.isShowModifyBind = false;
    promptAction.showToast({ message: $r('app.string.modify_success') })
  }
  @Styles
  settingCard() {
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 24,
      bottom: 24,
    })
  }

  @Builder
  avatarCard() {
    Row() {
      Text($r('app.string.avatar'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .height(20)
      Row() {
        SelectAvatarCard({ avatarIcon: this.avatarIcon })
      }
    }
    .height(64)
    .justifyContent(FlexAlign.SpaceBetween)
    .settingCard()
  }

  @Builder
  nickNameCard() {
    Row() {
      Text($r('app.string.nick_name'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .height(20)

      Row() {
        Text(this.nickName)
          .height(20)
        Image($r('app.media.ic_arrow_right'))
          .width(20)
          .height(20)
      }
    }
    .onClick(() => {
      this.isShowModifyBind = true;
      this.isModifyNickName = true;
    })
    .height(64)
    .justifyContent(FlexAlign.SpaceBetween)
    .settingCard()
  }

  @Builder
  brithDayCard() {
    Row() {
      Text($r('app.string.birthday'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .height(20)
      Row() {
        Text(this.userInfo?.birthday)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .height(20)
      }
    }
    .height(64)
    .justifyContent(FlexAlign.SpaceBetween)
    .settingCard()
  }

  @Builder
  nickAndBirthDayCard() {
    Column() {
      this.nickNameCard();
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
  }

  @Builder
  phoneCard() {
    Row() {
      Text($r('app.string.telephone'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .height(20)
      Row() {
        Text(this.telephone)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .height(20)
        Image($r('app.media.ic_arrow_right'))
          .width(20)
          .height(20)
      }
    }
    .onClick(() => {
      this.isShowModifyBind = true;
      this.isModifyTelephone = true;
    })
    .height(64)
    .justifyContent(FlexAlign.SpaceBetween)
    .settingCard()
  }

  @Builder
  loginOut() {
    Row() {
      Text($r('app.string.loginOut'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .height(20)
      Image($r('app.media.ic_arrow_right'))
        .width(20)
        .height(20)
    }
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        promptAction.showToast({ message: $r('app.string.no_login_out') })
      } else {
        promptAction.showDialog({
          title: $r('app.string.ask_for_login_out'),
          message: $r('app.string.ask_for_login_out_again'),
          buttons: [
            {
              text: $r('app.string.cancel'),
              color: $r('app.color.button_color')
            },
            {
              text: $r('app.string.agreement_and_login_out'),
              color: $r('app.color.button_color')
            }
          ]
        }, (err, data) => {
          if (data.index === 1) {
            this.userInfo?.isLogin
            AppStorage.setOrCreate('userInfo', undefined);
            emitter.emit(Constants.LOGIN_CHANGE);
            TCRouter.pop();
          }
        })
      }
    })
    .height(64)
    .justifyContent(FlexAlign.SpaceBetween)
    .settingCard()
  }

  getModifyContent(): string {
    if (this.isModifyNickName) {
      return this.nickName;
    } else if (this.isModifyTelephone) {
      return this.telephone;
    }

    return '';
  }

  @Builder
  modify() {
    Column() {
      TextInput({ text: this.getModifyContent() })
        .enableKeyboardOnFocus(true)
        .onChange((value: string) => {
          this.modifyContent = value;
        })
        .onSubmit(() => {
          this.submitModifyMsg()
        })
      Button('确定')
        .width(304)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.multi_color_08'))
        .onClick(()=>{
          this.submitModifyMsg()
        })
    }
    .height('90%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 12, right: 12 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: $r('app.string.person_setting'),
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: true,
          })
          Scroll() {
            Column({ space: 10 }) {
              this.avatarCard();
              this.nickAndBirthDayCard();
              this.phoneCard();
              this.loginOut();
            }
          }.layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .padding({
            left: 12,
            right: 12,
            top: 20
          })
        }
        .bindSheet($$this.isShowModifyBind, this.modify(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 800],
          height: SheetSize.FIT_CONTENT,
          preferType: SheetType.BOTTOM,
          title: { title: this.isModifyNickName ? $r('app.string.modify_nickname') : $r('app.string.modify_telephone')  },
          onWillDismiss: ()=>{
            this.isShowModifyBind = false;
            this.isModifyNickName = false;
            this.isModifyTelephone = false;
          }
        })
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}