import { Logger } from '@hw-agconnect/ui-base';
import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  FontModel,
  NavHeaderBar,
  ReturnButton,
  TCRouter
} from 'common';
import { baseActionSheet, UserInfo, fp2pxUtil } from 'base_common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ReadSettingPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local userInfo: UserInfo = AppStorage.get<UserInfo>('userInfo')!
  @Local isReminderTime: boolean = false
  @Local reminderTime: number = this.userInfo.reminderTime
  @Local optionTime: number = this.userInfo.reminderTime
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '阅读设置',
          hasBackButton: true,
          hasBgColor: true,
          isMainPage: false,
        })
        Scroll() {
          Column({ space: 12 }) {
            Column() {
              Row() {
                Text('全屏阅读')
                  .fontSize(this.fontModel.getFg(16))
                  .height(21)
                  .width(191)
                Toggle({ type: ToggleType.Switch, isOn: this.userInfo.fullScreen })
                  .width(36)
                  .height(20)
                  .selectedColor($r('sys.color.comp_background_emphasize'))
                  .switchPointColor($r('sys.color.comp_background_primary_contrary'))
                  .onChange((isOn: boolean) => {
                    this.userInfo.fullScreen = isOn
                  })
              }
              .width(Constants.FULL_SIZE)
              .height(56)
              .justifyContent(FlexAlign.SpaceBetween)

              Divider()
                .width(Constants.FULL_SIZE)

              Row() {
                Text('不显示时间')
                  .fontSize(this.fontModel.getFg(16))
                  .height(21)
                  .width(191)
                Toggle({ type: ToggleType.Switch, isOn: this.userInfo.noTimeBattery })
                  .width(36)
                  .height(20)
                  .selectedColor($r('sys.color.comp_background_emphasize'))
                  .switchPointColor($r('sys.color.comp_background_primary_contrary'))
                  .onChange((isOn: boolean) => {
                    this.userInfo.noTimeBattery = isOn
                  })
              }
              .width(Constants.FULL_SIZE)
              .height(56)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width(Constants.FULL_SIZE)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .padding({
              left: 12,
              right: 12
            })
            .borderRadius(16)

            Row() {
              Text('自动购买下一章')
                .fontSize(this.fontModel.getFg(16))
                .height(21)
                .width(191)
              Toggle({ type: ToggleType.Switch, isOn: this.userInfo.continuousBuy })
                .width(36)
                .height(20)
                .selectedColor($r('sys.color.comp_background_emphasize'))
                .switchPointColor($r('sys.color.comp_background_primary_contrary'))
                .onChange((isOn: boolean) => {
                  this.userInfo.continuousBuy = isOn
                })
            }
            .settingStyle()
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('休息时间提醒')
                .fontSize(this.fontModel.getFg(16))
                .height(21)
                .width(191)
              Row({ space: 6.6 }) {
                Text(this.reminderTime === 0 ? '关闭' : this.reminderTime + '分钟')
                  .fontSize(this.fontModel.getFg(16))
                  .fontColor($r('sys.color.font_primary'))
                Image($r('app.media.ic_arrow_right'))
                  .width(7)
                  .height(14)
                  .objectFit(ImageFit.Contain)
              }
            }
            .settingStyle()
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              baseActionSheet.show({
                id: 'ReminderSheetBuilder',
                showClose: false,
                height: SheetSize.FIT_CONTENT,
                backgroundColor: $r('sys.color.background_primary'),
                customContent: () => {
                  this.ReminderSheetBuilder()
                },
              })
            })
          }
          .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : '100%')
          .padding({
            top: 12,
            left: 16,
            right: 16
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .height(Constants.FULL_SIZE)
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Styles
  settingStyle() {
    .width(Constants.FULL_SIZE)
    .height(61)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 12,
      top: 20,
      bottom: 20,
      right: 12
    })
  }

  @Builder
  ReminderSheetBuilder() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(fp2pxUtil(24))
            .fontColor([$r('sys.color.icon_primary')])
            .width(40)
            .height(40)
            .borderRadius(1000)
            .padding(8)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              baseActionSheet.close('ReminderSheetBuilder')
              this.optionTime = this.reminderTime
            })

          Text('休息时间提醒')
            .fontSize(this.fontModel.getFg(20))
            .fontWeight(FontWeight.Bold)
        }

        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(fp2pxUtil(24))
          .fontColor([$r('sys.color.icon_primary')])
          .width(40)
          .height(40)
          .borderRadius(1000)
          .padding(8)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            baseActionSheet.close('ReminderSheetBuilder')
            this.reminderTime = this.optionTime
            this.userInfo.reminderTime = this.optionTime
          })
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: 8,
        bottom: 8
      })

      this.SheetOptionView(45)
      this.SheetOptionView(90)
      this.SheetOptionView(120)
      this.SheetOptionView(0)
    }
    .width(Constants.FULL_SIZE)
    .padding({
      bottom: 40,
      left: 16,
      right: 16,
      top: 8
    })
    .backgroundColor($r('sys.color.background_tertiary'))
    .borderRadius(16)
  }

  @Builder
  SheetOptionView(tempTime: number) {
    Row({ space: 18 }) {
      Checkbox({ name: tempTime.toString(), group: 'reminderGroup', })
        .select(this.optionTime === tempTime)
        .height(20)
        .width(20)
        .selectedColor('#E84026')
        .shape(CheckBoxShape.CIRCLE)
        .onClick(() => {
          if (this.optionTime !== tempTime) {
            this.optionTime = tempTime
          }
        })

      Text(tempTime === 0 ? '关闭' : tempTime + '分钟')
        .fontSize(this.fontModel.getFg(16))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
    }
    .width(Constants.FULL_SIZE)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      if (this.optionTime !== tempTime) {
        this.optionTime = tempTime
      }
    })
  }
}


