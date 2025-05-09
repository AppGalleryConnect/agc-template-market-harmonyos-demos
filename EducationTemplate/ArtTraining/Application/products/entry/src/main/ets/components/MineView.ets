import { BindPhoneUtil, CommonDivider, CommonHeader, ContainerColumn } from 'componentlib';
import { ORDER_SERVICE_LIST, STORE_INFO_LIST, STUDY_SERVICE_LIST } from '../constants/Constants';
import { OrderServiceItem, StoreInfoItem, StudyServiceItem } from '../types/Types';
import { MineVM } from '../viewmodels/MineVM';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';

@ComponentV2
export struct MineView {
  vm: MineVM = MineVM.instance;

  build() {
    Column() {
      CommonHeader({
        title: '我的',
        bgColor: '#00ffffff',
      });

      Scroll() {
        Column() {
          // 用户信息
          this.userInfoBuilder();

          // 订单
          this.myOrderBuilder();

          // 学习工具
          this.learningToolsBuilder();

          // 商户信息
          this.merchantInfoBuilder();

          Blank().layoutWeight(1)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .padding($r('app.string.padding_l'));
      }
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1);
    }
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .height($r('app.string.height_percent_full'))
    .width($r('app.string.width_percent_full'))
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[0x4afe4f35, 0.0], [0x8F1F3F5, 0.6]],
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  userInfoBuilder() {
    Row() {
      Image(this.vm.isBind ? this.vm.userInfo.avatar : $r('app.media.ic_default_avatar'))
        .width(64)
        .height(64)
        .borderRadius($r('app.string.border_radius_capsule'))
        .alt($r('app.media.ic_default_avatar'))
        .onClick(() => {
          this.vm.jumpToInfoEditPage();
        });
      Column() {
        Text(this.vm.isBind && this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户')
          .fontSize($r('app.string.font_size_18'))
          .margin({ bottom: $r('app.string.margin_s') })
          .fontColor(this.vm.isBind ? $r('app.color.font_color_level1') : $r('app.color.font_color_level2'))
          .fontWeight(500);

        if (this.vm.isBind) {
          Row() {
            Image($r('app.media.ic_mobilephone'))
              .width($r('app.integer.icon_size_16'))
              .height($r('app.integer.icon_size_16'))
              .margin({ right: $r('app.string.margin_xxs') });
            Text(this.vm.phoneLabel)
              .fontSize($r('app.string.font_size_14'))
              .fontColor($r('app.color.font_color_level2'));
          }
          .alignItems(VerticalAlign.Center);
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: $r('app.string.padding_l') })
      .layoutWeight(1)
      .onClick(() => {
        this.vm.jumpToInfoEditPage();
      });

      this.bindPhoneBuilder();

    }
    .width($r('app.string.width_percent_full'))
    .padding({
      bottom: $r('app.string.padding_xs'),
    })
    .margin({
      left: $r('app.string.margin_l'),
      bottom: $r('app.string.margin_l'),
    })
    .justifyContent(FlexAlign.Start);
  }

  @Builder
  myOrderBuilder() {
    Column() {
      Row() {
        Text('我的订单').moduleTitleStyle().layoutWeight(1);
        Image($r('app.media.ic_arrow_right'))
          .width($r('app.integer.icon_size_12'))
          .onClick(() => {
            this.vm.jumpToOrderList();
          });
      };

      CommonDivider({ gap: $r('app.string.margin_m') });
      Row() {
        ForEach(ORDER_SERVICE_LIST, (item: OrderServiceItem) => {
          Column() {
            Image(item.icon)
              .width($r('app.integer.icon_size_32'))
              .height($r('app.integer.icon_size_32'))
              .margin({ bottom: $r('app.string.margin_xs') });
            Text(item.label)
              .fontColor($r('app.color.font_color_level1'))
              .fontSize($r('app.string.font_size_12'));
          }
          .onClick(() => {
            this.vm.jumpToOrderList(item.type);
          });
        }, (item: OrderServiceItem) => item.label);
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceAround);
    }
    .moduleContainerStyle();

  }

  @Builder
  learningToolsBuilder() {
    ContainerColumn({
      title: '学习工具',
    }) {
      Row() {
        ForEach(STUDY_SERVICE_LIST, (item: StudyServiceItem) => {
          Column() {
            Image(item.icon)
              .width(30)
              .height(30)
              .margin({ bottom: $r('app.string.margin_xs') });
            Text(item.label)
              .fontColor($r('app.color.font_color_level1'))
              .fontSize($r('app.string.font_size_12'));
          }
          .onClick(() => {
            this.vm.jumpToStudyService(item.type);
          });
        }, (item: StudyServiceItem) => item.label);
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceAround);
    };
  }

  @Builder
  merchantInfoBuilder() {
    ContainerColumn() {
      ForEach(this.vm.storeInfo, (item: StoreInfoItem, index: number) => {
        Row() {
          Image(item.icon)
            .width($r('app.integer.icon_size_16'))
            .height($r('app.integer.icon_size_16'))
            .margin({ right: $r('app.string.margin_l') });
          Text(item.label)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level1'))
            .margin({ right: $r('app.string.margin_s') });
          Text(item.value)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level2'))
            .layoutWeight(1);
          if (item.showArrow) {
            Image($r('app.media.ic_arrow_right'))
              .width($r('app.integer.icon_size_12'))
              .height($r('app.integer.icon_size_12'))
              .fillColor($r('app.color.icon_color_level2'))
              .onClick(() => {
                this.vm.handleMerchantInfoClick(item);
              });
          }
        };

        if (index < STORE_INFO_LIST.length - 1) {
          CommonDivider().margin({ left: $r('app.string.margin_xl') });
        }
      }, (item: StoreInfoItem) => item.label);
    };
  }

  @Builder
  bindPhoneBuilder() {
    Row() {
      Image($r('app.media.ic_bind_phone'))
        .height($r('app.integer.icon_size_12'))
        .width($r('app.integer.icon_size_12'))
        .fillColor(this.vm.isBind ? $r('app.color.icon_color_level1_invert') : $r('app.color.system_theme_color'))
        .margin({ right: $r('app.string.margin_xs') });
      if (!this.vm.isBind) {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
            label: '关联账号',
            styleOption: {
              plain: true,
              styleConfig: new functionalButtonComponentManager
                .ButtonConfig()
                .type(ButtonType.Normal)
                .padding(0)
                .stateEffect(false)
                .margin(0)
                .backgroundColor('#00ffffff')
                .fontSize($r('app.string.font_size_12'))
                .fontColor($r('app.color.system_theme_color')),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController()
            .onGetPhoneNumber((err, data) => {
              BindPhoneUtil.handleFunctionalButtonClick(err, data?.code);
            }),
        });
      } else {
        Text('解除关联')
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.system_color_background_white'))
          .onClick(() => {
            BindPhoneUtil.unbindPhone();
          });
      }
    }
    .padding({
      left: $r('app.string.padding_s'),
      right: $r('app.string.padding_s'),
      top: $r('app.string.padding_s'),
      bottom: $r('app.string.padding_s'),
    })
    .height(30)
    .borderRadius(99)
    .margin({
      right: $r('app.string.margin_xl'),
      bottom: $r('app.string.margin_xl'),
    })
    .backgroundColor(this.vm.isBind ? $r('app.color.system_theme_color') :
    $r('app.color.system_color_background_grey_level2'));
  }
}

@Extend(Column)
function moduleContainerStyle() {
  .borderRadius($r('app.string.border_radius_16'))
  .width($r('app.string.width_percent_full'))
  .alignItems(HorizontalAlign.Start)
  .padding($r('app.string.padding_m'))
  .margin({
    bottom: $r('app.string.margin_l'),
  })
  .backgroundColor($r('app.color.system_color_background_white'));
}

@Extend(Text)
function moduleTitleStyle() {
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium)
  .fontSize($r('app.string.font_size_16'));
}