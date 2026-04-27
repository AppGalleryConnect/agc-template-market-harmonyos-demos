import { BreakpointModel, CommonHeader, RouterMap, BarVM } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { healthKnowledge } from '../constants/constants';
import { HealthKnowledgeSingleModel } from '../viewmodel/HealthKnowledgeSingleModel';
import { HealthKnowledgeSingleRow } from '../comp/HealthKnowledgeSingleRow';
import { HealthKnowledgeDetailPageBuilder } from './HealthKnowledgeDetailPage';
import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointNameEnum } from 'common/src/main/ets/constant/GridRowColSetting';

@Builder
export function HealthKnowledgeListPageBuilder() {
  HealthKnowledgeListPage()
}

/**
 * @usage: 健康知识列表页面，用于展示健康知识文章列表，提供健康知识的浏览和选择功能，
 * 主要数据结构为HealthKnowledgeSingleModel数组（健康知识列表模型）
 * @layout: 垂直布局，顶部为CommonHeader导航栏，下方为健康知识列表，使用List组件展示多个HealthKnowledgeSingleRow行组件
 * @constraints:
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 健康知识列表页面
 * @subPage: HealthKnowledgeDetailPage
 * @component: CommonHeader,HealthKnowledgeSingleRow
 * @image: screenshot/health/HealthKnowledgeList.jpg
 */
@ComponentV2
export struct HealthKnowledgeListPage {
  @Local knowledgeSingleModelVM: HealthKnowledgeSingleModel[] = healthKnowledge;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.health_knowledge_list_title'),
        onReturnClick: this.onReturnClick,
        leftImageRes: $r('app.media.ic_backward2')
      })

      List({ space: 12 }) {
        ForEach(this.knowledgeSingleModelVM, (item: HealthKnowledgeSingleModel,
          _index: number) => {
          ListItem() {
            HealthKnowledgeSingleRow({
              knowledgeSingleModelVM: item
            })
              .onClick(() => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.HEALTH_KNOWLEDGE_DETAIL_PAGE,
                  builder: wrapBuilder(HealthKnowledgeDetailPageBuilder),
                  param: item
                })
              })
          }
        }, (item: HealthKnowledgeSingleModel, index: number) => `${item.title}_${index}}`)

        ListItem().height(px2vp(BarVM.instance.aiBarH))
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .lanes(this.getFoldShow ? 2 : 1, $r('app.float.vp_12'))
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#FFF1F3F5')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }

  @Computed
  get getFoldShow(): boolean {
    if (this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      return false;
    } else {
      return true;
    }
  }
}

