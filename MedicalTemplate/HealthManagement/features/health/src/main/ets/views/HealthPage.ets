import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { BreakpointModel, CommonHeader, Constants, RouterMap } from 'common';
import { HealthCardRow } from '../comp/HealthCardRow';
import { HealthRunningRow } from '../comp/HealthRunningRow';
import { HealthModel } from '../viewmodel/HealthModel';
import { HealthCardModel } from '../viewmodel/HealthCardModel';
import { HealthKnowledgeRow } from '../comp/HealthKnowledgeRow';
import { phoneRouterControl } from 'oh_router';
import { MessageCenterPageBuilder } from 'person';
import { HealthRunningFoldRow } from '../comp/HealthRunningFoldRow';

@Builder
export function HealthPageBuilder() {
  HealthPage()
}

/**
 * @usage: 用于展示健康应用的首页。导航栏（CommonHeader）包括模块名称和右侧的消息中心入口，下方是运动组件(包含if逻辑，根据设备情况提供
 * 不同的运动组件样式)，健康卡片组件，健康知识展示组件。
 * @layout: 页面采用Stack布局,底层采用垂直布局（Column）实现渐变色背景，上层的顶部为CommonHeader导航栏，
 * 下方使用列表（List）展示健康卡片。包含运动数据区域（item）、和由健康卡片列表、底部健康知识组件的列表item分组。
 * @constraints: 如果用户需求不需要消息中心入口，可以在CommonHeader组件中不提供图标(rightImageRes)和跳转逻辑(rightOnClick)
 * @domain: 健康医疗
 * @zhName: 健康主页面
 * @fileType: page
 * @isGen: true
 * @subPage: MessageCenterPage
 * @component: HealthCardRow,HealthRunningRow,HealthKnowledgeRow,HealthRunningFoldRow
 * @image: screenshot/health.jpg
 */
@ComponentV2
export struct HealthPage {
  healthModelVM: HealthModel = HealthModel.instance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local onReturnClick: () => void = () => {
  }
  @Local onRightClick: () => void = () => {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MESSAGE_CENTER_PAGE,
      builder: wrapBuilder(MessageCenterPageBuilder)
    })
  }

  @Local onHealthDataChange: () => void = () => {
    this.healthModelVM.initDeviceData();
    this.healthModelVM.initHealthData();
  }

  aboutToAppear(): void {
    try {
      emitter.on(Constants.onHealthDataChange, this.onHealthDataChange);
    } catch (err) {
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off(Constants.onHealthDataChange.eventId, this.onHealthDataChange);
    } catch (err) {
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .alignItems(HorizontalAlign.Start)
        .height($r('app.float.vp_327'))
        .width('100%')
        .linearGradient({
          angle: 180,
          colors: [['#524792F3', 0.0], ['#00F1F3F5', 1.0]]
        })

      Column() {
        CommonHeader({
          title: $r('app.string.health_module_name'),
          onReturnClick: this.onReturnClick,
          backgroundColorParam: Color.Transparent,
          rightImageRes: $r('app.media.health_message'),
          rowFlexAlign: FlexAlign.SpaceBetween,
          rightOnClick: this.onRightClick
        })
          .padding({
            left: this.breakPointModel.pagePadding,
            right: this.breakPointModel.pagePadding
          })

        Column() {
          List() {
            ListItem() {
              Column() {
                Row() {
                  Blank().layoutWeight(1)

                  Stack() {
                    Progress({
                      value: this.healthModelVM.activityHeat / 2,
                      total: this.healthModelVM.standardActivityHeat,
                      type: ProgressType.Ring
                    })
                      .width($r('app.float.vp_216'))
                      .height($r('app.float.vp_216'))
                      .color($r('app.color.color_ED6F21'))
                      .style({ strokeWidth: $r('app.float.vp_26') })
                      .rotate({ angle: -90 })

                    Progress({
                      value: this.healthModelVM.exerciseDuration / 2,
                      total: this.healthModelVM.standardExerciseDuration,
                      type: ProgressType.Ring
                    })
                      .width($r('app.float.vp_150'))
                      .height($r('app.float.vp_150'))
                      .color($r('app.color.color_F9A01E'))
                      .style({ strokeWidth: $r('app.float.vp_26') })
                      .rotate({ angle: -90 })

                    Progress({
                      value: this.healthModelVM.travelDistance / 2,
                      total: this.healthModelVM.standardTravelDistance,
                      type: ProgressType.Ring
                    })
                      .width($r('app.float.vp_84'))
                      .height($r('app.float.vp_84'))
                      .color($r('app.color.color_46B1E3'))
                      .style({ strokeWidth: $r('app.float.vp_26') })
                      .rotate({ angle: -90 })
                  }
                  .width($r('app.float.vp_216'))
                  .height($r('app.float.vp_216'))

                  Blank().layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)
                .width('100%')
                .height($r('app.float.vp_108'))
                .clip(true)

                if (this.healthModelVM.getFoldShow) {
                  HealthRunningFoldRow({ healthModelVM: this.healthModelVM });
                } else {
                  HealthRunningRow({ healthModelVM: this.healthModelVM });
                }

                Blank().height($r('app.float.vp_12'))
              }
              .height(this.healthModelVM.getFoldShow ? $r('app.float.vp_216') : $r('app.float.vp_240'))
              .width(this.healthModelVM.getFoldShow ? '400%' : '200%')
              .padding({
                left: $r('app.float.vp_12')
              })
            }

            ListItemGroup({
              space: 12
            }) {
              ForEach(this.healthModelVM.cardList, (item: HealthCardModel, _index: number) => {
                ListItem() {
                  if (item.type === 1) {
                    HealthCardRow({ healthCardModelVM: this.healthModelVM.dataVM })
                  } else if (item.type === 2) {
                    HealthCardRow({ healthCardModelVM: this.healthModelVM.reportVM })
                  } else if (item.type === 3) {
                    HealthCardRow({ healthCardModelVM: this.healthModelVM.sleepVM })
                  } else if (item.type === 4) {
                    HealthCardRow({ healthCardModelVM: this.healthModelVM.bloodPreVM })
                  } else if (item.type === 5) {
                    HealthCardRow({ healthCardModelVM: this.healthModelVM.heartRateVM })
                  } else if (item.type === 6) {
                    HealthCardRow({ healthCardModelVM: this.healthModelVM.bloodSugarVM })
                  }
                }
              }, (item: HealthCardModel, index: number) => `${item.title}_${index}}`)

              ListItem() {
                HealthKnowledgeRow({ healthModelVM: this.healthModelVM })
              }
            }
          }
          .height('100%')
          .width('100%')
          .lanes(this.healthModelVM.getFoldShow ? 4 : 2)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .layoutWeight(1)
        .width('100%')
        .padding({
          left: this.breakPointModel.pagePadding - 12,
          right: this.breakPointModel.pagePadding
        })
      }
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}

