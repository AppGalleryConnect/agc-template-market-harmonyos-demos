import { CategoryBrowserConfig as Config } from './config/CategoryBrowserConfig';
import { Category } from './model/Category';
import { CategoryBrowserRenderUnit } from './model/CategoryTypes';
import { CategoryBrowserLogic } from './logic/CategoryBrowserLogic';

@Builder
export function buildCategoryBrowser(logic: CategoryBrowserLogic) {
  /**
   * 使用层叠布局的方式，让父容器负责实际的视窗高度，原因如下：
   *
   * 1. 在滑动过程中，视窗高度需要根据内容高度逐帧动态变化。经过测试，如果让 Swiper 自身负责高度变化.height('auto')，
   * 其帧率表现并不理想。虽然可以通过自定义节点来主动接管布局生命周期, 但与 Stack 相比, 直接
   * 使用层叠布局更加简洁。
   *
   * 2. 手动实现的指示器需要在视窗高度变化的过程中，依然保证实时显示，并覆盖在 Swiper 之上。
   *
   * 3. Swiper 自身的高度不再影响其它组件布局，使得其可以随意增加自身高度，实现对触摸热区范围的增大。
   * 表现为页面滑动过程中，触摸点即便移出视窗范围，滑动交互依然可以继续维持。(因为滑动页面时，手指路径通常不会是水平的直线，很有可能移出视窗范围)
   */
  Stack({ alignContent: Alignment.Bottom }) {
    Swiper(logic.swiperController) {
      ForEach(logic.viewData, (render: CategoryBrowserRenderUnit, renderIndex: number) => {
        Column() {
          ForEach(render.content, (row: Category[], rowIndex: number) => {
            Row() {
              ForEach(row, (item: Category) => {
                buildCategoryTag(item, logic,
                  (renderIndex * Config.MAX_ROWS + rowIndex + 1) <= Config.PRIMARY_ROW_COUNT
                )
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .margin({ top: Config.ROW_SPACING, bottom: Config.LABEL_FONT_SIZE + Config.ICON_LABEL_SPACING })
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .height(logic.swiperHeight)
    .indicator(false)         // 原生指示器动画存在抖动, 且不支持高度自定义, 因此重新实现自己的指示器
    .position({ x: 0, y: 0 }) // 使用绝对位置保证内容区置顶 (同时 Alignment.Bottom 保证了指示器置底)
    .loop(false)
    .indicatorInteractive(false)
    .onContentDidScroll(logic.onContentDidScroll)
    buildIndicator(logic)
  }
  .width('100%')
  .height(logic.browserHeight)
  .clip(true)
}

@Builder
function buildCategoryTag(item: Category, logic: CategoryBrowserLogic, isPrimary: boolean) {
  Column() {
    Image(item.icon)
      .width(isPrimary ? Config.PRIMARY_ICON_SIZE : Config.ICON_SIZE)
      .height(isPrimary ? Config.PRIMARY_ICON_SIZE : Config.ICON_SIZE)
      .objectFit(ImageFit.Cover)
      .draggable(false)
    /**
     * 使用 Column 配合 .position 属性来构建一个锚点, 目的如下:
     *
     * 1. 使文本仅通过锚点来确立位置, 防止因文本自身大小的不确定性, 影响到其它元素的布局
     *
     * 2. 使文本不受父容器宽度约束
     */
    Column() {
      Text(item.label)
        .width(Config.LABEL_WIDTH)
        .fontSize(Config.LABEL_FONT_SIZE)
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .width('1px') // 使用 position 时, 至少需要一个像素宽度来锚定位置
    .position({
      x: Config.CATEGORY_TAG_WIDTH / 2,
      y: (isPrimary ? Config.PRIMARY_ICON_SIZE : Config.ICON_SIZE) + Config.ICON_LABEL_SPACING
    })
    .hitTestBehavior(HitTestMode.None)
  }
  .width(Config.CATEGORY_TAG_WIDTH)
  .alignItems(HorizontalAlign.Center)
  .onClick(() => logic.onSelected(item.id))
  .responseRegion({
    height: (isPrimary ? Config.PRIMARY_ICON_SIZE : Config.ICON_SIZE) +
        Config.ICON_LABEL_SPACING + Config.LABEL_FONT_SIZE + Config.ROW_SPACING
  })
}

@Builder
function buildIndicator(logic: CategoryBrowserLogic) {
  Row() {
    ForEach(logic.viewData, (render: CategoryBrowserRenderUnit, index: number) => {
      Column()
        .width(render.dot.width)
        .height(render.dot.height)
        .backgroundColor(render.dot.color)
        .borderRadius(Config.INDICATOR_BORDER_RADIUS)
        .margin({ left: index > 0 ? Config.INDICATOR_SPACING : 0 })
    })
  }
  .height(Config.INDICATOR_CONTAINER_HEIGHT)
  .alignItems(VerticalAlign.Center)
  .hitTestBehavior(HitTestMode.None)
}
