import { CommonHeader, BarVM } from 'common';
import { ArticleCard, CardData } from 'message_manager';
import { OHPage, phoneRouterControl } from 'oh_router';
import { getMsgData } from '../constants/Constants';

/**
 * @usage: 用于展示系统消息、通知公告、活动推送等信息的消息中心页面，提供消息列表展示和详情查看功能。
 * 主要数据结构包括CardData（消息卡片数据）。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，下方为消息列表区域。消息列表使用List组件垂直排列，
 * 每个消息项使用ArticleCard组件展示。
 * @constraints:
 * @domain: 健康医疗
 * @zhName: 消息中心页面
 * @fileType: page
 * @isGen: true
 * @subPage:
 * @component: OHPage,ArticleCard,CommonHeader
 * @image: screenshot/health/MessageCenter.jpg
 */
@ComponentV2
export struct MyMessage {
  cardList: CardData[] = getMsgData()
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  // 页面内容渲染
  @Builder
  render() {
    CommonHeader({
      title: $r('app.string.person_message_title'),
      onReturnClick: () => {
        phoneRouterControl.popPage();
      },
      leftImageRes: $r('app.media.ic_backward2')
    })

    Column() {
      List({ space: 12 }) {
        ForEach(this.cardList, (item: CardData) => {
          ArticleCard({
            cardStyle: {
              maxLines: -1
            },
            cardData: item,
            itemClick: () => {
            }
          })
        }, (item: CardData) => JSON.stringify(item))

        ListItem().height(px2vp(BarVM.instance.aiBarH))
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .layoutWeight(1)
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

@Builder
export function MessageCenterPageBuilder(): void {
  MyMessage()
}