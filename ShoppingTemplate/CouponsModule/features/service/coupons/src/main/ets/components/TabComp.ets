import { CommonConstants, CommonUtil } from 'commonlib'
import { LengthMetrics } from '@kit.ArkUI'
import { TabConstant } from '../constants';

@ComponentV2
export struct TabComp {
  /** 内容参数 **/
  // 初始Tab页索引
  @Param index: number = 0;
  @Event $index: (val: number) => void;
  // 页签名数组
  @Require @Param tabBar: string[];
  // 接收外界UI,注意使用()=>{},防止this指向性问题、不动态刷新
  @BuilderParam contentUi: (index: number) => void = this.tabContentsDefaultBuilder;
  /** 样式参数 **/
  // 页签位置: 顶部 or 底部
  @Param atTop: boolean = true;
  // 选中颜色: 文字 + 条形
  @Param activeColor: ResourceColor = TabConstant.ACTIVE_COLOR;
  // 待选颜色: 同上
  @Param frozenColor: ResourceColor = TabConstant.FROZEN_COLOR;
  // 导航区背景颜色
  @Param tabBarBgColor: ResourceColor = TabConstant.TAB_BAR_BGCOLOR;
  // 内容背景颜色
  @Param tabContentBgColor: ResourceColor = TabConstant.TAB_CONTENT_BGCOLOR;
  // 选中文字粗细
  @Param activeWeight: number | string | FontWeight = TabConstant.ACTIVE_WEIGHT;
  // 待选文字粗细
  @Param frozenWeight: number | string | FontWeight = TabConstant.FROZEN_WEIGHT;
  // 动画时长
  @Param animationDuration: number = TabConstant.ANIMATION_DURATION;
  // 导航区高度
  @Param tabBarHeight: number = TabConstant.TAB_BAR_HEIGHT;
  // 条形高度
  @Param lineHeight: number = TabConstant.LINE_HEIGHT;
  // 条形距离顶部位置
  @Param marginTop: number = TabConstant.MARGIN_TOP;
  /** 本地参数 **/
  @Local localIndex: number = 0;
  @Local indicatorLeftMargin: number = 0;
  @Local indicatorWidth: number = 0;
  private tabsWidth: number = 0;
  private textInfos: [number, number][] = [];
  private isStartAnimateTo: boolean = false;
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    for (let i = 0; i < this.tabBar.length; i++) {
      this.textInfos.push([0, 0]);
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Tabs({ barPosition: this.atTop ? BarPosition.Start : BarPosition.End, controller: this.controller }) {
        ForEach(this.tabBar, (item: string, index: number) => {
          TabContent() {
            Column() {
              this.contentUi(index)
            }.width(CommonConstants.FULL_WIDTH).height(CommonConstants.FULL_HEIGHT)
          }.tabBar(this.tabBarBuilder(item, index))
        },(item:string,index)=>item+'_'+index)
      }
      .onAppear(() => {
        this.controller.changeIndex(this.index)
      })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.tabsWidth = newValue.width as number;
        if (!this.isStartAnimateTo) {
          this.setIndicatorAttr(this.textInfos[this.localIndex][0], this.textInfos[this.localIndex][1]);
        }
      })
      .barWidth(CommonConstants.FULL_WIDTH)
      .barHeight(this.tabBarHeight)
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .barBackgroundColor(this.tabBarBgColor)
      .backgroundColor(this.tabContentBgColor)
      .animationDuration(this.animationDuration)
      .onChange((index: number) => {
        // 监听索引index的变化，实现页签内容的切换。
        this.localIndex = index;
        this.$index(index);
      })
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        // 切换动画开始时触发该回调。下划线跟着页面一起滑动，同时宽度渐变。
        this.localIndex = targetIndex;
        this.startAnimateTo(this.animationDuration, this.textInfos[targetIndex][0], this.textInfos[targetIndex][1]);
      })
      .onAnimationEnd((index: number, event: TabsAnimationEvent) => {
        // 切换动画结束时触发该回调。下划线动画停止。
        let currentIndicatorInfo = this.getCurrentIndicatorInfo(index, event);
        this.startAnimateTo(0, currentIndicatorInfo.left, currentIndicatorInfo.width);
      })
      .onGestureSwipe((index: number, event: TabsAnimationEvent) => {
        // 在页面跟手滑动过程中，逐帧触发该回调。
        let currentIndicatorInfo = this.getCurrentIndicatorInfo(index, event);
        this.localIndex = currentIndicatorInfo.index;
        this.setIndicatorAttr(currentIndicatorInfo.left, currentIndicatorInfo.width);
      })

      Column()
        .height(this.lineHeight)
        .width(this.indicatorWidth)
        .margin({ start: LengthMetrics.vp(this.indicatorLeftMargin), top: LengthMetrics.vp(this.marginTop) })
        .backgroundColor(this.activeColor)
    }.width(CommonConstants.FULL_WIDTH).layoutWeight(1)
  }

  private getCurrentIndicatorInfo(index: number, event: TabsAnimationEvent): Record<string, number> {
    let nextIndex = index;
    if (index > 0 && (CommonUtil.getIsRTL() ? event.currentOffset < 0 : event.currentOffset > 0)) {
      nextIndex--;
    } else if (index < this.textInfos.length - 1 &&
      (CommonUtil.getIsRTL() ? event.currentOffset > 0 : event.currentOffset < 0)) {
      nextIndex++;
    }
    let indexInfo = this.textInfos[index];
    let nextIndexInfo = this.textInfos[nextIndex];
    let swipeRatio = Math.abs(event.currentOffset / this.tabsWidth);
    // 页面滑动超过一半，tabBar切换到下一页。
    let currentIndex = swipeRatio > 0.5 ? nextIndex : index;
    let currentLeft = indexInfo[0] + (nextIndexInfo[0] - indexInfo[0]) * swipeRatio;
    let currentWidth = indexInfo[1] + (nextIndexInfo[1] - indexInfo[1]) * swipeRatio;
    return { 'index': currentIndex, 'left': currentLeft, 'width': currentWidth };
  }

  private startAnimateTo(duration: number, leftMargin: number, width: number) {
    this.isStartAnimateTo = true;
    animateTo({
      duration: duration,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: () => {
        this.isStartAnimateTo = false;
      },
    }, () => {
      this.setIndicatorAttr(leftMargin, width);
    })
  }

  private setIndicatorAttr(leftMargin: number, width: number) {
    this.indicatorWidth = width;
    if (CommonUtil.getIsRTL()) {
      this.indicatorLeftMargin = this.tabsWidth - leftMargin - width;
    } else {
      this.indicatorLeftMargin = leftMargin;
    }
  }

  @Builder
  tabBarBuilder(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.localIndex === index ? this.activeColor : this.frozenColor)
        .fontWeight(this.localIndex === index ? this.activeWeight : this.frozenWeight)
        .id(index.toString())
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.textInfos[index] = [newValue.globalPosition.x as number, newValue.width as number];
          if (!this.isStartAnimateTo && this.localIndex === index && this.tabsWidth > 0) {
            this.setIndicatorAttr(this.textInfos[this.localIndex][0], this.textInfos[this.localIndex][1]);
          }
        })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  tabContentsDefaultBuilder(index: number) {
    Text('TabContent' + index)
  }
}