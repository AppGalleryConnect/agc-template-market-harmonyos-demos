import { ComponentConst, NavigateBar, SimpleCapsuleButton } from 'componentlib';
import { MinePageVM } from '../viewmodel/MinePageVM';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UserInfoModel } from 'commonlib';
import { PersistenceV2, promptAction } from '@kit.ArkUI';

let disconnectDialogId: number = 0;

@Builder
function disconnectDialogBuilder(confirm: () => void, cancel?: () => void) {
  Column() {
    Text($r('app.string.disconnect_dialog_title'))
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Bold)
    Text($r('app.string.disconnect_tips'))
      .fontSize($r('sys.float.Body_M'))
      .margin({ top: ComponentConst.CARD_PADDING_VERTICAL })
    Row({ space: 16 }) {
      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.dialog_cancel'))
          .fontSize($r('app.string.font_size_16'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
      }
      .backgroundColor(Color.White)
      .onClick(() => {
        cancel?.();
        promptAction.closeCustomDialog(disconnectDialogId);
      })
      .layoutWeight(1)

      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.confirm_disconnect'))
          .fontSize($r('app.string.font_size_16'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
      }
      .backgroundColor(Color.White)
      .onClick(() => {
        confirm();
        promptAction.closeCustomDialog(disconnectDialogId);
      })
      .layoutWeight(1)
    }
    .margin({ top: $r('app.string.margin_xs') })
  }
  .width(ComponentConst.FULL_PARENT)
  .padding({
    top: ComponentConst.CARD_PADDING_VERTICAL,
    bottom: ComponentConst.CARD_PADDING_VERTICAL,
    left: ComponentConst.CARD_PADDING_HORIZON * 2,
    right: ComponentConst.CARD_PADDING_HORIZON * 2,
  })
}

let modifyDialogId: number = 0;
let modifyValue: string = '';

@Builder
function modifyDialogBuilder(confirm: (value: string) => void, cancel?: () => void) {
  Column() {
    Text($r('app.string.modify_nick_name_dialog_title'))
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Bold)
    TextInput()
      .onChange((value) => {
        modifyValue = value;
      })
      .margin({ top: $r('app.string.margin_xm') })
    Row({ space: 16 }) {
      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.dialog_cancel'))
          .fontSize($r('app.string.font_size_16'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
      }
      .backgroundColor(Color.White)
      .onClick(() => {
        cancel?.();
        modifyValue = '';
        promptAction.closeCustomDialog(modifyDialogId);
      })
      .layoutWeight(1)

      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.confirm_disconnect'))
          .fontSize($r('app.string.font_size_16'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
      }
      .backgroundColor(Color.White)
      .onClick(() => {
        confirm(modifyValue);
        promptAction.closeCustomDialog(modifyDialogId);
      })
      .layoutWeight(1)
    }
    .margin({ top: $r('app.string.margin_xs') })
  }
  .onAppear(() => {
    modifyValue = '';
  })
  .width(ComponentConst.FULL_PARENT)
  .padding({
    top: ComponentConst.CARD_PADDING_VERTICAL,
    bottom: ComponentConst.CARD_PADDING_VERTICAL,
    left: ComponentConst.CARD_PADDING_HORIZON * 2,
    right: ComponentConst.CARD_PADDING_HORIZON * 2,
  })
}


@Builder
export function minePageBuilder() {
  MinePage()
}

@ComponentV2
struct MinePage {
  @Local vm: MinePageVM = MinePageVM.instance;
  @Local modifyValue: string = '';
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  @Computed get desensitizationPhone() {
    return this.vm.userInfo.phone.slice(0, 3) + '****' + this.vm.userInfo.phone.slice(7);
  }

  @Builder disconnectAccountDialogBuilder(confirm: () => void, cancel?: () => void) {
    disconnectDialogBuilder(confirm, cancel);
  }

  @Builder modifyNickNameDialogBuilder(confirm: (value: string) => void, cancel?: () => void) {
    modifyDialogBuilder(confirm, cancel);
  }

  build() {
    Column() {
      NavigateBar({ title: $r('app.string.mine') })

      RelativeContainer() {
        // 背景
        Row() {
          Image($r('app.media.ic_mine_bg'))
            .objectFit(ImageFit.Fill)
            .width(112)
            .height(112)
        }
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.End)
        .width(ComponentConst.FULL_PARENT)
        .padding({ right: $r('app.string.padding_xl') })
        .backgroundColor(Color.White)
        .borderRadius({
          bottomLeft: ComponentConst.CARD_RADIUS_LARGE,
          bottomRight: ComponentConst.CARD_RADIUS_LARGE,
        })
        .id('mine_bg')

        // 用户信息
        Row() {
          this.userInfo();
        }
        .width(ComponentConst.FULL_PARENT)
        .padding({
          left: $r('app.string.padding_l'),
          right: $r('app.string.padding_l'),
        })
        .alignRules({
          top: ComponentConst.bindTop('mine_bg'),
          bottom: ComponentConst.bindBottom('mine_bg'),
        })
        .margin({ top: $r('app.string.margin_l') })
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .width(ComponentConst.FULL_PARENT)
      .layoutWeight(1)
    }
    .backgroundColor(Color.White)
    .width(ComponentConst.FULL_PARENT)
    .height(ComponentConst.FULL_PARENT)
  }

  @Builder
  titleText() {
    Text('校园助手')
      .fontColor(Color.White)
  }

  @Builder
  userInfo() {
    RelativeContainer() {
      if (this.vm.hasBindAccount) {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
            label: '',
            styleOption: {
              styleConfig: new functionalButtonComponentManager.ButtonConfig()
                .type(ButtonType.Circle)
                .backgroundImage(this.userInfoModel.avatar ?? $r('app.media.ic_mine_unconnected_img'))
                .backgroundImageSize(ImageSize.Cover)
                .width(ComponentConst.ICON_SIZE_XM.width!)
                .height(ComponentConst.ICON_SIZE_XM.height!),
            },
          },
          controller: new functionalButtonComponentManager
            .FunctionalButtonController().onChooseAvatar(async (err, data) => {
              if (err || data === undefined) {
                // 错误日志处理
                hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
                return;
              }
              // 成功日志处理
              hilog.info(0x0000, 'testTag', 'succeeded in choosing avatar');
              // 保存用户头像，下次登录后直接使用

              setTimeout(async () => {
                this.userInfoModel.avatar = data.avatarUri!;
              });
            }),
        }).id('user_image')

        Column({ space: 6 }) {
          Text(this.vm.userInfo.nickname)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Bold)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .onClick(() => {
              promptAction.openCustomDialog({
                builder: () => {
                  this.modifyNickNameDialogBuilder(
                    (value: string) => {
                      this.vm.updateNickName(value);
                    }
                  );
                },
                backgroundColor: Color.White,
              }).then((dialogId: number) => {
                modifyDialogId = dialogId;
              });
            })

          Row({ space: 2 }) {
            Image($r('app.media.ic_mobile_phone'))
              .objectFit(ImageFit.Fill)
              .size(ComponentConst.ICON_SIZE_S)

            Text(this.desensitizationPhone)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('app.color.system_color_grey_60'))
          }
          .width(ComponentConst.AUTO_SIZE)
        }
        .alignItems(HorizontalAlign.Start)
        .alignRules({
          center: ComponentConst.bindVerticalCenter('user_image'),
          left: ComponentConst.bindEnd('user_image'),
        })
        .constraintSize({
          maxWidth: '40%',
        })
        .margin({ left: $r('app.string.margin_m') })
        .id('user_info')

        SimpleCapsuleButton({
          buttonBgColor: $r('sys.color.multi_color_09'),
          iconSrc: $r('app.media.ic_disconnect'),
          textContent: $r('app.string.disconnect_account'),
          textColor: Color.White,
        })
          .alignRules({ right: ComponentConst.bindEnd() })
          .onClick(() => {
            promptAction.openCustomDialog({
              builder: () => {
                this.disconnectAccountDialogBuilder(
                  () => {
                    this.vm.disconnectHuaweiAccount();
                  }
                );
              },
              backgroundColor: Color.White,
            }).then((dialogId: number) => {
              disconnectDialogId = dialogId;
            });
          })
      } else {
        Image($r('app.media.ic_mine_unconnected_img'))
          .objectFit(ImageFit.Fill)
          .size(ComponentConst.ICON_SIZE_XM)
          .borderRadius(32)
          .id('user_image')

        Text($r('app.string.unconnected'))
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('app.color.system_color_grey_60'))
          .alignRules({
            center: ComponentConst.bindVerticalCenter('user_image'),
            left: ComponentConst.bindEnd('user_image'),
          })
          .margin({ left: $r('app.string.margin_m') })
          .id('unconnected_tips')

        SimpleCapsuleButton({
          buttonBgColor: $r('app.color.system_color_grey_10'),
          iconSrc: $r('app.media.ic_connect'),
          textContent: $r('app.string.connect_account'),
          textColor: $r('sys.color.multi_color_09'),
        })
          .alignRules({ right: ComponentConst.bindEnd() })
          .onClick(() => {
            this.vm.connectHuaweiAccount();
          })
      }
    }
    .width(ComponentConst.FULL_PARENT)
    .height(ComponentConst.AUTO_SIZE)
  }
}

