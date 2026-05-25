import { RouterMap, RouterUtils } from 'lib_common';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { GuidePageVM } from '../viewmodels/GuidePageVM';

@Builder
export function GuidePageInjuryBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Local clickedStates: boolean[] = [false, false, false, false, false, false]
  @Local selectedValue: string = '' // 记录选中值
  injuryList: string[] = ['手腕', '膝盖', '脚踝', '背部', '颈椎', '腰部']

  onNextButtonClick() {
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Sports)
  }

  @Builder
  contentBuilder() {
    Column() {
      Text('是否存在伤病困扰？')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({
          top: 40,
          bottom: 21,
        })
      Row() {
        // 是按钮
        Radio({
          group: 'Group',
          value: 'yes'
        })
          .radioStyle({
            checkedBackgroundColor: $r('app.color.app_theme')
          })
          .checked(this.selectedValue === 'yes')
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectedValue = 'yes'
            }
          })
        Text('是')
          .margin({ left: 12, right: 64 })

        // 否按钮
        Radio({
          group: 'Group',
          value: 'no'
        })
          .radioStyle({
            checkedBackgroundColor: $r('app.color.app_theme')
          })
          .checked(this.selectedValue === 'no')
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectedValue = 'no'
            }
          })
        Text('否')
          .margin({ left: 12 })
      }

      Column() {
        // 当选择"是"时显示的内容
        Text('选择受伤部位')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .margin({
            top: 40,
            bottom: 24,
          })
        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.injuryList, (item: string, index) => {
              Button(item)
                .width('32%')
                .height(28)
                .margin({ bottom: 12 })
                .fontSize($r('sys.float.Body_M'))
                .fontColor(this.clickedStates[index] ? $r('sys.color.font_on_primary') : 'rgba(0, 0, 0, 0.9)')
                .borderRadius(14)
                .backgroundColor(this.clickedStates[index] ? $r('app.color.app_theme') : $r('sys.color.comp_background_tertiary'))
                .onClick(() => {
                  this.clickedStates[index] = !this.clickedStates[index]
                })
            })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .visibility(this.selectedValue === 'yes' ? Visibility.Visible : Visibility.Hidden)
    }
    .alignItems(HorizontalAlign.Start)
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
