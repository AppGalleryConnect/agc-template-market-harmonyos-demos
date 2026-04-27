@ObservedV2
export class PlayerLayoutSize {
  @Trace private playerWidth: Length = '100%';
  @Trace private playerHeight: Length = '100%';
  @Trace private xComponentWidth: Length = '100%';
  @Trace private xComponentHeight: Length = '100%';
  @Trace private layoutSizeChangeFlag: boolean = false;
  @Trace private slideMovingFlag: boolean = false;

  public updatePlayerWidth(playerWidth: Length): void {
    this.playerWidth = playerWidth;
  }

  public getPlayerWidth(): Length {
    return this.playerWidth;
  }

  public updatePlayerHeight(playerHeight: Length): void {
    this.playerHeight = playerHeight;
  }

  public getPlayerHeight(): Length {
    return this.playerHeight;
  }

  public updateXComponentWidth(xComponentWidth: Length): void {
    this.xComponentWidth = xComponentWidth;
  }

  public getXComponentWidth(): Length {
    return this.xComponentWidth;
  }

  public updateXComponentHeight(xComponentHeight: Length): void {
    this.xComponentHeight = xComponentHeight;
  }

  public getXComponentHeight(): Length {
    return this.xComponentHeight;
  }

  public updateLayoutSizeChangeFlag(flag: boolean): void {
    this.layoutSizeChangeFlag = flag
  }

  public getLayoutSizeChangeFlag(): boolean {
    return this.layoutSizeChangeFlag
  }

  public updateSlideMovingFlag(flag: boolean): void {
    this.slideMovingFlag = flag
  }

  public getSlideMovingFlag(): boolean {
    return this.slideMovingFlag
  }
}