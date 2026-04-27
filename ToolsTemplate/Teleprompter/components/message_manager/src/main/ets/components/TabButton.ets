import { TabButtonData } from '../model/model';
import { TabController } from '../model/TabController';

@ComponentV2
export struct TabButton {
  @Param isActive: boolean = false;
  @Param tabController: TabController = new TabController('消息推送')
  @Param tabButtonData: TabButtonData = {
    activeBgColor:'#376BFC',
    defaultBgColor: 'rgba(0,0,0,0.05)',
    defaultFontColor: 'rgba(0,0,0,0.9)',
    activeFontColor: '#fff'
  }
  @Event statusChange:(status:boolean) => void = (status: boolean) => {};
  build() {
    RelativeContainer() {
      Button(this.tabController.tabName)
        .height('100%')
        .backgroundColor(this.isActive?this.tabButtonData.activeBgColor:this.tabButtonData.defaultBgColor)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.isActive?this.tabButtonData.activeFontColor:this.tabButtonData.defaultFontColor)
        .padding({
          left:8,
          right:8
        })
        .id('button')
        .onClick(() => {
          this.statusChange(!this.isActive);
        })

      if (this.tabController.unReadCount) {
        Text()
          .width(6)
          .height(6)
          .borderRadius('50%')
          .backgroundColor('#E84026')
          .alignRules({
            top: { anchor: 'button', align: VerticalAlign.Top },
            right:{anchor:'button', align: HorizontalAlign.End}
          })
      }

    }
    .height(27)
    .width('auto')
  }
}