import { UtilLog } from '@hw-agconnect/util-log';
import { LengthMetrics } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';

@ComponentV2
export struct WeightRulerComponent {
  @Consumer() weightValue: number = 65.0;
  @Consumer() weightText: string = '';
  @Local rulerWidth: number = 350;
  @Local rulerHeight: number = 40;
  @Local rulerSpacing: number = 8;
  @Local private listScroller: Scroller = new Scroller();
  @Local private weightRuleDataSource: CenterBasedWRDS = new CenterBasedWRDS(this.weightValue);
  @Local private isUserScrolling: boolean = false;
  @Local private lastScrollIndex: number = -1;
  @Local private resetIsUserScrollingTimer: number = 0;
  @Local private screenWidth: number = 0;
  @Local private displayChangeCallback: (() => void) | null = null;
  @Local private needsReposition: boolean = false;

  aboutToAppear(): void {
    this.screenWidth = display.getDefaultDisplaySync().width;
    this.updateRulerWidth();
    this.weightRuleDataSource = new CenterBasedWRDS(this.weightValue);
    this.lastScrollIndex = this.valueToIndex(this.weightValue);
    this.addDisplayListener();
  }

  aboutToDisappear(): void {
    this.clearTimer(this.resetIsUserScrollingTimer);
    this.removeDisplayListener();
  }

  private addDisplayListener(): void {
    this.displayChangeCallback = () => {
      const newScreenWidth = display.getDefaultDisplaySync().width;
      if (newScreenWidth !== this.screenWidth) {
        this.screenWidth = newScreenWidth;
        this.updateRulerWidth();
        this.needsReposition = true;
        this.updateRulerPosition();
      }
    };

    try {
      display.on('change', this.displayChangeCallback);
    } catch (e) {
      UtilLog.error(`addDisplayListener failed with error ${JSON.stringify(e)}`);
    }
  }

  private removeDisplayListener(): void {
    if (this.displayChangeCallback) {
      try {
        display.off('change', this.displayChangeCallback);
        this.displayChangeCallback = null;
      } catch (e) {
        UtilLog.error(`removeDisplayListener failed with error ${JSON.stringify(e)}`);
      }
    }
  }

  private updateRulerWidth(): void {
    this.rulerWidth = Math.floor(this.screenWidth * 0.95);
  }

  private updateRulerPosition(): void {
    if (this.needsReposition) {
      const idx = this.valueToIndex(this.weightValue);
      const targetOffset = idx * this.rulerSpacing - this.getScrollOffset();
      this.listScroller.scrollTo({ xOffset: targetOffset, yOffset: 0, animation: false });
      this.lastScrollIndex = idx;
      this.needsReposition = false;
    }
  }

  private valueToIndex(val: number): number {
    let idx = Math.round((val - 1.0) * 10);
    idx = Math.max(0, Math.min(this.weightRuleDataSource.totalCount() - 1, idx));
    return idx;
  }

  private getScrollOffset(): number {
    return (this.rulerWidth - this.rulerSpacing) / 2;
  }

  @Monitor('weightValue')
  onWeightValueChanged() {
    if (this.isUserScrolling) {
      return;
    }
    const idx = this.valueToIndex(this.weightValue);
    if (idx !== this.lastScrollIndex) {
      const targetOffset = idx * this.rulerSpacing - this.getScrollOffset();
      this.listScroller.scrollTo({ xOffset: targetOffset, yOffset: 0, animation: false });
      this.lastScrollIndex = idx;
    }
  }

  private clearTimer(timerId: number) {
    if (timerId) {
      clearTimeout(timerId);
    }
    return 0;
  }

  private updateFromScroll(centerIndex: number) {
    const clampedIndex = Math.max(0, Math.min(this.weightRuleDataSource.totalCount() - 1, centerIndex));
    const newWeight = this.weightRuleDataSource.getValue(clampedIndex);
    if (newWeight !== this.weightValue) {
      this.isUserScrolling = true;
      this.weightValue = newWeight;
      this.weightText = `${this.weightValue}`;
      this.lastScrollIndex = centerIndex;
      this.clearTimer(this.resetIsUserScrollingTimer);
      this.resetIsUserScrollingTimer = setTimeout(() => {
        this.isUserScrolling = false;
      }, 200);
    }
  }

  getDividerHeight(num: number): number {
    num = num * 10;
    if (num === 0) {
      return 0;
    }
    if (num % 10 === 0) {
      return 20;
    }
    if (num % 5 === 0) {
      return 15;
    }
    return 10;
  }

  build() {
    Column() {
      Column() {
        Polygon({ width: 12, height: 10 })
          .points([[0, 0], [6, 10], [12, 0]])
          .fill('#0ED9BA')
          .margin({ bottom: 3 })
          .offset({ left: this.rulerSpacing/2-2.5 })
      }

      Stack() {
        Column() {
          Divider()
            .vertical(true)
            .color('#0ED9BA')
            .height(30)
            .strokeWidth(2)
            .offset({ left: this.rulerSpacing/2-2.5 })

          Row() {
            List({ initialIndex: this.valueToIndex(this.weightValue), scroller: this.listScroller }) {
              LazyForEach(this.weightRuleDataSource, (item: number, index: number) => {
                ListItem() {
                  Column() {
                    Row() {
                      Divider()
                        .strokeWidth(2)
                        .color('rgba(0,0,0,0.2)')
                        .margin({ left: this.rulerSpacing/2-1 })
                        .vertical(true)
                        .height(this.getDividerHeight(item))
                    }
                    .alignItems(VerticalAlign.Bottom)
                    .height(20)

                    Row() {
                      if (item !== 0 && (item * 10 % 10) === 0) {
                        Stack() {
                          Text(item.toString())
                            .fontSize(12)
                            .opacity(0.6)
                            .fontWeight(FontWeight.Medium)
                            .textAlign(TextAlign.Center)
                            .width(30)
                            .offset({ x: -10 })
                        }
                        .width(30)
                        .height(20)
                      }
                    }
                    .height(20)
                  }
                  .width(this.rulerSpacing)
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              }, (item: number, index: number) => index.toString())
            }
            .onScrollStart(() => {
              this.isUserScrolling = true;
            })
            .onScrollStop(() => {
              const currentOffset = this.listScroller.currentOffset().xOffset;
              const centerIndex = Math.round((currentOffset + this.getScrollOffset()) / this.rulerSpacing);
              const clampedIndex = Math.max(0, Math.min(this.weightRuleDataSource.totalCount() - 1, centerIndex));
              const alignedOffset = clampedIndex * this.rulerSpacing - this.getScrollOffset();
              this.listScroller.scrollTo({ xOffset: alignedOffset, yOffset: 0, animation: false });
              this.updateFromScroll(centerIndex);
            })
            .contentEndOffset(this.getScrollOffset())
            .contentStartOffset(this.getScrollOffset())
            .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(80) })
            .scrollBar(BarState.Off)
            .alignListItem(ListItemAlign.End)
            .height(50)
            .listDirection(Axis.Horizontal)
          }
          .offset({ bottom: 25 })
          .justifyContent(FlexAlign.End)
        }
        .width(this.rulerWidth)
        .height(this.rulerHeight)
        .margin({ bottom: 15 })
        .onAppear(() => {
          this.updateRulerPosition();
        })
      }
    }
    .width('95%')
    .clip(true)
    .alignItems(HorizontalAlign.Center)
  }
}

class CenterBasedWRDS implements IDataSource {
  private totalItems: number = 2991;
  constructor(centerValue: number) {
  }
  totalCount(): number {
    return this.totalItems;
  }
  getData(index: number): number {
    return this.getValue(index);
  }
  getValue(index: number): number {
    const clampedIndex = Math.max(0, Math.min(this.totalItems - 1, index));
    const value = 1.0 + clampedIndex * 0.1;
    return parseFloat(value.toFixed(1));
  }
  registerDataChangeListener(listener: DataChangeListener): void {
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
  }
}
