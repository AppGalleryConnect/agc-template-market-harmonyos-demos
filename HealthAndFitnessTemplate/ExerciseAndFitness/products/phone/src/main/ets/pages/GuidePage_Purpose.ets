import { BreakpointModel, BreakpointNameEnum, RouterMap, RouterUtils } from 'lib_common';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { GuidePageVM } from '../viewmodels/GuidePageVM';
import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

interface purposeInfo {
  desc: string,
  cover: ResourceStr,
}

@Builder
export function GuidePagePurposeBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Local clickedStates: boolean[] = [false, false, false, false, false]
  @Local purpose: string[] = []
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local imageWidth: string = '70%'

  purposeList: purposeInfo[] = [
    {
      desc: '增肌塑形',
      cover: $r('app.media.purpose1')
    },
    {
      desc: '减重瘦身',
      cover: $r('app.media.purpose2')
    },
    {
      desc: '保持健康',
      cover: $r('app.media.purpose3')
    },
    {
      desc: '增强身体',
      cover: $r('app.media.purpose4')
    },
    {
      desc: '随便练练',
      cover: $r('app.media.purpose5')
    }
  ]
  onNextButtonClick() {
    this.vm.savePurpose(this.getUIContext().getHostContext() as common.UIAbilityContext, this.purpose);
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Body)
  }

  @Builder
  contentBuilder() {
    List({ space: 2 }) {
      ForEach(this.purposeList, (purposeItem: purposeInfo, index: number) => {
        ListItem() {
          Column() {
            Stack() {
              Image(purposeItem.cover)
                .width(this.imageWidth)
                .height('12%')
                .borderRadius(16) // 可选：设置圆角
                .border({
                  width: {
                    left: 1,
                    right: 1,
                    top: 1,
                    bottom: 1
                  }, // 设置四边宽度
                  color: this.clickedStates[index] ? $r('app.color.app_theme') :
                    $r('sys.color.ohos_id_color_background')     // 动态颜色绑定
                })
              Column() {
                Text(purposeItem.desc)  // 主标题
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Bold)
                  .width(108)
                  .height(24)
                  .offset({
                    x: 72,
                    y: 0
                  })
                  .fontColor('rgba(237, 111, 33, 1)')
              }
            }
            .onClick(() => {
              this.clickedStates[index] = !this.clickedStates[index]
              if (this.purpose.includes(purposeItem.desc)) {
                const curIndex = this.purpose.findIndex(item => item === purposeItem.desc);
                this.purpose.splice(curIndex, 1);
              } else {
                this.purpose.push(purposeItem.desc);
              }
            })
            .width('100%')
          }
          .justifyContent(FlexAlign.Center)
          .margin({ top: 8 })
        }
        .width('100%')
      })
    }
    .lanes(this.listLanes)
    .width('100%')
    .margin({ top: 8 })
  }

  @Computed
  get listLanes() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      this.imageWidth = '70%'
      return 1;
    }
    this.imageWidth = '90%'
    return 2;
  }

  build() {
    CommonGuidePage({
      guideTitle: '您想锻炼的目的？',
      guideDesc: '信息仅用于制定更好的训练计划，我们将会严格加密！',
      isShowNextButton: true,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.onNextButtonClick(),
      onSkipButtonClick: this.vm.skipBtnClick
    })
  }
}
