import { NavItemModel, NavBadge } from '../model/NavItemModel';
import { FloatingNavBarStyle } from '../model/FloatingNavBarStyle';
import { FloatingNavDefaults } from '../common/FloatingNavConstants';

/**
 * 悬浮导航栏组件
 *
 * 使用示例：
 * ```
 * FloatingNavBar({
 *   items: [
 *     { id: 0, title: '首页', icon: $r('app.media.ic_home'), selectedIcon: $r('app.media.ic_home_fill') },
 *     { id: 1, title: '视频', icon: $r('app.media.ic_video'), badge: { type: 'dot' } },
 *     { id: 2, title: '我的', icon: $r('app.media.ic_mine'), badge: { type: 'number', count: 5 } },
 *   ],
 *   selectedIndex: this.currentIndex,
 *   onIndexChange: (index: number) => { this.currentIndex = index; },
 *   style: { activeColor: '#FF6B00' }
 * })
 * ```
 */
@ComponentV2
export struct FloatingNavBar {
  /** 导航项数据（必填） */
  @Param items: NavItemModel[] = [];
  /** 当前选中索引 */
  @Param selectedIndex: number = 0;
  @Param isLandscape: boolean = false;
  @Param screenSize: string = 'sm';
  /** 选中项变化时回调 */
  @Event onIndexChange?: (index: number) => void;
  /** 自定义样式（可选） */
  @Param style: FloatingNavBarStyle = {};
  /** 自定义 item 渲染器（可选，传入后将完全替代默认渲染） */
  @BuilderParam itemBuilder?: (item: NavItemModel, index: number) => void;

  private getBorderRadius(): number {
    return this.style.borderRadius ?? FloatingNavDefaults.BORDER_RADIUS;
  }

  private getBackgroundColor(): ResourceStr {
    return this.style.backgroundColor ?? FloatingNavDefaults.BACKGROUND_COLOR;
  }

  private getBlurStyle(): BlurStyle {
    return this.style.blurStyle ?? FloatingNavDefaults.BLUR_STYLE;
  }

  private getBorderWidth(): number {
    return this.style.borderWidth ?? FloatingNavDefaults.BORDER_WIDTH;
  }

  private getBorderColor(): string {
    return this.style.borderColor ?? FloatingNavDefaults.BORDER_COLOR;
  }

  private getIconSize(): number {
    return this.style.iconSize ?? FloatingNavDefaults.ICON_SIZE;
  }

  private getTitleSize(): number {
    return this.style.titleSize ?? FloatingNavDefaults.TITLE_SIZE;
  }

  private getActiveColor(): string {
    return this.style.activeColor ?? FloatingNavDefaults.ACTIVE_COLOR;
  }

  private getInactiveColor(): string {
    return this.style.inactiveColor ?? FloatingNavDefaults.INACTIVE_COLOR;
  }

  // ===== 内置默认 item 渲染 =====
  @Builder
  DefaultItemBuilder(item: NavItemModel, index: number) {
    Column() {
      Stack() {
        // 图标区域
        this.IconBuilder(item, index)
        // 角标
        if (item.badge) {
          this.BadgeBuilder(item.badge)
        }
      }

      // 标题
      Text(item.title)
        .fontSize(this.getTitleSize())
        .fontColor(this.selectedIndex === index ? this.getActiveColor() : this.getInactiveColor())
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onIndexChange?.(index);
    })
  }

  // 图标渲染：根据 icon 类型自动选择 Text 或 Image
  @Builder
  IconBuilder(item: NavItemModel, index: number) {
    if (typeof (this.selectedIndex === index ? (item.selectedIcon ?? item.icon) : item.icon) === 'string') {
      Text(this.selectedIndex === index
        ? ((item.selectedIcon as string) ?? (item.icon as string))
        : (item.icon as string))
        .fontSize(this.getIconSize())
        .fontColor(this.selectedIndex === index ? this.getActiveColor() : this.getInactiveColor())
    } else {
      Image(this.selectedIndex === index
        ? (item.selectedIcon ?? item.icon)
        : item.icon)
        .width(this.getIconSize())
        .height(this.getIconSize())
        .fillColor(this.selectedIndex === index ? this.getActiveColor() : this.getInactiveColor())
    }
  }

  // 角标渲染
  @Builder
  BadgeBuilder(badge: NavBadge) {
    if (badge.type === 'dot') {
      // 红点角标
      Column()
        .width(FloatingNavDefaults.BADGE_DOT_SIZE)
        .height(FloatingNavDefaults.BADGE_DOT_SIZE)
        .borderRadius(FloatingNavDefaults.BADGE_DOT_SIZE / 2)
        .backgroundColor(FloatingNavDefaults.BADGE_BG_COLOR)
        .position({ right: -2, top: -2 })
    } else if (badge.type === 'number' && badge.count !== undefined && badge.count > 0) {
      // 数字角标
      Text(this.formatBadgeCount(badge.count, badge.maxCount))
        .fontSize(FloatingNavDefaults.BADGE_FONT_SIZE)
        .fontColor(FloatingNavDefaults.BADGE_TEXT_COLOR)
        .backgroundColor(FloatingNavDefaults.BADGE_BG_COLOR)
        .borderRadius(8)
        .padding({
          left: 5,
          right: 5,
          top: 1,
          bottom: 1
        })
        .position({ right: -8, top: -4 })
    }
  }

  private formatBadgeCount(count: number, maxCount?: number): string {
    const max = maxCount ?? FloatingNavDefaults.BADGE_MAX_COUNT;
    return count > max ? `${max}+` : count.toString();
  }

  build() {
    Flex({
      // 竖屏模式下 主轴是水平的。子组件从左到右横向排列。
      direction: this.isLandscape ? FlexDirection.Column : FlexDirection.Row,
      justifyContent: FlexAlign.SpaceAround, // 均匀分布
      alignItems: ItemAlign.Center
    }) {
      ForEach(this.items, (item: NavItemModel, index: number) => {
        Column() {
          if (this.itemBuilder) {
            this.itemBuilder(item, index)
          } else {
            this.DefaultItemBuilder(item, index)
          }
        }
        // 横屏时给每个 Item 增加上下间距，竖屏时增加左右间距
        .margin(this.isLandscape ? { top: 10, bottom: 10 } : { left: 5, right: 5 })
      })
    }
    // 关键：宽高也需要根据方向互换
    .width(this.isLandscape ? 96 : this.screenSize === 'sm' ? 318 : 400)
    .height(this.isLandscape ? '100%' : 56)
    .padding({ top: this.isLandscape ? 200 : 0, bottom: this.isLandscape ? 200 : 0 })
    .backgroundColor(this.getBackgroundColor())
    .backgroundBlurStyle(this.getBlurStyle())
    .borderRadius(this.isLandscape ? 0 : this.getBorderRadius())
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .border({ width: this.isLandscape ? 0 : this.getBorderWidth(), color: this.isLandscape ? '' : this.getBorderColor() })
    .shadow({
      radius: this.style.shadowRadius ?? FloatingNavDefaults.SHADOW_RADIUS,
      color: this.style.shadowColor ?? FloatingNavDefaults.SHADOW_COLOR,
      offsetX: this.isLandscape ? 4 : 0, // 横屏时阴影偏移方向调整
      offsetY: this.isLandscape ? 0 : (this.style.shadowOffsetY ?? FloatingNavDefaults.SHADOW_OFFSET_Y)
    })
  }
}