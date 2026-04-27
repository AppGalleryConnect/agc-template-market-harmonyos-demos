import { TabIndexEnum } from '../model/Index';

@ComponentV2
export struct BaseTabs {
  @Param tabsTitle: ResourceStr[] = ['全部用料', '菜谱用料'];
  @Param currentIndex: number = 1;
  @Event changeTabs: (index: number) => void = () => {
  };

  build() {
    Row() {
      Text(this.tabsTitle[0])
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === TabIndexEnum.FIRST ? $r('sys.color.font_primary') :
        $r('sys.color.font_secondary'))
        .backgroundColor(this.currentIndex === TabIndexEnum.FIRST ? $r('sys.color.background_primary') :
          '#00000000')
        .borderRadius(18)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          this.changeTabs(TabIndexEnum.FIRST);
        });
      Text(this.tabsTitle[1])
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === TabIndexEnum.SECOND ? $r('sys.color.font_primary') :
        $r('sys.color.font_secondary'))
        .backgroundColor(this.currentIndex === TabIndexEnum.SECOND ? $r('sys.color.background_primary') :
          '#00000000')
        .borderRadius(18)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          this.changeTabs(TabIndexEnum.SECOND);
        });
    }
    .padding(2)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius(20);
  }
}
