import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { promptAction } from '@kit.ArkUI';
import { AccountUtil, RouterModule, UserInfoModel, CommonConstants, Logger } from 'commonlib';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { BaseSuccessResponse, https, UpdateUserInfoRequest } from 'network';
import { Gender } from '../types/Index';

const TAG: string = '[ProfileEditPage]';


@ComponentV2
struct ProfileEditPage {
  @Local
  private userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Local
  private gender: Gender = Gender.MALE;
  @Local
  private newUserInfo: UserInfoModel = new UserInfoModel();

  aboutToAppear(): void {
    this.cloneUserInfo();
    this.gender = this.newUserInfo.sex === '1' ? Gender.MALE : Gender.FEMALE;
  }

  cloneUserInfo() {
    this.newUserInfo.avatar = this.userInfo.avatar;
    this.newUserInfo.name = this.userInfo.name;
    this.newUserInfo.nickname = this.userInfo.nickname;
    this.newUserInfo.sex = this.userInfo.sex;
    this.newUserInfo.cellphone = this.userInfo.cellphone;
    this.newUserInfo.birthday = this.userInfo.birthday;
    this.newUserInfo.avatar = this.userInfo.avatar;
  }

  isNewUserInfoValid(): boolean {
    if (!this.newUserInfo.name) {
      promptAction.showToast({ message: '请填写用户姓名！' });
      return false;
    }
    if (!this.newUserInfo.nickname) {
      promptAction.showToast({ message: '请填写用户昵称！' });
      return false;
    }
    if (!this.newUserInfo.birthday) {
      promptAction.showToast({ message: '请填写生日！' });
      return false;
    }
    return true;
  }

  async updateUserInfo() {
    if (!this.isNewUserInfoValid()) {
      return;
    }
    const profileInfo: UpdateUserInfoRequest = {
      id: this.userInfo.id,
      name: this.newUserInfo.name ?? '',
      nickname: this.newUserInfo.nickname ?? '',
      sex: this.gender,
      cellphone: this.newUserInfo.cellphone ?? '',
      birthday: this.newUserInfo.birthday ?? '',
      avatar: this.newUserInfo.avatar ?? '',
    };
    const res: BaseSuccessResponse = await https.updateUserInfo(profileInfo);
    if (res.code === 0) {
      promptAction.showToast({ message: '修改成功!' });
      this.newUserInfo.sex = this.gender;
      AccountUtil.updateUserInfo(this.newUserInfo);
      const timer = setTimeout(() => {
        RouterModule.pop();
        clearTimeout(timer);
      }, 1000);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            this.AvatarEditingBuilder();
            this.DividerBuilder();
            this.NicknameEditingBuilder();
            this.DividerBuilder();
            this.RealNameEditingBuilder();
            this.DividerBuilder();
            this.GenderEditingBuilder();
            this.DividerBuilder();
            this.PhoneNumberEditingBuilder();
            this.DividerBuilder();
            this.BirthdayEditingBuilder();
          }.backgroundColor(CommonConstants.BG_COLOR_WHITE)
          .margin({ bottom: 20 })
          .padding({ left: 10, right: 10, top: 10 });

        }
        .align(Alignment.Top)
        .height('calc(100% - 75vp)')
        .scrollBar(BarState.Off);

        Column() {
          Button('保存')
            .width('100%')
            .backgroundColor(CommonConstants.FONT_COLOR_GREEN)
            .fontWeight(500)
            .fontSize(CommonConstants.FONT_SIZE_L)
            .borderRadius(20)
            .height(40)
            .onClick(() => {
              this.updateUserInfo();
            });
        }
        .justifyContent(FlexAlign.Center)
        .width('100%').padding({ left: 10, right: 10 }).height(75);
      }.height(CommonConstants.FULL_HEIGHT).backgroundColor(CommonConstants.BG_COLOR_GRAY);
    }
    .width('100%')
    .height('100%')
    .title('编辑资料');

  }

  @Builder
  AvatarEditingBuilder() {
    Row() {
      Text('头像')
        .commonLabelStyle();
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .type(ButtonType.Circle)
              .backgroundImage(this.newUserInfo.avatar ? this.newUserInfo.avatar : $r('app.media.icon_default_avatar'))
              .backgroundImageSize(ImageSize.Cover)
              .width(30)
              .height(30)
              .backgroundColor('#FFE5E5E5'),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error, data) => {
          if (error) {
            return;
          }
          let avatarFile: fs.File | null = null;
          try {
            avatarFile = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
            let newPath: string = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
            fs.copyFileSync(avatarFile.fd, newPath);
            this.newUserInfo.avatar = 'file://' + newPath;
          } catch (err) {
            Logger.error(TAG, 'get photo error:' + err);
          } finally {
            if (avatarFile) {
              fs.closeSync(avatarFile);
            }
          }
        }),
      });
    }
    .commonItemStyle();
  }

  @Builder
  NicknameEditingBuilder() {
    Row() {
      Text('昵称')
        .commonLabelStyle();

      TextInput({ text: this.newUserInfo.nickname }).commonInputStyle().onChange((res) => {
        this.newUserInfo.nickname = res;
      });
    }
    .commonItemStyle();
  }

  @Builder
  RealNameEditingBuilder() {
    Row() {
      Text('姓名').commonLabelStyle();
      TextInput({ text: this.newUserInfo.name }).commonInputStyle().onChange((res) => {
        this.newUserInfo.name = res;
      });

    }
    .commonItemStyle();
  }

  @Builder
  PhoneNumberEditingBuilder() {
    Row() {
      Text('手机号').commonLabelStyle();
      Text(this.newUserInfo.cellphone === '' ? '未关联手机号' : this.newUserInfo.cellphone)
        .commonTextStyle()
        .fontColor(this.newUserInfo.cellphone === '' ? CommonConstants.FONT_COLOR_GRAY :
        CommonConstants.FONT_COLOR_BLACK);
    }
    .commonItemStyle();
  }

  @Builder
  GenderEditingBuilder() {
    Row() {
      Text('性别').commonLabelStyle();
      Row() {
        Row() {
          Text('男')
            .width(52)
            .borderWidth(1)
            .borderRadius(24)
            .height(24)
            .borderColor(this.gender === Gender.MALE ? CommonConstants.FONT_COLOR_GREEN : '#FFCCCCCC')
            .textAlign(TextAlign.Center)
            .fontSize(CommonConstants.FONT_SIZE_M)
            .fontColor(this.gender === Gender.MALE ? '#FFFFFF' : CommonConstants.FONT_COLOR_BLACK)
            .backgroundColor(this.gender === Gender.MALE ? CommonConstants.FONT_COLOR_GREEN : '');
        }
        .margin({ right: 20 })
        .height('100%')
        .onClick(() => this.gender = Gender.MALE);

        Row() {
          Text('女')
            .width(52)
            .borderWidth(1)
            .borderRadius(24)
            .height(24)
            .borderColor(this.gender === Gender.FEMALE ? CommonConstants.FONT_COLOR_GREEN : '#FFCCCCCC')
            .textAlign(TextAlign.Center)
            .fontSize(CommonConstants.FONT_SIZE_M)
            .fontColor(this.gender === Gender.FEMALE ? '#FFFFFF' : CommonConstants.FONT_COLOR_BLACK)
            .backgroundColor(this.gender === Gender.FEMALE ? CommonConstants.FONT_COLOR_GREEN : '');
        }
        .height('100%')
        .onClick(() => this.gender = Gender.FEMALE);
      };
    }
    .commonItemStyle();
  }

  @Builder
  BirthdayEditingBuilder() {
    Row() {
      Text('生日').commonLabelStyle();
      Row() {
        Text(this.newUserInfo.birthday).commonLabelStyle();
        Image($r('app.media.icon_right_arrow')).width(13).margin({ left: 10 });
      }
      .onClick(() => {
        DatePickerDialog.show({
          start: new Date('1900-1-1'),
          end: new Date(Date.now()),
          lunar: false,
          showTime: false, // 是否显示时钟与分钟
          useMilitaryTime: true, // 是否使用 24 小时制度
          lunarSwitch: false, // 是否打开用于切换农历或公历的开关
          disappearTextStyle: {
            color: CommonConstants.FONT_COLOR_BLACK,
            font: { size: 14, weight: 400, style: FontStyle.Normal },
          },
          textStyle: {
            color: CommonConstants.FONT_COLOR_BLACK,
            font: { size: 14, weight: 400, style: FontStyle.Normal },
          },
          selectedTextStyle: { color: '#FF191919', font: { size: 16, weight: 700, style: FontStyle.Normal } },
          alignment: DialogAlignment.Bottom,
          offset: { dx: 0, dy: 0 },
          maskRect: {
            x: 0,
            y: 0,
            width: '100%',
            height: '100%',
          },
          backgroundColor: '#FFFFFFFF',
          backgroundBlurStyle: BlurStyle.NONE,
          acceptButtonStyle: {
            type: ButtonType.Normal,
            style: ButtonStyleMode.NORMAL,
            role: ButtonRole.NORMAL,
            fontColor: '#FFFFFFFF',
            fontSize: 14,
            backgroundColor: CommonConstants.FONT_COLOR_GREEN,
            borderRadius: 10,
          },
          cancelButtonStyle: {
            type: ButtonType.Normal,
            style: ButtonStyleMode.NORMAL,
            role: ButtonRole.NORMAL,
            fontColor: '#FF191919',
            fontSize: 14,
            backgroundColor: '#FFFFFFFF',
            borderRadius: 10,
          },
          onDateAccept: (value: Date) => {
            let month: string = (value.getMonth() + 1).toString();
            if (month.length === 1) {
              month = '0' + month;
            }
            let day: string = value.getDate().toString();
            if (day.length === 1) {
              day = '0' + day;
            }
            this.newUserInfo.birthday = value.getFullYear() + '-' + month + '-' + day;
          },
        });
      });
    }
    .commonItemStyle();
  }

  @Builder
  DividerBuilder() {
    Divider()
      .vertical(false)
      .color(CommonConstants.DIVIDER_GRAY)
      .strokeWidth(0.5);
  }
}

@Extend(TextInput)
function commonInputStyle() {
  .width(200)
  .height('100%')
  .textAlign(TextAlign.End)
  .padding({ left: 0, right: 0 })
  .fontSize(CommonConstants.FONT_SIZE_M)
  .fontColor(CommonConstants.FONT_COLOR_BLACK)
  .backgroundColor('transparent');
}

@Extend(Text)
function commonTextStyle() {
  .width(200)
  .height('100%')
  .textAlign(TextAlign.End)
  .padding({ left: 0, right: 0 })
  .fontSize(CommonConstants.FONT_SIZE_M)
  .backgroundColor('transparent');
}

@Extend(Text)
function commonLabelStyle() {
  .fontSize(CommonConstants.FONT_SIZE_M)
  .fontColor(CommonConstants.FONT_COLOR_BLACK);
}


@Extend(Row)
function commonItemStyle() {
  .width('100%')
  .height(52)
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.SpaceBetween);
}

@Builder
export function ProfileEditPageBuilder() {
  ProfileEditPage();
}