import { RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { healthKnowledge } from '../constants/constants';
import { HealthModel } from '../viewmodel/HealthModel';
import { HealthKnowledgeDetailPageBuilder } from '../views/HealthKnowledgeDetailPage';
import { HealthKnowledgeListPageBuilder } from '../views/HealthKnowledgeListPage';

/**
 * @usage: 用于显示健康知识内容和导航。支持点击跳转到健康知识列表页面和详情页面。包含标题行和知识卡片展示区域。
 * @layout: 垂直布局（Column），顶部为标题行Row，包含标题和导航按钮。下方为知识卡片展示区域（Row），包含左右两个Stack堆叠容器，
 * 每个包含背景图片和文本内容。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 健康知识行组件
 * @fileType: component
 * @isGen: true
 * @subPage: HealthKnowledgeListPage，HealthKnowledgeDetailPage
 * @component:
 * @image: screenshot/health/HealthKnowledge.jpg
 */
@ComponentV2
export struct HealthKnowledgeRow {
  @Param @Require healthModelVM: HealthModel;

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.health_knowledge_title'))
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)

          Row() {
            Text($r('app.string.health_all_title'))
              .fontColor($r('app.color.color_999'))
              .fontSize($r('sys.float.Body_M'))
            Blank().width($r('app.float.vp_4'))
            Image($r('app.media.iconRight'))
              .width($r('app.float.vp_20'))
              .height($r('app.float.vp_20'))
          }
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HEALTH_KNOWLEDGE_LIST_PAGE,
              builder: wrapBuilder(HealthKnowledgeListPageBuilder)
            })
          })
        }
        .width('100%')
        .height($r('app.float.vp_28'))
        .justifyContent(FlexAlign.SpaceBetween)

        Blank().height($r('app.float.vp_4'))

        Row() {
          Stack() {
            Image($r('app.media.health_knowledge_left_bg'))
              .objectFit(ImageFit.Fill)
              .width('100%')
              .height('100%')

            Row() {
              Image($r('app.media.health_knowledge_left_icon'))
                .width($r('app.float.vp_22'))
                .height($r('app.float.vp_22'))

              Blank().width($r('app.float.vp_4'))
              Text($r('app.string.health_eat_name'))
                .fontColor(Color.White)
                .fontSize($r('sys.float.Body_M'))
            }
            .width('100%')
            .height('100%')
            .padding($r('app.float.vp_12'))
            .justifyContent(FlexAlign.Start)
          }
          .layoutWeight(1)
          .height('100%')
          .borderRadius($r('sys.float.corner_radius_level6'))
          .clip(true)
          .onClick(() => {
            let singleVMList = healthKnowledge;
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HEALTH_KNOWLEDGE_DETAIL_PAGE,
              builder: wrapBuilder(HealthKnowledgeDetailPageBuilder),
              param: singleVMList[0]
            })
          })

          Blank().width($r('app.float.vp_10'))

          Stack() {
            Image($r('app.media.health_knowledge_right_bg'))
              .objectFit(ImageFit.Fill)
              .width('100%')
              .height('100%')

            Row() {
              Image($r('app.media.health_knowledge_right_icon'))
                .width($r('app.float.vp_22'))
                .height($r('app.float.vp_22'))

              Blank().width($r('app.float.vp_4'))
              Text($r('app.string.health_intermittent_fasting'))
                .fontColor(Color.White)
                .fontSize($r('sys.float.Body_M'))
            }
            .padding($r('app.float.vp_12'))
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Start)
          }
          .layoutWeight(1)
          .height('100%')
          .borderRadius($r('sys.float.corner_radius_level6'))
          .clip(true)
          .onClick(() => {
            let singleVMList = healthKnowledge;
            phoneRouterControl.jumpPage({
              pageName: RouterMap.HEALTH_KNOWLEDGE_DETAIL_PAGE,
              builder: wrapBuilder(HealthKnowledgeDetailPageBuilder),
              param: singleVMList[2]
            })
          })
        }
        .width('100%')
        .height($r('app.float.vp_60'))
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .backgroundColor(Color.White)
      .height('100%')
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level7'))
      .padding($r('app.float.vp_16'))
      .clip(true)
    }
    .padding({
      left: $r('app.float.vp_12'),
    })
    .height($r('app.float.vp_122'))
    .width('200%')
  }
}