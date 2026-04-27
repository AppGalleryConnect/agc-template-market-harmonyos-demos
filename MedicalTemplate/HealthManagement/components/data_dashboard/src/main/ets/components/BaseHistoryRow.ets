// 历史记录页面基础组件
import { CommonHeader } from './CommonHeader';

// 历史记录项基础接口
export interface BaseHistoryItem {
  dateTime: string;
}

// 月份数据接口
export interface MonthData {
  monthTitle: string;
  records: BaseHistoryItem[];
}

// 历史记录ViewModel接口
export interface BaseHistoryViewModel {
  months: MonthData[];
  selectedMonthIndex: number;
  showMonthMenu: boolean;
  getMonthMenuItems(): Array<MenuElement>;
}

// 历史页面配置
export class HistoryRowConfig {
  title: string = '历史记录';
  itemBuilder: WrappedBuilder<[object, () => void]> | null = null;
  hasDetailPage: boolean = false;
}

// 基础历史页面组件
@ComponentV2
export struct BaseHistoryRow {
  @Require @Param vm: BaseHistoryViewModel;
  @Require @Param config: HistoryRowConfig;
  @Param onItemClick: (item: object) => void = () => {};
  @Param onRouterReady: (router: NavPathStack) => void = () => {};

  @Local routerModule: NavPathStack = new NavPathStack();

  private handleBack = (): void => {
    this.routerModule.pop();
  }

  private handleItemClickInternal = (item: object): void => {
    if (this.onItemClick) {
      this.onItemClick(item);
    }
  }

  @Builder
  private renderCustomHeader() {
    CommonHeader({
      title: this.config.title,
      onBack: this.handleBack
    })
  }

  @Builder
  private renderMonthSection() {
    Column({ space: 12 }) {
      // 月份选择器
      Row() {
        Text(this.vm.months[this.vm.selectedMonthIndex].monthTitle)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))

        Blank().layoutWeight(1)

        Image($r('app.media.iconRight'))
          .width(16)
          .height(16)
          .rotate({ angle: 90 })
      }
      .width('100%')
      .padding({
        top: 16,
        bottom: 8,
        left: 16,
        right: 16
      })
      .onClick(() => {
        this.vm.showMonthMenu = true;
      })
      .bindMenu(this.vm.showMonthMenu, this.vm.getMonthMenuItems(), {
        placement: Placement.BottomRight,
        onDisappear: () => {
          this.vm.showMonthMenu = false;
        },
        offset: { x: -16, y: 0 }
      })

      // 历史记录列表
      Column({ space: 0 }) {
        ForEach(
          this.vm.months[this.vm.selectedMonthIndex].records,
          (record: BaseHistoryItem, index: number) => {
            // 使用传入的itemBuilder渲染每一项
            if (this.config.itemBuilder !== null) {
              this.config.itemBuilder.builder(record as object, () => this.handleItemClickInternal(record as object))
            }

            // 分割线
            if (index < this.vm.months[this.vm.selectedMonthIndex].records.length - 1) {
              Divider()
                .color($r('sys.color.comp_divider'))
                .strokeWidth('1px')
                .margin({ left: 16, right: 16 })
            }
          }
        )
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .clip(true)
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.renderCustomHeader()

        Scroll() {
          Column({ space: 12 }) {
            this.renderMonthSection()
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 24
          })
        }
        .align(Alignment.Top)
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .margin({ top: 10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_gray'))
      .padding({ top: 24 })
    }
    .hideTitleBar(true)
    .onReady((context) => {
      this.routerModule = context.pathStack;
      this.onRouterReady(context.pathStack);
    })
    .onBackPressed(() => {
      this.routerModule.pop();
      return true;
    })
  }
}
