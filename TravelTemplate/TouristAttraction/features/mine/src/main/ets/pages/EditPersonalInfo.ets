import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { Constant, CommonUtil, Logger, AccountUtil } from 'common';
import { NickNameDialog, TitleBar } from 'uicomponents';
import { genderData, GenderType } from '../model/PersonalInfo';
import { UserInfo } from 'types';

@Builder
export function EditPersonalInfoBuilder() {
  EditPersonalInfo();
}

@ComponentV2
export struct EditPersonalInfo {
  @Local userInfo: UserInfo = AccountUtil.getUserInfo();
  @Local index: number = 0;
  @Local isShowGender: boolean = false;
  @Local isShowBirthday: boolean = false;
  @Local cloneUserName: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: NickNameDialog({
      change: (value: string) => {
        this.cloneUserName = value;
      },
      confirm: () => {
        this.userInfo.nickname = this.cloneUserName;
      },
      nickName: this.cloneUserName,
    }),
    customStyle: false,
    backgroundColor: 'rgba(250, 250, 250, 0.85)',
    autoCancel: true,
  });

  @Computed
  get genderVal() {
    let genderMap: Map<number, string> = new Map();
    genderData.forEach((item) => {
      genderMap.set(item, item === GenderType.MALE ? '男' : '女');
    });

    return genderMap.get(this.userInfo.gender) ?? '';
  }

  @Builder
  GenderSelectBuilder() {
    List() {
      ForEach(genderData, (item: GenderType) => {
        ListItem() {
          Column() {
            Text(`${item === GenderType.MALE ? '男' : '女'}`)
              .fontWeight(500)
              .height(48)
              .width(Constant.FULL_PERCENT)
              .textAlign(TextAlign.Center);
            Divider().opacity(0.05);
          };
        }.onClick(() => {
          this.userInfo.gender = item;
          this.isShowGender = false;
        });
      }, (item: GenderType) => item.toString());

      ListItem() {
        Text('取消')
          .width(Constant.FULL_PERCENT)
          .textAlign(TextAlign.Center)
          .height(40)
          .opacity(0.4)
          .onClick(() => this.isShowGender = false);
      };
    }.padding(12);
  }

  @Builder
  BirthdaySelectBuilder() {
    Column() {
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: new Date(this.userInfo.birthday),
      })
        .disappearTextStyle({ color: $r('sys.color.font_primary'), font: { size: $r('sys.float.Subtitle_S'), weight: FontWeight.Bold } })
        .textStyle({ color: $r('sys.color.font_primary'), font: { size: $r('sys.float.Subtitle_M'), weight: FontWeight.Normal } })
        .selectedTextStyle({
          color: '#64BB5C',
          font: { size: $r('sys.float.Title_S'), weight: 500 },
        })
        .onDateChange((value: Date) => {
          this.userInfo.birthday = CommonUtil.getFormatDate(value);
        });
    }.height(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center);
  }

  @Builder
  ProfileBuilder() {
    Row() {
      Text('头像').fontWeight(500).opacity(0.9);
      Row() {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
            label: '',
            styleOption: {
              styleConfig: new functionalButtonComponentManager.ButtonConfig()
                .type(ButtonType.Circle)
                .backgroundImage(this.userInfo.avatar ? this.userInfo.avatar : $r('app.media.default_avatar'))
                .backgroundImageSize(ImageSize.Cover)
                .width(28)
                .height(28)
                .backgroundColor('#FFE5E5E5'),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error,
            data) => {
            if (error) {
              return;
            }
            if (data.avatarUri === undefined || data.avatarUri === '') {
              this.getUIContext().getPromptAction().showToast({ message: '获取头像失败，请重试！' });
            }
            let avatarFile: fs.File | undefined = undefined;
            try {
              avatarFile = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY);
              let newPath: string = this.getUIContext().getHostContext()!.cacheDir + `/${util.generateRandomUUID(false)}.png`;
              fs.copyFileSync(avatarFile.fd, newPath);
              this.userInfo.avatar = 'file://' + newPath;
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
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

    Divider().margin({ top: 12, bottom: 12 }).opacity(0.05);
  }

  @Builder
  NickNameBuilder() {
    Row() {
      Text('昵称').fontWeight(500).opacity(0.9);
      Row({ space: 4 }) {
        Text(this.userInfo.nickname ? this.userInfo.nickname : '华为用户');
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
      this.cloneUserName = this.userInfo.nickname;
      if (this.dialogController != null) {
        this.dialogController.open();
      }
    });

    Divider().margin({ top: 12, bottom: 12 }).opacity(0.05);
  }

  @Builder
  GenderBuilder() {
    Row() {
      Text('性别').fontWeight(500).opacity(0.9);
      Row() {
        Text(this.genderVal);
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.isShowGender = true;
    }).bindSheet($$this.isShowGender, this.GenderSelectBuilder(),
      { showClose: false, height: 180 });

    Divider().margin({ top: 12, bottom: 12 }).opacity(0.05);
  }

  @Builder
  BirthdayBuilder() {
    Row() {
      Text('生日').fontWeight(500).opacity(0.9);
      Row() {
        Text(this.userInfo.birthday);
        Image($r('app.media.chevron_right')).size({ width: 14, height: 24 });
      };
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.isShowBirthday = true;
    }).bindSheet($$this.isShowBirthday, this.BirthdaySelectBuilder(),
      { height: '40%' });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '用户信息', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column(){
          this.ProfileBuilder();
          this.NickNameBuilder();
          this.GenderBuilder();
          this.BirthdayBuilder();
        }.padding(12)
      }.height(Constant.FULL_PERCENT);
    }.hideTitleBar(true);
  }
}
