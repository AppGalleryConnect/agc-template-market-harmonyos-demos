import { CustomTabsInfo } from '../model/Model';
import { getDataFromJSON } from '../utils/Utils';

/**
 * @usage: 用于自定义标签栏场景。提供标签切换功能，从JSON文件加载标签数据。
 * 关键数据结构：CustomTabsInfo（标签信息，包含name名称）、currentIndex（当前选中索引）、
 * rawSource（JSON文件路径字符串）、tabsInfos（标签信息数组）、tabIndexChange（标签切换回调函数，
 * 参数为索引）。包含if逻辑：根据currentIndex判断选中状态（选中显示红色文字和底部边框）。
 * @layout: 横向Flex布局，均分宽度。每个标签垂直布局（标签名称文字），选中标签显示红色文字和底部红色边框。
 * 整体带底部分割线。
 * @constraints: currentIndex当前索引必须有效，rawSource JSON文件路径不能为空且文件必须存在，
 * tabIndexChange回调函数必须正确处理标签切换
 * @isGen: true
 * @fileType: component
 * @zhName: 基础自定义标签栏组件
 */
@ComponentV2
export struct BaseCustomTabBar {
  @Require @Param currentIndex: number;
  @Require @Param rawSource: string = ''
  @Local tabsInfos: CustomTabsInfo[] = []
  @Event tabIndexChange: (index: number) => void = () => {
  }

  aboutToAppear(): void {
    this.tabsInfos = getDataFromJSON<CustomTabsInfo>(this.rawSource, this);
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceEvenly,
    }) {
      ForEach(this.tabsInfos, (item: CustomTabsInfo, index: number) => {
        Column() {
          Text(item.name)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.currentIndex === index ? '#C4272B' : $r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
        }
        .border({
          width: { bottom: this.currentIndex === index ? 2 : 0 },
          color: '#C4272B',
        })
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          this.tabIndexChange(index)
        })
      }, (item: CustomTabsInfo) => JSON.stringify(item))
    }
    .backgroundColor($r('sys.color.background_primary'))
    .border({
      width: { bottom: 1 },
      color: $r('sys.color.comp_divider'),
    })
    .margin({ top: 11})
  }
}
