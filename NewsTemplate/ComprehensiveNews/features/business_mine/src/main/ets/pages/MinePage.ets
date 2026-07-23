import { CircleShape } from '@kit.ArkUI';
import { CommonConstants, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingView } from 'module_app_setting';
import { mineGridList } from '../constants/Constants';
import { MineGridItem } from '../types/Types';
import { MineViewModel } from '../viewmodels/MineVM';

@Builder
export function MinePageBuilder() {
  MinePage()
}

@ComponentV2
struct MinePage {
  @Local vm: MineViewModel = new MineViewModel();

  aboutToAppear(): void {
    this.vm.queryMembershipStatus();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的',
          isSubTitle: false,
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            this.loginCard()
            this.gridCard()
            this.listCard()
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          top: CommonConstants.SPACE_M,
          bottom: CommonConstants.SPACE_M,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  loginCard() {
    Column() {
      if (this.vm.userInfoModel.isLogin) {
        Column() {
          Row({ space: CommonConstants.SPACE_L }) {
            Image(this.vm.userIcon)
              .width($r('app.float.user_icon_width'))
              .clipShape(new CircleShape({ width: 48, height: 48 }))
              .draggable(false)
            Column({ space: CommonConstants.SPACE_XXS }) {
              Row() {
                Text(this.vm.userInfoModel.authorNickName)
                  .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .constraintSize({
                    maxWidth: 'calc(100% - 50vp)',
                  })
                SymbolGlyph($r('sys.symbol.v_diamond_fill'))
                  .fontColor([this.vm.userInfoModel.isMembership ? $r('app.color.membership') :
                    $r('sys.color.font_tertiary')])
                  .fontWeight(FontWeight.Normal)
                  .fontSize(16)
                  .margin({
                    left: CommonConstants.PADDING_S,
                  })
                Text('会员')
                  .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                  .fontColor(this.vm.userInfoModel.isMembership ? $r('sys.color.font_primary') :
                    $r('sys.color.font_tertiary'))
                  .fontWeight(FontWeight.Regular)
                  .margin({
                    left: CommonConstants.PADDING_XXS,
                  })
              }

              Row({ space: CommonConstants.SPACE_XS }) {
                Image($r('app.media.ic_phone'))
                  .width($r('app.float.medium_img_width'))
                  .draggable(false)
                  .fillColor($r('sys.color.icon_secondary'))
                Text(this.vm.userInfoModel.authorPhone)
                  .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                  .fontColor($r('sys.color.font_secondary'))
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Image($r('app.media.ic_right'))
              .width($r('app.float.arrow_right_w'))
              .draggable(false)
          }
          .borderRadius($r('app.float.large_radius'))
          .padding(CommonConstants.PADDING_S)
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .onClick(() => {
            this.vm.jumpProfile();
          })

          Divider().width(CommonConstants.FULL_PERCENT).margin({
            left: CommonConstants.PADDING_S,
            right: CommonConstants.PADDING_S,
            top: CommonConstants.PADDING_XS,
            bottom: CommonConstants.PADDING_XS,
          })

          Row() {
            Text(this.vm.userInfoModel.isMembership ? '请查看您的会员权益' : '开通会员享受更多权益')
              .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
            Button('会员中心')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('app.color.membership'))
              .height(28)
              .onClick(() => {
                this.vm.jumpMembership();
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: CommonConstants.PADDING_S,
            right: CommonConstants.PADDING_S,
            top: CommonConstants.PADDING_S,
            bottom: CommonConstants.PADDING_S,
          })
        }
      } else {
        Row({ space: CommonConstants.SPACE_L }) {
          Image($r('app.media.ic_user_unlogin'))
            .width($r('app.float.user_icon_width'))
            .draggable(false)
          Column({ space: CommonConstants.SPACE_XXS }) {
            Text('点击登录')
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('登录后享受更多服务')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
        }
        .borderRadius($r('app.float.large_radius'))
        .padding(CommonConstants.PADDING_S)
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick(() => {
          this.vm.jumpLogin();
        })
      }
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width(CommonConstants.FULL_PERCENT)
    .padding(CommonConstants.PADDING_XS)
    .borderRadius($r('app.float.large_radius'))
  }

  @Builder
  gridCard() {
    Column() {
      Grid() {
        ForEach(mineGridList, (v: MineGridItem) => {
          GridItem() {
            Column() {
              Image(v.icon)
                .width($r('app.float.grid_icon_width'))
                .draggable(false)
              Text(v.label)
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
            }
            .height(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .borderRadius($r('app.float.large_radius'))
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .padding({
            top: CommonConstants.PADDING_S,
            bottom: CommonConstants.PADDING_S,
            left: CommonConstants.PADDING_XS,
            right: CommonConstants.PADDING_XS,
          })
          .onClick(() => {
            this.vm.gridClick(v);
          })
        }, (v: MineGridItem) => v.label as string)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(76)
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.large_radius'))
  }

  @Builder
  listCard() {
    Column({ space: CommonConstants.SPACE_M }) {
      Text('常用服务')
        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      SettingView({
        pathStack: RouterUtils.getStack(),
        settingList: [this.vm.group],
        fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
        enableLaneSetting: true,
        enableEdgeEffect: false,
        fullGridCol: true,
        autoHeight: true,
        pagePadding: {
          top: 8,
          left: 0,
          right: 0,
        },
      })
    }
    .margin({ top: CommonConstants.PADDING_XS })
    .alignItems(HorizontalAlign.Start)
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }
}