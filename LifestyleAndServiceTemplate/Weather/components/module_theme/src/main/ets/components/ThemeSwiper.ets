import { CommonUtil } from '../utils/CommonUtil';

export type Src = PixelMap | ResourceStr | DrawableDescriptor;

@ComponentV2
export struct ThemeSwiper {
  /** 接收参数 **/
  // 中心图片宽度
  @Param @Once imgWidth: number = 264;
  // 中心图片高度
  @Param @Once imgHeight: number = 190;
  // 阴影大小
  @Param shadowRatio: number = 1;
  // 间隔时间
  @Param interval: number = 3000;
  // 是否循环
  @Param isLoop: boolean = true;
  // 是否自动播放
  @Param autoPlay: boolean = false;
  // 图片地址
  @Require @Param imgList: Src[] = [];
  // 当前图片被点击
  @Event onImageClick: (index: number) => void;
  @Param indicator: boolean = false;
  /** 本地参数 **/
  @Local curIndex: number = 0;
  @Local bakIndex: number = 0;
  @Local allScale: number[] = [];
  @Local containerWidth: number = 0;
  @Local marginWidth: number = 0;
  @Local swiperHeight: number = 0;
  @Local ratio: number = 0;
  @Local imgSpace: number = 12;
  @Local containerRatio: number = 1;
  @Local maxWidth: number = 264;
  @Local minWidth: number = 136;
  @Local isShow: boolean = true;
  private _controller: SwiperController = new SwiperController();
  private _indicatorController: IndicatorComponentController = new IndicatorComponentController();
  private _timer: number = 0;
  private _bakWidth: number = 0;
  private _bakHeight: number = 0;
  private _changeFlag: number = 0;

  @Monitor('imgList')
  refresh() {
    if (this._changeFlag !== 0) {
      this.isShow = false;
      this._timer = setTimeout(() => {
        this.isShow = true;
      }, 100);
    }
    this._changeFlag++;
    this.initDataByIsCovered();
    this.curIndex = 0;
  }

  // 根据切换模式初始化,宽高限制
  initDataByIsCovered(): void {
    if (this._bakWidth <= 0 || this._bakHeight <= 0) {
      CommonUtil.error('Set the image width and height correctly!');
      return;
    }
    this.curIndex = 0;
    // 获取当前容器宽度相对360vp的比率
    this.containerRatio = this.containerWidth / 360;
    this.imgWidth = this._bakWidth;
    this.imgHeight = this._bakHeight;
    this.imgSpace = 10 * this.containerRatio;
    this.maxWidth = 264 * this.containerRatio;
    this.minWidth = 136 * this.containerRatio;
    // 限制宽度
    if (this.imgWidth > this.maxWidth) {
      this.imgHeight = this.imgHeight / (this.imgWidth / this.maxWidth);
      this.imgWidth = this.maxWidth;
    }
    if (this.imgWidth < this.minWidth) {
      this.imgHeight = this.imgHeight * (this.minWidth / this.imgWidth);
      this.imgWidth = this.minWidth;
    }
    const fullVisibleMax = this.containerWidth * 0.35;
    const isWideEnough = this.containerWidth >= this._bakWidth * 3;
    if (isWideEnough && this.imgWidth > fullVisibleMax) {
      this.imgHeight = this._bakHeight * (fullVisibleMax / this._bakWidth);
      this.imgWidth = fullVisibleMax;
    }
    this.ratio = 7 * this.imgSpace / this.imgHeight;
    const sideCardMeasuredWidth = this.imgWidth * (1 - this.ratio) + 24 * this.containerRatio;
    const naturalMargin = (this.containerWidth - this.imgWidth - this.imgSpace) / 2;
    if (isWideEnough) {
      this.marginWidth = Math.max(naturalMargin, Math.min(sideCardMeasuredWidth, this.containerWidth / 3));
    } else {
      this.marginWidth = Math.min(naturalMargin, sideCardMeasuredWidth);
    }
    this.swiperHeight = this.imgHeight + 16 * this.containerRatio;
    this.allScale = new Array(this.imgList.length).fill(1 - this.ratio);
    this.allScale[0] = 1;
  }

  aboutToAppear(): void {
    if (this.imgList.length < 3) {
      CommonUtil.error('Please transfer at least three images!');
    } else {
      //备份初始化宽高，防止因窗口变化，宽高变化后，无法恢复
      this._bakWidth = this.imgWidth;
      this._bakHeight = this.imgHeight;
      this.initDataByIsCovered();
    }
  }

  build() {
    Column() {
      if (this.isShow) {
        Swiper(this._controller) {
          ForEach(this.imgList, (url: Src, index) => {
            Column() {
              Image(url)
                .borderRadius(16)
                .shadow({
                  radius: this.getUIContext().vp2px(4 * this.containerRatio * this.shadowRatio),
                  color: 'rgba(0,0,0,0.2)',
                  fill: true,
                  offsetY: 4,
                })
                .height(this.imgHeight * this.allScale[index])
                .width(this.imgWidth * this.allScale[index])
                .onError((callback: ImageError) => {
                  CommonUtil.error(callback.message);
                })
                .onClick(() => {
                  if (index === this.curIndex) {
                    this.onImageClick(index);
                  } else {
                    if (this.curIndex === this.imgList.length - 2 && index === this.imgList.length - 1) {
                      this._controller.showNext();
                    } else if (this.curIndex === this.imgList.length - 1 && index === 0) {
                      this._controller.showNext();
                    } else if (this.curIndex === 1 && index === 0) {
                      this._controller.showPrevious();
                    } else if (this.curIndex === 0 && index === this.imgList.length - 1) {
                      this._controller.showPrevious();
                    } else {
                      this._controller.changeIndex(index, true);
                    }
                  }
                })
            }
            .justifyContent(FlexAlign.Center)
            .padding({ top: 8 * this.containerRatio, bottom: 8 * this.containerRatio })
            .margin({ left: 12 * this.containerRatio, right: 12 * this.containerRatio })
          }, (item: Src, index) => index.toString())
        }
        .onChange((index) => {
          this.curIndex = index;
        })
        .width(this.containerWidth)
        .height(this.swiperHeight)
        .prevMargin(this.marginWidth)
        .nextMargin(this.marginWidth)
        .indicator(this.indicator ? this._indicatorController : false)
        .autoPlay(this.autoPlay)
        .interval(this.interval)
        .loop(this.isLoop)
        .customContentTransition({
          timeout: 1000,
          transition: (proxy: SwiperContentTransitionProxy) => {
            // 计算缩放比例
            let scale = 1 - Math.abs(proxy.position) * this.ratio;
            this.allScale[proxy.index % this.allScale.length] = scale;
          },
        })
        .onAnimationStart((index, targetIndex) => {
          this.bakIndex = targetIndex;
          this.curIndex = this.bakIndex;
        })
        .onAppear(() => {
          // 清除定时器
          clearTimeout(this._timer);
        })

        if (this.indicator) {
          IndicatorComponent(this._indicatorController)
            .style(new DotIndicator())
            .loop(this.isLoop)
            .count(5)
        }
      }
    }
    .size({ width: '100%', height: this.swiperHeight })
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      if (this.containerWidth !== newValue.width as number) {
        this.containerWidth = newValue.width as number;
        this.imgWidth = this._bakWidth;
        this.imgHeight = this._bakHeight;
        this.containerRatio = this.containerWidth / 360;
        this.initDataByIsCovered();
      }
    })
  }
}
