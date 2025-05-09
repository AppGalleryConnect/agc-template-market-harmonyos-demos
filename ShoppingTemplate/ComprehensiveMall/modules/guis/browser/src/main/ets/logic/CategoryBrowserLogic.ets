import util from '@ohos.util';

import { ARGB } from '@common/customtypes';

import { CategoryBrowserConfig as Config } from '../config/CategoryBrowserConfig';
import { Category } from '../model/Category';
import { CategoryIndicatorDot } from '../model/CategoryIndicatorDot';
import { CategoryBrowserViewData } from '../model/CategoryTypes';
import { CategoryUtils } from '../utils/CategoryUtils';

@ObservedV2
export class CategoryBrowserLogic {

  private contentHeightInfo: number[] = [];

  private contentScrollCache: [number, number, number] = [0, 1, 1];

  private selectEventCallback: (id: string) => void = () => {};

  public readonly swiperController: SwiperController = new SwiperController();

  @Trace
  public _viewData: CategoryBrowserViewData = [];

  @Trace
  private _browserHeight: number = 0;

  @Trace
  private _swiperHeight: number = 0;

  @Computed
  public get viewData(): CategoryBrowserViewData {
    return this._viewData;
  }

  @Computed
  public get browserHeight(): number {
    return this._browserHeight;
  }

  @Computed
  public get swiperHeight(): number {
    return this._swiperHeight;
  }

  public setData(data: Category[]): void {
    if (!data || data.length === 0) {
      return;
    }
    this.reset();
    const viewData: CategoryBrowserViewData = [];
    const rows: Category[][] = [];
    const contentHeightInfo: number[] = [];
    for (let i: number = 0; i < data.length; i += Config.MAX_COLUMNS) {
      rows.push(data.slice(i, i + Config.MAX_COLUMNS));
    }
    if (rows.length > 0 && rows[rows.length - 1].length < Config.MAX_COLUMNS) {
      for (let i: number = rows[rows.length - 1].length; i < Config.MAX_COLUMNS; i++) {
        rows[rows.length - 1].push(Config.CATEGORY_PLACEHOLDER_ITEM);
      }
    }
    for (let i: number = 0; i < rows.length; i += Config.MAX_ROWS) {
      viewData.push({
        id: util.generateRandomUUID(false),
        content: rows.slice(i, i + Config.MAX_ROWS),
        dot: new CategoryIndicatorDot()
      });
    }
    let swiperHeight: number = 0;
    for (let i: number = 0; i < viewData.length; i++) {
      const contentHeight: number = this.computeContentHeight(viewData[i].content, i);
      swiperHeight = Math.max(swiperHeight, contentHeight);
      contentHeightInfo.push(contentHeight);
    }
    this._viewData = viewData;
    this.contentHeightInfo = contentHeightInfo;
    this._swiperHeight = swiperHeight * Config.SWIPER_RES_REGION_RATE;
    if (this._viewData.length === 1) {
      this._browserHeight = this.contentHeightInfo[0];
      this._viewData[0].dot.color = this.computeColorByProgress(1);
      this._viewData[0].dot.width = Config.INDICATOR_SELECTED_WIDTH;
      this._viewData[0].dot.height = Config.INDICATOR_SELECTED_HEIGHT;
    } else {
      this.onContentDidScroll(this.contentScrollCache[0], this.contentScrollCache[1], this.contentScrollCache[2]);
    }
  }

  public setSelectEventCallback(callback: (id: string) => void): void {
    this.selectEventCallback = callback;
  }

  public readonly onContentDidScroll = (selectedIndex: number, index: number, position: number): void => {
    if (this._viewData.length === 1) {
      return;
    }
    const current = this.contentHeightInfo[index];
    if (selectedIndex < index && position >= 0) {
      this.contentScrollCache = [selectedIndex, index, position];
      this._browserHeight = current + position * (Math.abs(current - this.contentHeightInfo[index - 1]));
      this.refreshIndicatorStatus(index - 1, index, position);
    } else if (selectedIndex > index && position <= 0) {
      this.contentScrollCache = [selectedIndex, index, position];
      this._browserHeight = current + position * (Math.abs(current - this.contentHeightInfo[index + 1]));
      this.refreshIndicatorStatus(index + 1, index, -position);
    }
  }

  public readonly onSelected = (id: string): void => {
    if (id) {
      this.selectEventCallback(id);
    }
  }

  private reset = (): void => {
    this._viewData = [];
    this._browserHeight = 0;
    this._swiperHeight = 0;
    this.contentHeightInfo = [];
    this.contentScrollCache = [0, 1, 1];
    this.swiperController.changeIndex(0, false);
  }

  private refreshIndicatorStatus = (from: number, to: number, progress: number): void => {
    if (this._viewData.length <= 1) {
      return;
    }
    const deltaWidth: number = Math.abs(Config.INDICATOR_SELECTED_WIDTH - Config.INDICATOR_WIDTH);
    const deltaHeight: number = Math.abs(Config.INDICATOR_SELECTED_HEIGHT - Config.INDICATOR_HEIGHT);
    this._viewData[from].dot.color = this.computeColorByProgress(progress);
    this._viewData[from].dot.width = Config.INDICATOR_WIDTH + deltaWidth * progress;
    this._viewData[from].dot.height = Config.INDICATOR_HEIGHT + deltaHeight * progress;
    this._viewData[to].dot.color = this.computeColorByProgress(1 - progress);
    this._viewData[to].dot.width = Config.INDICATOR_SELECTED_WIDTH - deltaWidth * progress;
    this._viewData[to].dot.height = Config.INDICATOR_SELECTED_HEIGHT - deltaHeight * progress;
  }

  private computeColorByProgress(progress: number): string {
    const linearInterpolation = (start: number, end: number) => Math.round(start + (end - start) * progress);
    const argb: ARGB = [0, 0, 0, 0];
    for (let i: number = 0; i < 'ARGB'.length; i++) {
      argb[i] = linearInterpolation(Config.INDICATOR_COLOR_ARGB[i], Config.INDICATOR_SELECTED_COLOR_ARGB[i]);
    }
    return CategoryUtils.argbToHexColor(argb);
  }

  private computeContentHeight(contentData: Category[][], index: number): number {
    let totalRowHeight: number = 0;
    const rowMarginHeight: number = Config.ROW_SPACING + Config.ICON_LABEL_SPACING + Config.LABEL_FONT_SIZE;
    for (let i: number = 0; i < contentData.length; i++) {
      let iconHeight: number = (() => {
        if ((index * Config.MAX_ROWS + i + 1) <= Config.PRIMARY_ROW_COUNT) {
          return Config.PRIMARY_ICON_SIZE;
        } else {
          return Config.ICON_SIZE;
        }
      })();
      totalRowHeight = totalRowHeight + iconHeight + rowMarginHeight;
    }
    return totalRowHeight + Config.INDICATOR_CONTAINER_HEIGHT;
  }
}
