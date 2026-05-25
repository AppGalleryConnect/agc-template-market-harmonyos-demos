import { RouterMap, RouterUtils } from 'lib_common';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { GuidePageVM } from '../viewmodels/GuidePageVM';

@Builder
export function GuidePageSportsBuilder() {
  GuidePage()
}

@ComponentV2
export struct CustomButton {
  @Param label: string = ''    // 按钮文本
  @Param btnWidth: string = '32%'
  @Param private themeColor: Resource = $r('app.color.app_theme')  // 主题色
  @Param private backColor: Resource = $r('sys.color.comp_background_tertiary')
  @Param private foreColor: string = 'rgba(0, 0, 0, 0.9)'
  @Param selected: boolean = false

  build() {
    Button(this.label)
      .width(this.btnWidth)
      .height(28)
      .margin({ bottom: 12 })
      .fontSize($r('sys.float.Body_S'))
      .borderRadius(14)
      .fontColor(this.selected ? Color.White : this.foreColor)
      .backgroundColor(this.selected ? this.themeColor : this.backColor)
  }
}

@ComponentV2
export struct CustomButton1 {
  @Local isOn: boolean = false  // 独立状态存储
  @Param label: string = ''    // 按钮文本
  @Param btnWidth: string = '32%'
  @Param private themeColor: Resource = $r('app.color.app_theme')  // 主题色
  @Param private backColor: Resource = $r('sys.color.comp_background_tertiary')
  @Param private foreColor: string = 'rgba(0, 0, 0, 0.9)'

  build() {
    Button(this.label)
      .width(this.btnWidth)
      .height(28)
      .margin({ bottom: 12 })
      .fontSize($r('sys.float.Body_S'))
      .borderRadius(14)
      .fontColor(this.isOn ? Color.White : this.foreColor)
      .backgroundColor(this.isOn ? this.themeColor : this.backColor)
      .onClick(() => {
        this.isOn = !this.isOn  // 状态自动切换
      })
  }
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Local selectedFrequency: string = '';
  sportList: string[] = ['跑步', '跳绳', '游泳', '瑜伽', '器械', '爬楼']
  frequencyList: string[] = ['一周1次', '一周2~3次', '一周3次以上']
  difficultLevel: string[] = ['零基础', '初级', '中级', '高级']
  onNextButtonClick() {
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Start)
  }

  @Builder
  contentBuilder() {
    Column() {
      Text('您喜欢的运动类型')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .margin({
          top: 40,
          bottom: 24,
        })

      Column() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.sportList, (item: string) => {
            CustomButton1({ label: item })
          })
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    Column() {
      Text('您的运动频次')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .margin({
          top: 40,
          bottom: 24,
        })

      Column() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.frequencyList, (item: string) => {
            CustomButton({ label: item, selected: this.selectedFrequency === item })
              .onClick(() => {
                this.selectedFrequency = item
              })
          })
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')

    Column() {
      Text('期望练习难度')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .margin({
          top: 40,
          bottom: 24,
        })

      Column() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.difficultLevel, (item: string) => {
            CustomButton1({ label: item, btnWidth: '23%' })
          })
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  build() {
    CommonGuidePage({
      guideTitle: '关于您',
      guideDesc: '选择目标部位，获得更精确的课程推荐！',
      isShowNextButton: true,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.onNextButtonClick(),
      onSkipButtonClick: this.vm.skipBtnClick
    })
  }
}
