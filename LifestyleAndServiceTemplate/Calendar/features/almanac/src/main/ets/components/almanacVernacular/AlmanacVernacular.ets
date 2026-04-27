import { BaseCell } from 'base_apis'
import { YiJiSetDate } from './Model'
import { convertToEmperorEra, fullDateTransfer } from './utils/Utils'

@ComponentV2
export struct AlmanacVernacular {
  /**
   * 选择时间
   */
  @Param selectTime: string = ''
  /**
   * 今日宜
   */
  @Param yiToday: YiJiSetDate[] = []
  /**
   * 今日忌
   */
  @Param jiToday: YiJiSetDate[] = []
  /**
   * 背景颜色
   */
  @Param bgColor: ResourceStr = $r('sys.color.background_primary')
  /**
   * 皇帝纪元
   */
  @Local emperorYear: number = 0

  @Local localTime:string = ''

  @Builder
  cellTitle(title: string) {
    Row({ space: 5 }) {
      Image($r('app.media.classifieds')).width(16).height(16)
      Text(title)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_L'))
    }
    .margin({ bottom: 16 })
  }

  aboutToAppear(): void {
    this.emperorYear = convertToEmperorEra(this.selectTime)
    this.localTime = fullDateTransfer(this.selectTime)
  }

  @Builder
  yellowEmperorBuilder() {
    Column({ space: 8 }) {
      Text(`公元${this.localTime}=黄帝纪元${this.emperorYear}年`)
        .fontWeight(FontWeight.Regular)
        .fontColor('#966426')
        .fontSize($r('sys.float.Subtitle_S'))
      Text('黄帝纪年是根据黄帝历和天干地支，以及帝王世系推算的华夏人文初祖黄帝即位，以及创制历法的时开始纪年。' +
        '公元前2697年是干支纪年的开始、华夏是最早创制历法的三大民族之一。' +
        '黄帝纪年影响深远，农历、道教历法均始于黄帝纪年为元年，为中传统历法开始之年史开元。')
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Subtitle_S'))
        .lineHeight(23)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  yiJiDetailsBuilder(list: YiJiSetDate[], type: string) {
    Column({ space: 16 }) {
      ForEach(list, (item: YiJiSetDate) => {
        Column({ space: 8 }) {
          Text(item.name)
            .fontWeight(FontWeight.Medium)
            .fontColor(type === 'yi' ? '#C4272B' : $r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
          Text(item.des)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Subtitle_S'))
            .lineHeight(23)
        }
        .alignItems(HorizontalAlign.Start)
      },(item: YiJiSetDate) => JSON.stringify(item))
    }
  }

  @Builder
  yiJiListBuilder() {
    Column({ space: 16 }) {
      Column({ space: 16 }) {
        Image($r('app.media.yi')).width(24).height(24)
        this.yiJiDetailsBuilder(this.yiToday, 'yi')
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 16 }) {
        Image($r('app.media.ji')).width(24).height(24)
        this.yiJiDetailsBuilder(this.jiToday, 'ji')
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  yellowEmperorEra() {
    BaseCell({
      bgColor: this.bgColor,
      leftTextBuilderParam: () => this.cellTitle('黄帝纪元'),
      customBuilderParam: () => this.yellowEmperorBuilder(),
    })
  }

  @Builder
  yiJiDetails() {
    BaseCell({
      bgColor: this.bgColor,
      leftTextBuilderParam: () => this.cellTitle('宜忌'),
      customBuilderParam: () => this.yiJiListBuilder(),
    })
  }

  build() {
    List() {
      ListItem() {
        this.yellowEmperorEra()
      }

      ListItem() {
        this.yiJiDetails()
      }
    }
    .layoutWeight(1)
    .padding({ bottom: '30%' })
    .scrollBar(BarState.Off)
  }
}
