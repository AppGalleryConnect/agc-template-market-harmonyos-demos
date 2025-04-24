import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { promptAction } from '@kit.ArkUI';
import { AccountUtil, Logger, MemberInfoModel, RouterModule, UserInfoModel } from 'commonlib';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { CommonButton, CommonHeader } from 'componentlib';
import { EditDialogType, Gender } from '../constants';
import { ProfileEditPageVM } from '../viewModels/ProfileEditPageVM';

const TAG: string = '[ProfileEditPage]';

@ComponentV2
struct ProfileEditPage {
  vm: ProfileEditPageVM = ProfileEditPageVM.instance;

  aboutToAppear(): void {
    this.vm.cloneUserInfo();
  }

  build() {
    NavDestination() {
      CommonHeader({
        title: '账号设置',
      });
      Column() {
        Column() {
          this.avatarEditingBuilder();
          this.dividerBuilder();
          this.nicknameEditingBuilder();
        }
        .commonGroupStyle();

        Column() {
          this.realNameEditingBuilder();
          this.dividerBuilder();
          this.genderEditingBuilder();
          this.dividerBuilder();
          this.phoneNumberEditingBuilder();
          this.dividerBuilder();
          this.birthdayEditingBuilder();
        }
        .commonGroupStyle();

      }
      .height('100%')
      .padding($r('app.string.padding_s'))
      .backgroundColor('#FFF5F5F5');

      Column() {
        CommonButton({
          title: '保存',
          handleClick: () => {
            this.vm.updateUserInfo();
          },
        });
      }
      .position({
        bottom: 0,
      });
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true);

  }

  @Builder
  avatarEditingBuilder() {
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
              .backgroundImage(this.vm.newUserInfo.avatar ? this.vm.newUserInfo.avatar :
              $r('app.media.ic_default_avatar'))
              .backgroundImageSize(ImageSize.Cover)
              .width(28)
              .height(28)
              .backgroundColor('#FFE5E5E5'),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error, data) => {
          if (error) {
            return; // todo: 设计一个弹窗
          }
          let avatarFile: fs.File | null = null;
          try {
            avatarFile = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
            let newPath: string = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
            fs.copyFileSync(avatarFile.fd, newPath);
            this.vm.newUserInfo.avatar = 'file://' + newPath;
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
  nicknameEditingBuilder() {
    Row() {
      Text('昵称')
        .commonLabelStyle();
      Row() {
        TextInput({ text: this.vm.newUserInfo.nickname, placeholder: '请输入昵称' })
          .textInputStyle()
          .maxLength(8)
          .onChange((value) => {
            this.vm.newUserInfo.nickname = value;
          });
      }
      .height(60);
    }
    .commonItemStyle();
  }

  @Builder
  realNameEditingBuilder() {
    Row() {
      Text() {
        Span('*').fontColor($r('app.color.system_color_highlight'));
        Span('姓名');
      }
      .commonLabelStyle();

      Row() {
        TextInput({ text: this.vm.newUserInfo.name, placeholder: '请输入姓名' })
          .textInputStyle()
          .maxLength(8)
          .onChange((value) => {
            this.vm.newUserInfo.name = value;
          });
      }
      .height(60);
    }
    .commonItemStyle();
  }

  @Builder
  phoneNumberEditingBuilder() {
    Row() {
      Text() {
        Span('*').fontColor($r('app.color.system_color_highlight'));
        Span('手机号');
      };

      Row() {
        TextInput({ text: this.vm.newUserInfo.cellphone, placeholder: '请输入手机号' })
          .textInputStyle()
          .maxLength(11)
          .type(InputType.PhoneNumber)
          .onChange((value) => {
            this.vm.newUserInfo.cellphone = value;
          });
      }
      .height(60);
    }
    .commonItemStyle();
  }

  @Builder
  genderEditingBuilder() {
    Row() {
      Text() {
        Span('*').fontColor($r('app.color.system_color_highlight'));
        Span('性别');
      };

      Row() {
        Row() {
          Text('男')
            .width(42)
            .commonLabelStyle()
            .borderWidth(1)
            .borderRadius(10)
            .borderColor(this.vm.gender === Gender.MALE ? '#FF007DFF' : '#FFE0E0E0')
            .textAlign(TextAlign.Center);
        }
        .padding({
          left: $r('app.string.padding_xs'),
          right: $r('app.string.padding_xs'),
        })
        .onClick(() => this.vm.gender = Gender.MALE);

        Row() {
          Text('女')
            .width(42)
            .commonLabelStyle()
            .borderWidth(0.8)
            .borderRadius(10)
            .borderColor(this.vm.gender === Gender.FEMALE ? '#FF007DFF' : '#FFE0E0E0')
            .textAlign(TextAlign.Center);
        }
        .height('100%')
        .onClick(() => this.vm.gender = Gender.FEMALE);
      }
      .width(100)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .commonItemStyle();
  }

  @Builder
  birthdayEditingBuilder() {
    Row() {
      Text('生日').commonLabelStyle();
      Row() {
        Text(this.vm.newUserInfo.birthday).commonLabelStyle()
          .margin({ right: 12 });
        Image($r('app.media.ic_right_arrow')).width(12).margin($r('app.string.margin_s'));
      }
      .onClick(() => {
        DatePickerDialog.show({
          start: new Date('1900-1-1'),
          end: new Date(Date.now()),
          lunar: false,
          showTime: false, // 是否显示时钟与分钟
          useMilitaryTime: true, // 是否使用 24 小时制度
          lunarSwitch: false, // 是否打开用于切换农历或公历的开关
          disappearTextStyle: { color: '#FF666666', font: { size: 14, weight: 400, style: FontStyle.Normal } },
          textStyle: { color: '#FF666666', font: { size: 14, weight: 400, style: FontStyle.Normal } },
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
            backgroundColor: '#FF007DFF',
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
            this.vm.newUserInfo.birthday = value.getFullYear() + '-' + month + '-' + day;
          },
        });
      });
    }
    .commonItemStyle();
  }

  @Builder
  dividerBuilder() {
    Divider()
      .vertical(false)
      .color('#FFE0E0E0')
      .strokeWidth(1)
      .lineCap(LineCapStyle.Butt);
  }
}

@Extend(Text)
function commonLabelStyle() {
  .fontSize($r('app.string.font_size_28'))
  .fontColor('#FF191919');
}

@Extend(Column)
function commonGroupStyle() {
  .margin({ bottom: $r('app.string.margin_m') })
  .padding({ left: $r('app.string.padding_m'), right: $r('app.string.padding_m') })
  .backgroundColor('#FFFFFFFF')
  .borderRadius($r('app.string.border_radius_16'));
}

@Extend(Row)
function commonItemStyle() {
  .width('100%')
  .height(60)
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.SpaceBetween);
}

@Extend(TextInput)
function textInputStyle() {
  .placeholderColor($r('app.color.font_color_level2'))
  .placeholderFont({ size: $r('app.string.font_size_28') })
  .backgroundColor($r('app.color.system_color_background_white'))
  .width(150)
  .textAlign(TextAlign.End)
  .fontSize($r('app.string.font_size_28'))
  .fontColor($r('app.color.font_color_level1'))
  .padding({ right: $r('app.string.padding_xs') })
  .margin(0);
}

@Builder
export function profileEditPageBuilder() {
  ProfileEditPage();
}