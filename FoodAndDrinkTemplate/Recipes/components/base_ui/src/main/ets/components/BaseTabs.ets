import { BreakpointModel } from '../models/BreakpointModel';
import { TabIndexEnum } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointType } from '../models/GridRowColSetting';

@ComponentV2
export struct BaseTabs {
  @Param tabsTitle: ResourceStr[] = ['全部用料', '菜谱用料'];
  @Param currentIndex: number = 1;
  @Param mineWidth: number = 0;
  @Event changeTabs: (index: number) => void = () => {
  };
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 0,
    md: 448,
    lg: 448,
    xl: 448,
  });

  @Computed
  get tabWidth() {
    if(this.mineWidth) {
      return this.mineWidth;
    }
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  build() {
    Row() {
      Text(this.tabsTitle[0])
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === TabIndexEnum.FIRST ? $r('sys.color.font_primary') :
          $r('sys.color.font_secondary'))
        .backgroundColor(this.currentIndex === TabIndexEnum.FIRST ?
          $r('sys.color.comp_background_primary_contrary_secondary') :
          Color.Transparent)
        .borderRadius(18)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 8 })
        .height(38)
        .onClick(() => {
          this.changeTabs(TabIndexEnum.FIRST);
        });
      Text(this.tabsTitle[1])
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === TabIndexEnum.SECOND ? $r('sys.color.font_primary') :
          $r('sys.color.font_secondary'))
        .backgroundColor(this.currentIndex === TabIndexEnum.SECOND ?
          $r('sys.color.comp_background_primary_contrary_secondary') :
          Color.Transparent)
        .borderRadius(18)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 8 })
        .height(38)
        .onClick(() => {
          this.changeTabs(TabIndexEnum.SECOND);
        });
    }
    .height(40)
    .width(this.tabWidth === 0 ? '100%' : this.tabWidth)
    .padding(2)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(20);
  }
}
