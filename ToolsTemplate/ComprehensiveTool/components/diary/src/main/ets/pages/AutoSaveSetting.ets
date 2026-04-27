import { PersistenceV2 } from '@kit.ArkUI';
import { DiaryExtraInfo } from '../models/Diary';
import { DiaryUtil } from '../utils/DiaryUtil';
import { PopViewUtils } from '../utils/PopViewUtils';

@Builder
export function AutoSaveSettingBuilder() {
  AutoSaveSetting()
}


@ComponentV2
export struct AutoSaveSetting {
  diaryUtil: DiaryUtil = DiaryUtil.instance;
  pathStack: NavPathStack = new NavPathStack();

  @Local time: string = '';
  @Local showAutoSaveTip: boolean = true;
  @Local diaryExtraInfo: DiaryExtraInfo = PersistenceV2.connect(DiaryExtraInfo, () => new DiaryExtraInfo())!;

  aboutToAppear(): void {
    this.time = this.diaryExtraInfo.autoSaveTime.toString();
    this.showAutoSaveTip = this.diaryExtraInfo.showAutoSaveTip;
  }
  // 打开设置自动保存日记时间的弹框
  openSettingAutoSaveTimeDialog() {
    let builderParams: AutoSaveTimeBuilderParams = {
      time: this.time,
      confirm: (time: number) => {
        this.time = time.toString();
        this.diaryExtraInfo.autoSaveTime = time
        PopViewUtils.closePopView();
      },
      cancel: () => {
        PopViewUtils.closePopView()
      }
    }
    PopViewUtils.showPopView<AutoSaveTimeBuilderParams>(wrapBuilder(autoSaveTimeDialogBuilder), {
      autoCancel: false,
      alignment: DialogAlignment.Center,
    }, builderParams)
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 13 }) {
          CardItem({
            label: '自动保存时间',
            rightBuilder: () => {
              this.autoSaveTime();
            }
          })

          Row().width('100%').height(0.5).backgroundColor($r('sys.color.comp_divider'))

          CardItem({
            label: '自动保存提醒',
            rightBuilder: () => {
              this.autoSaveSwitch();
            }
          })
        }
        .width('100%')
        .borderRadius(16)
        .padding({
          left: 12,
          right: 12,
          top: 16,
          bottom: 16
        })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .width('100%')
      .padding(16)
    }
    .title('设置自动保存')
    .onReady((cxt)=> {
      this.pathStack = cxt.pathStack;
    })
  }

  @Builder
  autoSaveTime() {
    Row({ space: 6 }) {
      Text(this.time + 'S')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(19)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontColor([$r('sys.color.icon_fourth')])
        .fontSize(20)
    }
    .onClick(() => {
      this.openSettingAutoSaveTimeDialog()
    })
  }

  @Builder
  autoSaveSwitch() {
    Toggle({ type: ToggleType.Switch, isOn: !!this.showAutoSaveTip })
      .selectedColor($r('sys.color.comp_background_emphasize'))
      .onChange((isOn: boolean) => {
        this.diaryExtraInfo.showAutoSaveTip = isOn
      })
  }
}



@ComponentV2
struct CardItem {
  @Param label: string = ''
  @BuilderParam rightBuilder: CustomBuilder

  build() {
    Row() {
      Text(this.label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .lineHeight(21)
        .fontColor($r('sys.color.font_primary'))

      if (this.rightBuilder) {
        this.rightBuilder()
      }

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}


interface AutoSaveTimeBuilderParams {
  time: string
  confirm: (time: number) => void
  cancel: () => void
}

@Builder
function autoSaveTimeDialogBuilder(params: AutoSaveTimeBuilderParams) {
  SettingAutoSaveTimeDialog({
    time: params.time,
    confirm: params.confirm,
    cancel: params.cancel
  })
}

@ComponentV2
struct SettingAutoSaveTimeDialog {
  @Param time: string = ''
  @Event confirm: (time: number) => void = (time: number) => {}
  @Event cancel: () => void = () => {}

  @Local value: string | string[] = '';
  private times: string[] = ['10', '15', '30', '35', '40'];

  aboutToAppear(): void {
    this.value = this.time;
  }

  build() {
    Column() {
      Column({ space: 12 }) {
        Text(this.value.toString() + 'S')
          .fontSize(20)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .lineHeight(27)
          .margin({ top: 16 })

        TextPicker({ range: this.times, value: this.value })
          .onChange((value: string | string[]) => {
            this.value = value as string
          })
          .disappearTextStyle({
            font: { size: 14, weight: FontWeight.Regular },
          })
          .textStyle({
            color: $r('sys.color.font_primary'),
            font: { size: 16, weight: FontWeight.Regular },
          })
          .selectedTextStyle({
            color: $r('app.color.diary_primary_color'),
            font: {
              size: 20,
              weight: FontWeight.Medium,
            },
          })
          .canLoop(false)
          .width('45%')

        Flex({ alignItems: ItemAlign.Center }) {
          Button('取消', { buttonStyle: ButtonStyleMode.TEXTUAL })
            .fontColor($r('sys.color.font_primary'))
            .width('100%')
            .onClick(() => {
              this.cancel?.()
            })

          Divider().strokeWidth(1).height(24).color('#0d000000').vertical(true)

          Button('确认', { buttonStyle: ButtonStyleMode.TEXTUAL })
            .fontColor($r('app.color.diary_primary_color'))
            .width('100%')
            .onClick(() => {
              let time = this.value as string;
              this.confirm?.(Number(time))
            })
        }
        .margin({ top: 8, bottom: 24 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(32)
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .padding(16)
  }
}