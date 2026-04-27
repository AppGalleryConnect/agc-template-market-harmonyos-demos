import { CommonHeader, TValueType, BarVM } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { HealthKnowledgeSingleModel } from '../viewmodel/HealthKnowledgeSingleModel';

@Builder
export function HealthKnowledgeDetailPageBuilder(value: TValueType) {
  HealthKnowledgeDetailPage({
    value: value
  })
}

/**
 * @usage： 健康知识详情页面，用于展示健康知识的详细内容，包括标题、图片、详细描述等信息，
 * 主要数据结构为HealthKnowledgeSingleModel（健康知识单项模型）
 * @layout： 垂直布局，顶部为CommonHeader导航栏，下方为内容区域，包含图片展示和文本描述的列表布局
 * @constraints：
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 健康知识详情页面
 * @image: screenshot/health/HealthKnowledgeDetail.jpg
 */
@ComponentV2
export struct HealthKnowledgeDetailPage {
  @Param @Require value: TValueType;
  @Local vm?: HealthKnowledgeSingleModel;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  aboutToAppear(): void {
    this.vm = this.value as HealthKnowledgeSingleModel;
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: (!this.vm || this.vm?.title.length > 0) ? this.vm?.title : $r('app.string.health_knowledge_list_title'),
        onReturnClick: this.onReturnClick,
        leftImageRes: $r('app.media.ic_backward2')
      })

      Column() {
        List({ space: 12 }) {
          ListItem() {
            Image($r('app.media.health_knowledge_fast_icon'))
              .objectFit(ImageFit.Fill)
              .width('100%')
              .height($r('app.float.vp_90'))
              .borderRadius($r('sys.float.corner_radius_level8'))
              .clip(true)
          }

          ListItemGroup() {
            ListItem() {
              Text(this.vm?.title)
                .fontColor('#FF352200')
                .fontSize($r('sys.float.Body_L'))
                .lineHeight($r('app.float.vp_22'))
            }

            ListItem() {
              Text(this.vm?.content)
                .fontColor($r('sys.color.mask_secondary'))
                .fontSize($r('sys.float.Body_M'))
                .lineHeight($r('app.float.vp_24'))
                .maxLines(-1)
            }
          }
          .backgroundColor(Color.White)
          .width('100%')
          .borderRadius($r('sys.float.corner_radius_level7'))
          .padding($r('app.float.vp_12'))
          .clip(true)

          ListItem().height(px2vp(BarVM.instance.aiBarH))
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('app.color.color_F1F3F5'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }
}


