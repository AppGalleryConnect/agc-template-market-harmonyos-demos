import HashSet from '@ohos.util.HashSet';

export enum ContentType {
  A,
  B
}

@ObservedV2
export class SearchSuggestionCarouselLogic {

  @Trace
  public selectedContentType: ContentType = ContentType.A;

  @Trace
  public isPrepareStatus: boolean = false;

  @Trace
  public contentA: string = '';

  @Trace
  public contentB: string = '';

  @Trace
  public isPlaying: boolean = false;

  // 搜索建议数据
  private data: string[] = [];

  // 定时器 id
  private intervalID: number | null = null;

  // 当前搜索框中显示内容对应的索引指针
  private index: number = 0;

  // 选择事件触发时的回调方法, key 为选择的搜索建议
  private selectEventCallback: (key: string) => void = () => {};

  // 上一次开启轮播时使用的间隔时长 (毫秒)
  private cacheInterval: number = 0;

  /**
   * 设置新的搜索建议数据, 组件的后续轮播内容会使用新数据
   *
   * 1. 新旧数据会进行比较, 筛选出相同且在旧数据轮次中已经播放过的数据 (每份数据都有自己的轮次周期, 从头到尾播放完毕视为一轮次)
   *    被筛数据将排序在前, 本轮从被筛数据末尾播放, 实现优先显示真正意义上的新数据
   *
   * @param data 搜索建议数据
   * @param now  是否立即用新数据替换当前搜索框中正在显示的数据
   */
  public setSuggestionData(data: string[], now: boolean = false): void {
    // 将 data 转储至 HashSet, 间接实现自身去重
    const set: HashSet<string> = new HashSet();
    for (let item of data) {
      set.add(item);
    }
    // 筛选出重复且在旧数据轮次中呈现过的数据, 将其从 Set 中取出
    const realData: string[] = [];
    for (let i: number = 0; i <= Math.min(this.index, this.data.length - 1); i++) {
      if (set.has(this.data[i])) {
        realData.push(this.data[i]);
        set.remove(this.data[i]);
      }
    }
    /**
     * 更新指针到现有数据末尾, 之后写入 Set 中剩余数据
     *
     * 注: 指针当前所指数据无需担心会被重复播放, 组件会检测正在播放的数据与即将播放的数据是否相同
     */
    this.index = Math.max(realData.length - 1, 0);
    for (let item of set) {
      realData.push(item);
    }
    this.data = realData;
    // 立即替换当前显示内容
    if (now) {
      this.next(false);
      this.refreshTimer();
    }
  }

  /**
   * 立即修改当前正在显示的搜索建议
   *
   * @param content     用于修改的内容
   * @param resetTiming 是否刷新显示时长 (轮播处于启动状态时生效)
   */
  public modifyCurrentDisplay(content: string, resetTiming: boolean = false): void {
    if (this.selectedContentType === ContentType.A) {
      this.contentA = content;
    } else {
      this.contentB = content;
    }
    if (resetTiming) {
      this.refreshTimer();
    }
  }

  /**
   * 开启轮播
   *
   * @param interval 时间间隔 (毫秒)
   */
  public start(interval: number = 4500): void {
    if (!this.intervalID) {
      this.cacheInterval = interval;
      this.intervalID = setInterval(this.next, interval);
    }
  }

  /**
   * 停止轮播
   */
  public stop(): void {
    if (this.intervalID) {
      clearInterval(this.intervalID);
      this.intervalID = null;
    }
  }

  /**
   * 刷新定时器状态
   */
  private refreshTimer = (): void => {
    if (this.intervalID) {
      this.stop();
      this.start(this.cacheInterval);
    }
  }

  /**
   * 显示下一条搜索建议
   *
   * @param animated 是否使用动画
   */
  private next = (animated: boolean = true): void => {
    const nextIndex: number | null = this.getNextIndex();
    if (nextIndex !== null) {
      this.index = nextIndex;
      if (animated) {
        this.enterPrepare(this.realPlayAnimation);
      } else {
        this.modifyCurrentDisplay(this.data[this.index], true);
      }
    }
  }

  /**
   * 进入准备阶段
   *
   * 1. 将状态变量 isPrepareStatus 设置为 true, 未被选中的内容(A or B)会移动到视窗下方, 等待动画入场
   *
   * 2. 更新未被选中内容的数据
   *
   * 3. 以上环节准备完成后, 执行 onStandby()
   */
  private enterPrepare = (onStandby: () => void): void => {
    animateTo({
      duration: 0,
      onFinish: onStandby
    }, () => {
      this.isPlaying = true;
      this.isPrepareStatus = true;
      this.contentA = this.selectedContentType === ContentType.A ? this.contentA : this.data[this.index];
      this.contentB = this.selectedContentType === ContentType.B ? this.contentB : this.data[this.index];
    });
  }

  /**
   * 正式执行轮播动画
   *
   * 1. 将状态变量 isPrepareStatus 设置为 false, 被选中内容将移动至视窗内, 未被选中内容将移动至视窗上方
   *
   * 2. 更新本轮的选中内容
   *
   * 3. 由于经历了准备环节, 最终呈现的效果一定是曾经被选中的内容上移出视窗外, 本次选中的内容从视窗下方移动至视窗内
   */
  private realPlayAnimation = (): void => {
    animateTo({
      duration: 600,
      onFinish: () => this.isPlaying = false
    }, () => {
      this.isPrepareStatus = false;
      this.selectedContentType = this.selectedContentType === ContentType.A ? ContentType.B : ContentType.A;
    })
  }

  /**
   * 获取下一条搜索建议对应的索引
   *
   * 与当前显示内容相同的数据会被跳过, 找不到数据时会返回 null
   */
  private getNextIndex = (): number | null => {
    if (this.data.length === 0) {
      return null;
    }
    let next: number = this.index >= this.data.length ? 0 : this.index;
    const currentContent = this.selectedContentType === ContentType.A ? this.contentA : this.contentB;
    while (true) {
      if (this.data[next] !== currentContent && this.data[next] !== '') {
        return next;
      }
      next = next + 1 >= this.data.length ? 0 : next + 1;
      if (next === this.index) {
        return null;
      }
    }
  }

  /**
   * 组件点击事件的监听方法
   */
  public readonly onClick = (): void => {
    const key: string = this.selectedContentType === ContentType.A ? this.contentA : this.contentB;
    this.selectEventCallback(key);
  }

  /**
   * 设置选择事件的回调方法
   *
   * @param callback 回调方法
   */
  public setSelectEventCallback(callback: (key: string) => void): void {
    this.selectEventCallback = callback;
  }
}
