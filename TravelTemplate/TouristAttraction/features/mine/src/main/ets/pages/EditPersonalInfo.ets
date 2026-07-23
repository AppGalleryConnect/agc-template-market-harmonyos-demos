import { AppStorageV2 } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import fs from '@ohos.file.fs';
import { CommonUtil, Constant, Logger } from 'common';
import { UserInfo } from 'types';
import { NickNameDialog, TitleBar } from 'uicomponents';
import { GridRowColSetting } from '../common/GridRowColSetting';

@Builder
export function EditPersonalInfoBuilder() {
  EditPersonalInfo();
}

@ComponentV2
export struct EditPersonalInfo {
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Local index: number = 0;
  @Local isShowGender: boolean = false;
  @Local isShowBirthday: boolean = false;
  @Local draftAvatar: ResourceStr = '';
  @Local draftNickname: string = '';
  @Local cloneUserName: string = '';

  aboutToAppear(): void {
    this.draftAvatar = this.userInfo.avatar;
    this.draftNickname = this.userInfo.nickname;
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: NickNameDialog({
      change: (value: string) => {
        this.cloneUserName = value;
      }, confirm: () => {
        this.draftNickname = this.cloneUserName;
      }, nickName: this.cloneUserName,
    }),
    customStyle: false,
    backgroundColor: 'rgba(250, 250, 250, 0.85)',
    autoCancel: true,
  });
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  BirthdaySelectBuilder() {
    Column() {
      DatePicker({
        start: new Date('1970-1-1'), end: new Date('2100-1-1'), selected: new Date(this.userInfo.birthday),
      })
        .disappearTextStyle(
          { color: $r('sys.color.font_primary'), font: { size: $r('sys.float.Subtitle_S'), weight: FontWeight.Bold } })
        .textStyle({
          color: $r('sys.color.font_primary'), font: { size: $r('sys.float.Subtitle_M'), weight: FontWeight.Normal },
        })
        .selectedTextStyle({
          color: '#64BB5C', font: { size: $r('sys.float.Title_S'), weight: 500 },
        })
        .onDateChange((value: Date) => {
          this.userInfo.birthday = CommonUtil.getFormatDate(value);
        });
    }.height(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center);
  }

  @Builder
  ProfileBuilder() {
    Row() {
      Text('头像')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'));
      Row({ space: 4 }) {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR, label: '', styleOption: {
              styleConfig: new functionalButtonComponentManager.ButtonConfig().type(ButtonType.Circle)
                .backgroundImage(this.draftAvatar ? this.draftAvatar : $r('app.media.default_avatar'))
                .backgroundImageSize(ImageSize.Cover)
                .width(40)
                .height(40)
                .backgroundColor('#FFE5E5E5'),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar(
            (error, data) => {
              if (error) {
                return;
              }
              if (data.avatarUri === undefined || data.avatarUri === '') {
                this.getUIContext().getPromptAction().showToast({ message: '获取头像失败，请重试！' });
              }
              let avatarFile: fs.File | undefined = undefined;
              try {
                avatarFile = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY);
                let newPath: string =
                  this.getUIContext().getHostContext()!.cacheDir + `/${util.generateRandomUUID(false)}.png`;
                fs.copyFileSync(avatarFile.fd, newPath);
                this.draftAvatar = 'file://' + newPath;
              } catch (err) {
                this.getUIContext().getPromptAction().showToast({ message: '获取头像失败，请重试！' });
                Logger.error('choose avatar fail' + JSON.stringify(err));
              } finally {
                if (avatarFile) {
                  fs.close(avatarFile);
                }
              }
            }),
        });
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(12)
          .height(24)
          .fontSize(24)
          .fontColor([$r('sys.color.icon_fourth')]);
      };
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 8,
      bottom: 8,
      left: 12,
      right: 12,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'));
  }

  @Builder
  NickNameBuilder() {
    Row() {
      Text('昵称')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'));
      Row({ space: 4 }) {
        Text(this.draftNickname ? this.draftNickname : '华为用户')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(12)
          .height(24)
          .fontSize(24)
          .fontColor([$r('sys.color.icon_fourth')]);
      };
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween).padding({ top: 12, bottom: 12 })
    .onClick(() => {
      this.cloneUserName = this.draftNickname;
      if (this.dialogController != null) {
        this.dialogController.open();
      }
    });

  }

  @Builder
  PhoneBuilder() {
    Row() {
      Text('手机号')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'));
      Row({ space: 4 }) {
        Text((this.userInfo.phone ?? '').replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'));
      };
    }.padding({ top: 12, bottom: 12 }).width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    NavDestination() {
      TitleBar({
        isShowBack: true, title: '个人信息', clickEvent: () => {
          this.mainPathStack.pop();
        },
      });
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Column() {
            Column({ space: 12 }) {
              this.ProfileBuilder();
              Column() {
                this.NickNameBuilder();
                Divider().color($r('sys.color.comp_divider'));
                this.PhoneBuilder();
              }
              .width(Constant.FULL_PERCENT)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({
                top: 4,
                bottom: 4,
                left: 12,
                right: 12,
              })
              .borderRadius(16)
              .backgroundColor($r('sys.color.background_primary'));
            };

            Blank();
            Row() {
              Button('保存')
                .width(Constant.FULL_PERCENT)
                .constraintSize({ maxWidth: Constant.MAX_WIDTH })
                .backgroundColor($r('sys.color.multi_color_04'))
                .onClick(() => {
                  this.userInfo.avatar = this.draftAvatar;
                  this.userInfo.nickname = this.draftNickname;
                  this.getUIContext().getPromptAction().showToast({ message: '保存成功' });
                  this.mainPathStack.pop();
                });
            }.width(Constant.FULL_PERCENT).padding({ left: 12, right: 12 }).justifyContent(FlexAlign.Center);
          }.height(Constant.FULL_PERCENT).padding({
            top: 8,
            bottom: 8,
            left: 16,
            right: 16,
          });
        };
      }
      .layoutWeight(1).margin({ bottom: this.windowBottomHeight });

    }.hideTitleBar(true).backgroundColor($r('sys.color.background_secondary'));
  }
}
