import { CommonButton, CommonDivider, CommonHeader, ContainerColumn, ContainerRow } from 'componentlib';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { UserInfoEditVM } from '../viewModels/UserInfoEditVM';

@Builder
export function userInfoEditBuilder() {
  UserInfoEditPage();
}

@ComponentV2
export struct UserInfoEditPage {
  vm: UserInfoEditVM = UserInfoEditVM.instance;

  aboutToAppear(): void {
    this.vm.initData();
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '个人设置' });
      Column() {
        this.avatarEditBuilder();
        this.infoEditBuilder();
        this.phoneDisplayBuilder();
        Blank();
        CommonButton({
          title: '保存',
          handleClick: () => {
            this.vm.updateUserInfo();
          },
        });
      }.layoutWeight(1)
      .padding($r('app.string.padding_m'))
      .backgroundColor($r('app.color.system_color_background_auxiliary'));
    }
    .hideTitleBar(true);
  }

  @Builder
  avatarEditBuilder() {
    ContainerRow() {
      Text('头像').titleStyle();
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .type(ButtonType.Circle)
              .backgroundImage(this.vm.editInfo.avatar && this.vm.editInfo.avatar !== '' ? this.vm.editInfo.avatar :
              $r('app.media.ic_default_avatar'))
              .backgroundImageSize(ImageSize.Cover)
              .width(28)
              .height(28)
              .borderRadius($r('app.string.border_radius_capsule'))
              .backgroundColor($r('app.color.icon_color_level3')),

          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error, data) => {
          this.vm.getAvatarSrc(error, data);
        }),
      });
      Image($r('app.media.ic_arrow_right2')).rightIconStyle();
    };
  }

  @Builder
  infoEditBuilder() {
    ContainerColumn() {
      Row() {
        Text('昵称').titleStyle();
        TextInput({ text: this.vm.editInfo.nickname, placeholder: '请输入昵称' })
          .textInputStyle()
          .maxLength(8)
          .onChange((value: string) => {
            this.vm.editInfo.nickname = value;
          });
        Image($r('app.media.ic_info_edit')).rightIconStyle();
      };

      CommonDivider();
      Row() {
        Text('微信').titleStyle();
        TextInput({ text: this.vm.editInfo.wechat, placeholder: '请输入微信号' })
          .textInputStyle()
          .maxLength(8)
          .onChange((value: string) => {
            this.vm.editInfo.wechat = value;
          });
        Image($r('app.media.ic_info_edit')).rightIconStyle();
      };

      CommonDivider();
      Row() {
        Text('生日').titleStyle();
        Row() {
          Text(this.vm.editInfo.birthday ? this.vm.editInfo.birthday : '请选择生日')
            .fontSize($r('app.string.font_size_14'))
            .fontColor($r('app.color.font_color_level2'));
          Image($r('app.media.ic_arrow_right2')).rightIconStyle();
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
              color: $r('app.color.font_color_level2'),
              font: { size: 14, weight: 400, style: FontStyle.Normal },
            },
            textStyle: { color: $r('app.color.font_color_level1'), font: { size: 16, style: FontStyle.Normal } },
            selectedTextStyle: {
              color: $r('app.color.font_color_link'),
              font: { size: 20, weight: FontWeight.Medium, style: FontStyle.Normal },
            },
            alignment: DialogAlignment.Bottom,
            offset: { dx: 0, dy: 0 },
            maskRect: {
              x: 0,
              y: 0,
              width: $r('app.string.width_percent_full'),
              height: $r('app.string.height_percent_full'),
            },
            backgroundColor: $r('app.color.system_color_background_white'),
            backgroundBlurStyle: BlurStyle.NONE,
            acceptButtonStyle: {
              fontColor: $r('app.color.font_color_level1_invert'),
              fontSize: $r('app.string.font_size_16'),
              backgroundColor: $r('app.color.system_theme_color'),
            },
            cancelButtonStyle: {
              fontColor: $r('app.color.font_color_level1'),
              fontSize: $r('app.string.font_size_16'),
              backgroundColor: $r('app.color.system_color_background_white'),
            },
            onDateAccept: (value: Date) => {
              this.vm.handleBirthdayChange(value);
            },
          });
        });
      };
    };
  }

  @Builder
  phoneDisplayBuilder() {
    ContainerRow() {
      Text('电话').titleStyle();
      Text(this.vm.getPhoneNumber())
        .fontSize($r('app.string.font_size_14'))
        .fontColor($r('app.color.font_color_level3'))
        .margin({
          right: $r('app.string.margin_s'),
          top: $r('app.string.margin_xs'),
          bottom: $r('app.string.margin_xs'),
        });
    };
  }
}

@Extend(Text)
function titleStyle() {
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium)
  .fontSize($r('app.string.font_size_16'))
  .layoutWeight(1)
  .margin({
    top: $r('app.string.margin_xs'),
    bottom: $r('app.string.margin_xs'),
  });
}

@Extend(TextInput)
function textInputStyle() {
  .placeholderColor($r('app.color.font_color_level2'))
  .placeholderFont({ size: $r('app.string.font_size_14') })
  .backgroundColor($r('app.color.system_color_background_white'))
  .width(150)
  .textAlign(TextAlign.End)
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level1'))
  .padding({ right: $r('app.string.padding_xs') })
  .margin(0);
}

@Extend(Image)
function rightIconStyle() {
  .width($r('app.integer.icon_size_24'))
  .height($r('app.integer.icon_size_24'))
  .margin({ left: $r('app.string.margin_xs') })
  .fillColor($r('app.color.icon_color_level2'));
}