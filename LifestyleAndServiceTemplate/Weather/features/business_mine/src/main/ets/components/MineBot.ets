import { AppStorageV2 } from '@kit.ArkUI';
import { BaseTextStyleModifier, CommonConstants, RouterMap, RouterModule } from 'lib_foundation';
import { BreakpointModel } from 'module_weather_core';

@ComponentV2
export struct MineBot {
  @Local breakpointModel: BreakpointModel =
    AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get listLanes(): number {
    return this.breakpointModel.isLargeWindow ? 2 : 1;
  }

  build() {
    Column({ space: CommonConstants.SPACE_8 }) {
      Text('常用服务')
        .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_L/Bold'))
        .width(CommonConstants.FULL_PERCENT)

      List() {
        this.itemBuilder($r('app.media.mark'), '生活指数', RouterMap.INDICES, true)
        this.itemBuilder($r('app.media.mic'), '播报语音包', RouterMap.VOICE_BROADCAST)
        this.itemBuilder($r('app.media.setting'), '设置', RouterMap.SETTING)
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('sys.color.comp_divider'),
        startMargin: 40,
        endMargin: 0,
      })
      .lanes(this.listLanes, 0)
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding(12)
  }

  @Builder
  itemBuilder(pic: ResourceStr, label: string, url: string, special: boolean = false) {
    ListItem() {
      Row() {
        if (special) {
          Row() {
            Image(pic).width(17).fillColor($r('sys.color.icon_secondary'))
          }.width(24).height(24).justifyContent(FlexAlign.Center)
        } else {
          Image(pic).width(24).aspectRatio(1).fillColor($r('sys.color.icon_secondary'))
        }
        Text(label)
          .layoutWeight(1)
          .margin({ left: CommonConstants.SPACE_16 })
          .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium'))
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize($r('app.float.normal_img_size'))
          .fontColor([$r('sys.color.font_fourth')])
      }
    }
    .height(56)
    .padding({ right: this.listLanes === 2 ? CommonConstants.SPACE_8 : 0 })
    .onClick(() => {
      RouterModule.push({ url: url });
    })
  }
}
