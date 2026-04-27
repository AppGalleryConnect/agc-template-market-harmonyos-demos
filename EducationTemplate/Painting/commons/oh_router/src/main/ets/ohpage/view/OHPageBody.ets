import { OHPageConfig } from '../config/OHPageConfig';

const TAG = 'OHPageBody: '

@ComponentV2
export struct OHPageBody {
  @Param @Require pageConfig: OHPageConfig
  /** 自定义Builder */
  @BuilderParam childBuilder: (pageId?: string) => void = this.defaultBuilder

  @Builder
  defaultBuilder(pageId?: string) {
    // 兜底布局
    Text('无内容页面')
  }

  aboutToAppear(): void {
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.childBuilder()
      }.width('100%')
      .constraintSize({
        minWidth: '100%'
      })
    }
    .width('100%')
    .height('100%')
    .constraintSize({
      minHeight: '100%',
      minWidth: '100%'
    })
    .backgroundColor(Color.Transparent)
  }
}