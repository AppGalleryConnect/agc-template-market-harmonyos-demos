import { emitter } from '@kit.BasicServicesKit';
import { UserInfo } from 'base_common';
import {
  BookApi,
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  FontModel,
  GetUserInfoRsp,
  NavHeaderBar,
  ReturnButton,
  TCRouter
} from 'common';
import { AvatarIcon, SelectAvatarCard } from '../comp/SelectAvatarCard';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct AccountPage {
  @Local userInfo: UserInfo | undefined = undefined;
  @Local avatarIcon: AvatarIcon = new AvatarIcon('');
  @Local modifyContent: string = '';
  @Local nickName: string = '';
  @Local telephone: string = '';
  @Local isShowModifyBind: boolean = false;
  @Local isSelectCalendar: boolean = false;
  @Local isModifyNickName: boolean = false;
  @Local isModifyTelephone: boolean = false;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  async aboutToAppear(): Promise<void> {
    this.userInfo = AppStorage.get('userInfo') as UserInfo;
    this.avatarIcon = new AvatarIcon(this.userInfo?.avatarUrl, 40, 40);
    this.telephone = this.userInfo.telephone as string;
    this.nickName = this.userInfo.nickName;
    try {
      emitter.on(Constants.LOGIN_CHANGE, () => {
        this.avatarIcon.avatarUrl = AppStorage.get<UserInfo>('userInfo')?.avatarUrl as string
      })
    } catch (e) {
      console.error('Failed to emitter on login change. Cause: ' + JSON.stringify(e));
    }
  }

  submitModifyMsg() {
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
    try {
      emitter.emit(Constants.LOGIN_CHANGE);
    } catch (e) {
      console.error('Failed to emitter emit login change. Cause: ' + JSON.stringify(e));
    }
    AppStorage.set('userInfo', this.userInfo);
    this.isShowModifyBind = false;
    const uiContext = this.getUIContext?.();
    if (uiContext) {
      const promptAction = uiContext.getPromptAction();
      promptAction.showToast({ message: $r('app.string.modify_success') });
    }
  }

  @Styles
  settingCard() {
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 24,
      bottom: 24,
    })
  }

  @Builder
  avatarCard() {
    Row() {
      Text($r('app.string.avatar'))
        .fontSize(this.fontModel.getFg(16))
        .fontColor($r('sys.color.font_primary'))
        .height(20)
      Row({ space: 4 }) {
        if (this.userInfo?.isLogin) {
          SelectAvatarCard({ avatarIcon: this.avatarIcon, isLogin: this.userInfo?.isLogin })
        } else {
          Image($r('app.media.ic_default_hd'))
            .width(40)
            .height(40)
            .borderRadius(50)
            .onClick(() => {
              const promptAction = this.getUIContext().getPromptAction();
              promptAction.showToast({ message: $r('app.string.no_login_out') })
            })
        }
        Image($r('app.media.ic_arrow_right'))
          .width(7)
          .height(14)
          .objectFit(ImageFit.Contain)
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
        .fontSize(this.fontModel.getFg(16))
        .fontColor($r('sys.color.font_primary'))
        .height(20)

      Row({ space: 4 }) {
        Text(this.nickName)
          .height(20)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .constraintSize({
            maxWidth: '50%'
          })
        Image($r('app.media.ic_modify_name'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      }
    }
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        const promptAction = this.getUIContext().getPromptAction();
        promptAction.showToast({ message: $r('app.string.no_login_out') })
      } else {
        this.isShowModifyBind = true;
        this.isModifyNickName = true;
      }
    })
    .height(58)
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  nickNameAndPhoneCard() {
    Column() {
      this.nickNameCard()
      Divider()
      this.phoneCard()
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  phoneCard() {
    Row() {
      Text($r('app.string.telephone'))
        .fontSize(this.fontModel.getFg(16))
        .fontColor($r('sys.color.font_primary'))
        .height(20)
      Row({ space: 4 }) {
        Text(this.telephone)
          .fontSize(this.fontModel.getFg(16))
          .fontColor($r('sys.color.font_secondary'))
          .height(20)
        Image($r('app.media.ic_arrow_right'))
          .width(7)
          .height(14)
          .objectFit(ImageFit.Contain)
      }
    }
    .onClick(() => {
      if (!this.userInfo?.isLogin) {
        const promptAction = this.getUIContext().getPromptAction();
        promptAction.showToast({ message: $r('app.string.no_login_out') })
      } else {
        this.isShowModifyBind = true;
        this.isModifyTelephone = true;
      }
    })
    .height(58)
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  loginOut() {
    Row() {
      Text($r('app.string.loginOut'))
        .fontSize(this.fontModel.getFg(16))
        .fontColor($r('sys.color.font_primary'))
        .height(20)
      Image($r('app.media.ic_arrow_right'))
        .width(7)
        .height(14)
        .objectFit(ImageFit.Contain)
    }
    .onClick(() => {
      const promptAction = this.getUIContext().getPromptAction();

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
            try {
              // 保留会员状态和书币信息，只清除登录状态
              const savedMembershipStatus = this.userInfo?.isMembership || false;
              const savedBookCoins = typeof this.userInfo?.bookCoins === 'number' ? this.userInfo.bookCoins : 100;

              // 保存会员状态和书币信息到本地存储
              AppStorage.setOrCreate('membershipStatus', savedMembershipStatus);
              AppStorage.setOrCreate('bookCoins', savedBookCoins);

              // 清除用户信息
              AppStorage.setOrCreate('userInfo', undefined);
              emitter.emit(Constants.LOGIN_CHANGE);
              TCRouter.pop();
            } catch (e) {
              console.error('Failed to emitter emit login change. Cause: ' + JSON.stringify(e));
            }
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
        .onClick(() => {
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
            title: '个人信息',
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: false,
          })
          Scroll() {
            Column({ space: 10 }) {
              this.avatarCard();
              this.nickNameAndPhoneCard()
            }
            .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : '100%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .padding({
            left: 12,
            right: 12,
            top: 20
          })
          .edgeEffect(EdgeEffect.Spring)
        }
        .bindSheet($$this.isShowModifyBind, this.modify(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 800],
          height: SheetSize.FIT_CONTENT,
          preferType: SheetType.BOTTOM,
          title: {
            title: this.isModifyNickName ? $r('app.string.modify_nickname') : $r('app.string.modify_telephone')
          },
          onWillDismiss: () => {
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