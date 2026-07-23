import { IPosition } from '../types/Types';

@ComponentV2
export struct DragList {
  @Param arr: IPosition[] = [];
  @Param itemHeight: number = 100;
  @Param listMargin: number = 10;
  @Event exchangeNext: (pre: number) => void;
  @BuilderParam itemUi: (index: number) => void;
  @Local itemOffsetList: number[] = [];
  private _listScroller: ListScroller = new ListScroller();
  private _dragIndex: number = -1;
  private _originDragIndex: number = -1;
  private _itemTotalHeight: number = this.itemHeight + this.listMargin;
  private _dragOffsetY: number = 0;
  private _relativeOffsetY: number = 0;
  private _listMaxScrollOffsetY: number = 0;
  private _originListOffsetY: number = 0;
  private _listArea: Area = {
    width: 0,
    height: 0,
    position: {},
    globalPosition: {},
  };

  aboutToAppear(): void {
    this.itemOffsetList = new Array<number>(this.arr.length);
    this._itemTotalHeight = this.itemHeight + this.listMargin;
  }

  initState() {
    this.itemOffsetList = this.itemOffsetList.map(() => 0);
    this._dragIndex = -1;
    this._originDragIndex = -1;
    this._dragOffsetY = 0;
    this._originListOffsetY = this._listScroller.currentOffset().yOffset;
  }

  startDragItem(dragIndex: number) {
    this.initState();
    this.getUIContext().animateTo({ curve: Curve.Linear }, () => {
      this._dragIndex = dragIndex;
      this._originDragIndex = dragIndex;
    });
  }

  increaseDragIndex(eventOffsetY: number) {
    let tmp = this.arr.splice(this._dragIndex, 1);
    this.arr.splice(this._dragIndex + 1, 0, tmp[0]);
    this.exchangeNext(this._dragIndex);
    this._dragIndex = this._dragIndex + 1;
    this.itemOffsetList[this._dragIndex] = eventOffsetY - (this._dragIndex - this._originDragIndex) *
    this._itemTotalHeight + this._listScroller.currentOffset().yOffset - this._originListOffsetY;
    this.itemOffsetList[this._dragIndex - 1] = this._itemTotalHeight;
    this.getUIContext().animateTo({ curve: Curve.Sharp, duration: 100 }, () => {
      this.itemOffsetList[this._dragIndex - 1] = 0;
    });
  }

  decreaseDragIndex(eventOffsetY: number) {
    let tmp = this.arr.splice(this._dragIndex, 1);
    this.arr.splice(this._dragIndex - 1, 0, tmp[0]);
    this.exchangeNext(this._dragIndex - 1);
    this._dragIndex = this._dragIndex - 1;
    this.itemOffsetList[this._dragIndex] = eventOffsetY - (this._dragIndex - this._originDragIndex) *
    this._itemTotalHeight + this._listScroller.currentOffset().yOffset - this._originListOffsetY;
    this.itemOffsetList[this._dragIndex + 1] = -this._itemTotalHeight;
    this.getUIContext().animateTo({ curve: Curve.Sharp, duration: 100 }, () => {
      this.itemOffsetList[this._dragIndex + 1] = 0;
    });
  }

  cancelDrag() {
    this.initState();
  }

  endDragItem() {
    this.getUIContext().animateTo({ curve: Curve.Sharp, duration: 100 }, () => {
      this.initState();
    });
  }

  build() {
    List({ space: this.listMargin, scroller: this._listScroller }) {
      ForEach(this.arr, (item: IPosition, index: number) => {
        ListItem() {
          this.itemUi(index)
        }
        .width('100%')
        .height(this.itemHeight)
        .zIndex(this._dragIndex === index ? 1 : 0)
        .scale(this._dragIndex === index ? { x: 1.05, y: 1.05 } : {})
        .offset({ y: this.itemOffsetList[index] })
        .gesture(GestureGroup(GestureMode.Sequence,
          LongPressGesture({ fingers: 1, repeat: false, duration: 200 }),
          PanGesture()
            .onActionStart(() => {
              this.startDragItem(index);
            })
            .onActionUpdate((event: GestureEvent) => {
              this._dragOffsetY = event.offsetY - (this._dragIndex - this._originDragIndex) * this._itemTotalHeight +
              this._listScroller.currentOffset().yOffset - this._originListOffsetY;
              // 限制dragOffsetY上下界
              let maxOffsetY = (this.arr.length - this._dragIndex - 1) * this._itemTotalHeight - this.listMargin;
              let minOffsetY = -this._dragIndex * this._itemTotalHeight + this.listMargin;
              this._dragOffsetY = Math.min(maxOffsetY, this._dragOffsetY);
              this._dragOffsetY = Math.max(minOffsetY, this._dragOffsetY);
              this._relativeOffsetY = this._dragOffsetY + this._dragIndex * this._itemTotalHeight + this.itemHeight / 2;
              this.itemOffsetList[this._dragIndex] = this._dragOffsetY;
              let fingerInfo = event.fingerList[0];
              let clickPercentY = (fingerInfo.globalY - Number(this._listArea.globalPosition.y)) /
              Number(this._listArea.height);
              if (clickPercentY > 0.8 && !this._listScroller.isAtEnd()) {
                let scrollVelocity = clickPercentY > 0.9 ? 4 : 2;
                if (this._listMaxScrollOffsetY - this._listScroller.currentOffset().yOffset > scrollVelocity + 5) {
                  this._listScroller.scrollTo({
                    xOffset: 0,
                    yOffset: this._listScroller.currentOffset().yOffset += scrollVelocity,
                  });
                }
              } else if (clickPercentY < 0.2 && this._listScroller.currentOffset().yOffset >= 0) {
                let scrollVelocity = clickPercentY < 0.1 ? 4 : 2;
                if (this._listScroller.currentOffset().yOffset > scrollVelocity + 5) {
                  this._listScroller.scrollTo({
                    xOffset: 0,
                    yOffset: this._listScroller.currentOffset().yOffset -= scrollVelocity,
                  });
                }
              }
              // 获取当前滑动到的index
              let insertIndex = Math.trunc(this._relativeOffsetY / this._itemTotalHeight);
              if (this._dragIndex < insertIndex) {
                this.increaseDragIndex(event.offsetY);
              } else if (this._dragIndex > insertIndex) {
                this.decreaseDragIndex(event.offsetY);
              }
            })
            .onActionEnd(() => {
              this.endDragItem();
            }),
        ).onCancel(() => {
          this.cancelDrag();
        }),
        )
      }, (item: IPosition, index: number) => JSON.stringify(item) + '_' + index)
    }
    .clip(false)
    .cachedCount(this.arr.length)
    .width('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this._listArea = newValue;
      this._listMaxScrollOffsetY = this.arr.length * this.itemHeight - 10;
    })
  }
}