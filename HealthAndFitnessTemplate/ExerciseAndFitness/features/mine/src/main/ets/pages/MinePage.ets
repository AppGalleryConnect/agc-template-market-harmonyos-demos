import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { BreakpointModel,
  BreakpointNameEnum,
  CommonConstants,
  Record,
  ExerciseRecord,
  ExerciseDays } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { mineGridList } from '../constants/Constants';
import { MineGridItem } from '../types/Types';
import { MineViewModel } from '../viewmodels/MineVM';

@Builder
export function MinePageBuilder() {
  MinePage()
}

interface GridSettingInfo {
  template: string;
  colGap: number;
  rowGap: number;
}

@ComponentV2
struct MinePage {
  today = new Date();
  year: number = this.today.getFullYear();
  month: string = (this.today.getMonth() + 1).toString().padStart(2, '0');
  day: string = this.today.getDate().toString().padStart(2, '0');
  @Local todayExerciseRecord: ExerciseRecord =
    AppStorageV2.connect(ExerciseRecord, String(`${this.year}-${this.month}-${this.day}`), () => new ExerciseRecord())!
  @Local totalExerciseRecord: ExerciseRecord =
    AppStorageV2.connect(ExerciseRecord, 'totalRecord', () => new ExerciseRecord())!
  @Local totalDays: ExerciseDays = AppStorageV2.connect(ExerciseDays, 'totalDays', () => new ExerciseDays())!
  @Local vm: MineViewModel = new MineViewModel();
  @Local totalRecord: Record = { duration: 0, energy: 0 }
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 12,
      rowGap: 12,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 24
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 16
    }
    return gridSettingInfo
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
            Grid() {
              GridItem() {
                this.todayCard()
              }
              GridItem() {
                this.recordCard()
              }
            }
            .columnsTemplate(this.gridSetting.template)
            .columnsGap(this.gridSetting.colGap)
            .rowsGap(this.gridSetting.rowGap)
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
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.pagePaddingBottom,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  loginCard() {
    Column() {
      if (this.vm.userInfoModel.isLogin) {
        Row({ space: CommonConstants.SPACE_L }) {
          Image(this.vm.userIcon)
            .width($r('app.float.user_icon_width'))
            .clipShape(new CircleShape({ width: 48, height: 48 }))
            .draggable(false)
          Text(this.vm.userInfoModel.authorNickName)
            .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          if (this.vm.userInfoModel.isVIP) {
            Row() {
              Image($r('app.media.icon_vip'))
                .width(20)
                .draggable(false)
                .margin({ left: 8, right: 8, top: 4 })
              Text('VIP会员')
                .width(43)
                .height(16)
                .margin({ top: 6 })
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('app.color.VIP'))
                .fontWeight(FontWeight.Medium)
            }
            .backgroundColor($r('app.color.VIP_back'))
            .width(96)
            .height(28)
            .borderRadius(8)
          }
        }
      } else {
        Row({ space: CommonConstants.SPACE_L }) {
          Image($r('app.media.ic_user_unlogin'))
            .width($r('app.float.user_icon_width'))
            .draggable(false)
          Text('去登录')
            .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        }
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick(() => {
          this.vm.jumpLogin();
        })
      }

      Row({ space: CommonConstants.SPACE_L }) {
        Image($r('app.media.ic_mine_vip'))
          .width(32)
          .height(32)
          .draggable(false)
          .margin({ right: 8 })

        Column() {
          Text('运动健身会员')
            .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('app.color.VIP'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 2 })
          Text('开通会员畅快训练')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('app.color.VIP'))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.vm.userInfoModel.isLogin) {
          Text('会员中心')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .borderRadius(14)
            .width(72)
            .height(28)
            .backgroundColor('#E3922F')
            .textAlign(TextAlign.Center)
        } else {
          Text('开通会员')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .borderRadius(14)
            .width(72)
            .height(28)
            .backgroundColor('#E3922F')
            .textAlign(TextAlign.Center)
        }
      }
      .backgroundImage(this.vm.gridCount === 2 ? $r('app.media.background_vip') :
        (this.vm.gridCount === 4 ? $r('app.media.background_vip_middle') : $r('app.media.background_vip_large')))
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(12)
      .padding(12)
      .width('100%')
      .height(64)
      .margin({ top: 12 })
      .onClick(() => {
        this.vm.jumpVIP();
      })
    }
    .backgroundColor(Color.White)
    .width('100%')
    .padding(CommonConstants.PADDING_M)
    .borderRadius(12)
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
  todayCard() {
    Column() {
      Row() {
        Image($r('app.media.ic_today'))
          .width(20)
          .margin({ right: 4 })
          .draggable(false)
        Text('今日运动')
          .width(64)
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      .height(24)
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.Start)

      Row() {
        Column() {
          Row() {
            Text(String(this.todayExerciseRecord.duration))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(分钟)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('运动时长')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)

        Column() {
          Row() {
            Text(String(this.todayExerciseRecord.energy))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(kcal)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('消耗热量')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .width('100%')
  }

  @Builder
  recordCard() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_record'))
            .width(16)
            .margin({ right: 8 ,left: 4})
            .draggable(false)
          Text('运动记录')
            .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Blank()
        }
        .justifyContent(FlexAlign.Start)
        Blank()
        Image($r('app.media.ic_right'))
          .width($r('app.float.arrow_right_w'))
          .draggable(false)
          .onClick(() => {
            this.vm.jumpRecord();
          })
      }
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height(24)

      Row() {
        Column() {
          Row() {
            Text(String(this.totalExerciseRecord.duration))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(分钟)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('总时长')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)

        Column() {
          Row() {
            Text(String(this.totalExerciseRecord.energy))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(kcal)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('总消耗')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)

        Column() {
          Row() {
            Text(String(this.totalDays.totalDays))
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
            Text('(天)')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Medium)
          }
          .margin({ bottom: 8 })

          Text('累计训练')
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      }
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .width('100%')
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