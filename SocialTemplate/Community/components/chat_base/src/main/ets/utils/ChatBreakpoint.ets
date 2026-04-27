@ObservedV2
export class ChatBreakpoint {
  @Trace topValue: number = 0
  @Trace bottomValue: number = 0
  @Trace currentScreenWidth: number = 0;
  @Trace currentChatBreakpoint: ChatBreakpointEnum = ChatBreakpointEnum.SM;

  // 根据当前断点，获取页面边距
  @Computed
  get pagePadding() {
    return GRID_ROW_PAGE_PADDING[this.currentChatBreakpoint] ?? 16;
  }

  /**
   * 根据栅格化动态获取每栅格宽度
   * @returns
   */
  getColumnWidth(uiContext: UIContext): number {
    let widthBreakpoint: WidthBreakpoint = uiContext.getWindowWidthBreakpoint()
    // 屏幕宽度 - 左右间隙
    let tempTotal = this.currentScreenWidth - this.pagePadding * 2;
    if (widthBreakpoint <= WidthBreakpoint.WIDTH_SM) {
      // 非阔折叠的直板设备,折叠屏折叠态，阔折叠的直板设备
      tempTotal = tempTotal - 60;
      return tempTotal / 6.0;
    } else if (widthBreakpoint === WidthBreakpoint.WIDTH_MD) {
      // 折叠屏展开态
      tempTotal = tempTotal - 84;
      return tempTotal / 8.0;
    } else {
      tempTotal = tempTotal - 36;
      return tempTotal / 4.0;
    }
  }
}

export enum ChatBreakpointEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

const GRID_ROW_PAGE_PADDING: GridRowColumnOption = {
  sm: 16,
  md: 24,
  lg: 32,
  xl: 32
};