/**
 * 健康历史记录页面
 */
import { phoneRouterControl } from 'oh_router';
import { HealthHistoryModel } from '../viewmodel/HealthHistoryModel';
import { HealthHistoryItem } from '../types/HealthHistoryTypes';
import { RouterMap, UnitConverter, BarVM } from 'common';
import { HealthHistoryDetailPageBuilder } from './HealthHistoryDetailPage';

@Builder
export function HealthHistoryPageBuilder() {
  HealthHistoryPage()
}

@ComponentV2
export struct HealthHistoryPage {
  private vm: HealthHistoryModel = HealthHistoryModel.instance;
  handleBack = (): void => {
    phoneRouterControl.popPage();
  }
  handleMonthClick = (): void => {
    this.vm.toggleMonthPicker();
  }
  handleItemClick = (item: HealthHistoryItem): void => {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.HEALTH_HISTORY_DETAIL_PAGE,
      builder: wrapBuilder(HealthHistoryDetailPageBuilder),
      param: item
    })
  }

  private getMonthMenuItems() {
    interface MenuItemType {
      value: string;
      action: () => void;
    }

    const items: MenuItemType[] = this.vm.getMonthOptions().map(month => {
      const menuItem: MenuItemType = {
        value: month,
        action: () => this.vm.selectMonth(month)
      };
      return menuItem;
    });
    return items;
  }

  build() {
    NavDestination() {
      Column() {
        // 自定义标题栏
        Row() {
          Image($r('app.media.ic_backward2'))
            .width(40)
            .aspectRatio(1)
            .margin({ left: 16, top: 32, right: 8 })
            .onClick(this.handleBack)

          Text('历史记录')
            .size({ height: 27 })
            .margin({ top: 32 })
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(700)
            .fontColor($r('sys.color.black'))

          Blank().layoutWeight(1)
        }
        .height(UnitConverter.px2vp(BarVM.instance.statusBarHeight.value) + 48)
        .width('100%')
        .margin({ top: 16, bottom: 8 })

        // 月份选择器
        Row() {
          Text(this.vm.selectedMonth)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.black'))
            .fontFamily('HarmonyOS Sans SC')
            .layoutWeight(1)

          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(16)
            .height(16)
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8
        })
        .onClick(this.handleMonthClick)
        .bindMenu(this.vm.showMonthPicker, this.getMonthMenuItems(), {
          placement: Placement.BottomRight
        })

        // 列表卡片容器 - 整体白色卡片
        Column() {
          List({ space: 0 }) {
            ForEach(this.vm.getCurrentMonthData(), (item: HealthHistoryItem, index: number) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(`体重${item.weight}`)
                      .fontSize($r('sys.float.Body_L'))
                      .fontColor($r('sys.color.black'))
                      .fontFamily('HarmonyOS Sans SC')
                      .layoutWeight(1)

                    Text(item.date)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_secondary'))
                      .fontFamily('HarmonyOS Sans SC')
                      .margin({ right: 8 })

                    Image($r('sys.media.ohos_ic_public_arrow_right'))
                      .width(16)
                      .height(16)
                      .fillColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')
                  .padding({
                    left: 20,
                    right: 20,
                    top: 18,
                    bottom: 18
                  })

                  // 下划线（最后一项不显示）
                  if (index < this.vm.getCurrentMonthData().length - 1) {
                    Divider()
                      .strokeWidth('1px')
                      .color($r('sys.color.comp_divider'))
                      .margin({ left: 16, right: 16 })
                  }
                }
                .width('100%')
                .onClick(() => this.handleItemClick(item))
              }
            })
          }
          .width('100%')
          .height('100%')
          .backgroundColor(Color.White)
          .borderRadius($r('sys.float.corner_radius_level7'))
          .clip(true)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 16
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
    .hideTitleBar(true)
  }
}

