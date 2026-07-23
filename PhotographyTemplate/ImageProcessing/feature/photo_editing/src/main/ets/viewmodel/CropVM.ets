import { ActionType } from '../constant/Enum';
import { MyPosition } from '../model/PageParams';
import { componentSnapshot, UIContext } from '@kit.ArkUI';
import { ContextUtil, Logger } from 'commonlib';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';


@ObservedV2
export class CropVM {
  uiContext: UIContext = ContextUtil.globalUIContext;
  settings: RenderingContextSettings = new RenderingContextSettings(true);
  maskContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  cropContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @Trace carouselCutTabIndex: number = 0;
  // 图片显示区域
  @Trace imageArea: MyPosition = new MyPosition();
  // 触摸位置
  @Trace touchPosition: MyPosition = new MyPosition();
  // 裁切的尺寸
  @Trace clipRect: MyPosition = new MyPosition();
  @Trace cropRatio: number = 0;
  @Trace clipRectMaxH: number = 0;
  @Trace clipRectMaxW: number = 0;
  @Trace actionType: ActionType = ActionType.MOVE;

  @Monitor('clipRect')
  refreshDrawMask() {
    this.maskContext.clearRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.fillStyle = 'rgba(0,0,0,0.5)';
    this.maskContext.fillRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.clearRect(this.clipRect.x - this.imageArea.x, this.clipRect.y - this.imageArea.y,
      this.clipRect.width, this.clipRect.height);
  }

  // 获取图片显示区域尺寸
  getAreaSize(newVal: Area) {
    const x = Math.round(newVal.position.x as number);
    const y = Math.round(newVal.position.y as number);
    const width = newVal.width as number;
    const height = newVal.height as number;
    this.imageArea.x = x;
    this.imageArea.y = y;
    this.imageArea.width = width;
    this.imageArea.height = height;
    this.clipRect = {
      x: x,
      y: y,
      width: width,
      height: height,
    };
  }

  // 绘制裁剪框
  drawClipImage() {
    let lineWidth = this.uiContext.vp2px(2);
    let clipRectW = this.clipRect.width! + 4;
    let clipRectH = this.clipRect.height! + 4;
    this.cropContext.clearRect(2, 2, this.clipRect.width, this.clipRect.height);
    this.cropContext.lineWidth = lineWidth;
    this.cropContext.strokeStyle = '#FFFFFF';
    this.cropContext.beginPath();

    this.cropContext.moveTo(0, 20);
    this.cropContext.lineTo(0, 0);
    this.cropContext.lineTo(20, 0);

    this.cropContext.moveTo(clipRectW / 2 - 10, 0);
    this.cropContext.lineTo(clipRectW / 2 + 10, 0);

    this.cropContext.moveTo(clipRectW - 20, 0);
    this.cropContext.lineTo(clipRectW, 0);
    this.cropContext.lineTo(clipRectW, 20);

    this.cropContext.moveTo(clipRectW, clipRectH / 2 - 10);
    this.cropContext.lineTo(clipRectW, clipRectH / 2 + 10);

    this.cropContext.moveTo(0, clipRectH - 20);
    this.cropContext.lineTo(0, clipRectH);
    this.cropContext.lineTo(20, clipRectH);

    this.cropContext.moveTo(clipRectW / 2 - 10, clipRectH);
    this.cropContext.lineTo(clipRectW / 2 + 10, clipRectH);

    this.cropContext.moveTo(clipRectW - 20, clipRectH);
    this.cropContext.lineTo(clipRectW, clipRectH);
    this.cropContext.lineTo(clipRectW, clipRectH - 20);

    this.cropContext.moveTo(0, clipRectH / 2 - 10);
    this.cropContext.lineTo(0, clipRectH / 2 + 10);

    this.cropContext.stroke();

    this.cropContext.beginPath();
    this.cropContext.lineWidth = 0.55;
    let height = Math.round((this.clipRect.height!) / 3);
    for (let index = 0; index <= 3; index++) {
      let y = index === 3 ? (this.clipRect.height) : height * index;
      this.cropContext.moveTo(2, y! + 2);
      this.cropContext.lineTo(this.clipRect.width, y! + 2);
    }
    let width = Math.round((this.clipRect.width!) / 3);
    for (let index = 0; index <= 3; index++) {
      let x = index === 3 ? (this.clipRect.width) : width * index;
      this.cropContext.moveTo(x! + 2, 2);
      this.cropContext.lineTo(x! + 2, this.clipRect.height! + 2);
    }
    this.cropContext.stroke();
  }

  // 处理裁切框的触摸事件
  handleTouch(event: TouchEvent, cutSelectIndex: number) {
    if (event.touches.length > 1) {
      return
    }

    if (event.type === TouchType.Down) {
      this.handleActionType(event.target.area, event.touches[0]);
      this.touchPosition = {
        x: event.touches[0].displayX,
        y: event.touches[0].displayY,
      };
    } else if (event.type === TouchType.Move) {
      let moveX = event.changedTouches[0].displayX - this.touchPosition.x;
      let moveY = event.changedTouches[0].displayY - this.touchPosition.y;
      this.touchPosition = {
        x: event.changedTouches[0].displayX,
        y: event.changedTouches[0].displayY,
      };
      if (cutSelectIndex === 1) {
        this.moveClipCanvasFreeType(moveX, moveY);
      } else {
        this.moveClipCanvasRatioType(moveX, moveY);
      }
    }
  }

  // 判断操作类型
  handleActionType(area: Area, touch: TouchObject) {
    let touchW = 40;
    if (this.cropRatio === 0) {
      if (touch.x < touchW && touch.y < touchW) { // 左上角
        this.actionType = ActionType.TOP_LEFT;
      } else if (touch.x < touchW && touch.y > (Number(area.height) - touchW)) { // 左下
        this.actionType = ActionType.BOTTOM_RIGHT;
      } else if (touch.x > Number(area.width) - touchW && touch.y < touchW) { // 右上
        this.actionType = ActionType.TOP_RIGHT;
      } else if (touch.x > Number(area.width) - touchW && touch.y > (Number(area.height) - touchW)) { // 右下
        this.actionType = ActionType.BOTTOM_RIGHT;
      } else if (touch.x > touchW && (touch.x < Number(area.width) - touchW) && touch.y < touchW) { //上面
        this.actionType = ActionType.TOP;
      } else if (touch.x > touchW && (touch.x < Number(area.width) - touchW) &&
        touch.y > (Number(area.height) - touchW)) { //下面
        this.actionType = ActionType.BOTTOM;
      } else if (touch.x < touchW && (touch.y < Number(area.height) - touchW) && touch.y > touchW) { //左面
        this.actionType = ActionType.LEFT;
      } else if (touch.x > Number(area.width) - touchW && (touch.y < Number(area.height) - touchW) &&
        touch.y > touchW) { //右面
        this.actionType = ActionType.RIGHT;
      } else {
        this.actionType = ActionType.MOVE;
      }
    } else {
      if (touch.x < (Number(area.width) / 2) && touch.y < touchW ||
        touch.x < touchW && touch.y < (Number(area.height) / 2)) { // 左上角
        this.actionType = ActionType.TOP_LEFT;
      } else if (touch.x < (Number(area.width) / 2) && touch.y > (Number(area.height) - touchW) ||
        touch.x < touchW && touch.y > (Number(area.height) / 2)) { // 左下
        this.actionType = ActionType.BOTTOM_LEFT;
      } else if (touch.x > Number(area.width) / 2 && touch.y < touchW ||
        touch.x > Number(area.width) - touchW && touch.y < (Number(area.height) / 2)) { // 右上
        this.actionType = ActionType.TOP_RIGHT;
      } else if (touch.x > Number(area.width) / 2 && touch.y > (Number(area.height) - touchW) ||
        touch.x > Number(area.width) - touchW && touch.y > (Number(area.height) / 2)) { // 右下
        this.actionType = ActionType.BOTTOM_RIGHT;
      } else {
        this.actionType = ActionType.MOVE;
      }
    }
  }

  // 自由裁剪框变换
  moveClipCanvasFreeType(moveX: number, moveY: number) {
    if (this.clipRect.height && this.clipRect.height <= 40) {
      return;
    }
    let clipRect: MyPosition = {
      x: this.clipRect.x,
      y: this.clipRect.y,
      width: this.clipRect.width,
      height: this.clipRect.height,
    };
    switch (this.actionType) {
      case ActionType.MOVE:
        clipRect.x += moveX;
        clipRect.y += moveY;
        break;
      case ActionType.TOP_LEFT:
        clipRect.x += moveX;
        clipRect.y += moveY;
        clipRect.width! += -moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.TOP_RIGHT:
        clipRect.y += moveY;
        clipRect.width! += moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.BOTTOM_LEFT:
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.BOTTOM_RIGHT:
        clipRect.width! += moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.TOP:
        clipRect.y += moveY;
        clipRect.height! += -moveY;
        break;
      case ActionType.BOTTOM:
        clipRect.height! += moveY;
        break;
      case ActionType.LEFT:
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        break;
      case ActionType.RIGHT:
        clipRect.width! += moveX;
        break;
      default:
        break;
    }

    // 偏移坐标小于初始位置
    if (clipRect.x < this.imageArea.x) {
      clipRect.x = this.imageArea.x;
    }

    if (clipRect.y < this.imageArea.y) {
      clipRect.y = this.imageArea.y;
    }

    // 横坐标限制位置
    if (clipRect.width! + clipRect.x > this.imageArea.width! + this.imageArea.x) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.x = this.imageArea.width! + this.imageArea.x - clipRect.width!;
      } else {
        clipRect.width = this.imageArea.width! + this.imageArea.x - clipRect.x;
      }
    }

    // 纵坐标限制
    if (clipRect.height! + clipRect.y > this.imageArea.height! + this.imageArea.y) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.y = this.imageArea.height! + this.imageArea.y - clipRect.height!;
      } else {

        clipRect.height = this.imageArea.height! + this.imageArea.y - clipRect.y;
      }
    }

    this.clipRect = {
      x: Math.round(clipRect.x),
      y: Math.round(clipRect.y),
      width: Math.round(clipRect.width!),
      height: Math.round(clipRect.height!),
    };
  }

  // 固定裁剪框位置和大小变化    初始位置为图片的初始坐标 移动的坐标
  moveClipCanvasRatioType(moveX: number, moveY: number) {
    let clipRect: MyPosition = {
      x: this.clipRect.x,
      y: this.clipRect.y,
      width: this.clipRect.width,
      height: this.clipRect.height,
    };

    switch (this.actionType) {
      case ActionType.MOVE:
        clipRect.x += moveX;
        clipRect.y += moveY;
        break;
      case ActionType.TOP_LEFT:
        if (moveX > (moveY / this.cropRatio)) {
          moveX = moveY / this.cropRatio;
        } else {
          moveY = moveX * this.cropRatio;
        }
        clipRect.x += moveX;
        clipRect.y += moveY;
        clipRect.width! += -moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.TOP_RIGHT:
        //moveX和moveY，一种正数，另外一个必然是负数
        if (moveX > 0) {
          if (moveX > -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        } else {
          if (moveX < -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        }

        clipRect.y += moveY;
        clipRect.width! += moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.BOTTOM_LEFT:
        //moveX和moveY，一种正数，另外一个必然是负数
        if (moveX > 0) {
          if (moveX > -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        } else {
          if (moveX < -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        }
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.BOTTOM_RIGHT:
        if (moveX < (moveY / this.cropRatio)) {
          moveX = moveY / this.cropRatio;
        } else {
          moveY = moveX * this.cropRatio;
        }
        clipRect.width! += moveX;
        clipRect.height! += moveY;
        break;
      default:
        break;
    }

    // 偏移坐标小于初始位置
    if (clipRect.x < this.imageArea.x) {
      clipRect.x = this.imageArea.x;
    }

    if (clipRect.y < this.imageArea.y) {
      clipRect.y = this.imageArea.y;
    }

    // 横坐标限制位置
    if (clipRect.width! + clipRect.x > this.imageArea.width! + this.imageArea.x) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.x = this.imageArea.width! + this.imageArea.x - clipRect.width!;
      } else {
        clipRect.width = this.imageArea.width! + this.imageArea.x - clipRect.x;
      }
    }

    // 纵坐标限制
    if (clipRect.height! + clipRect.y > this.imageArea.height! + this.imageArea.y) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.y = this.imageArea.height! + this.imageArea.y - clipRect.height!;
      } else {
        clipRect.height = this.imageArea.height! + this.imageArea.y - clipRect.y;
      }
    }
    if (clipRect.height! > this.clipRectMaxH) {
      clipRect.height = this.clipRectMaxH;
    }

    if (clipRect.width! > this.clipRectMaxW) {
      clipRect.width = this.clipRectMaxW;
    }

    this.clipRect = {
      x: Math.round(clipRect.x),
      y: Math.round(clipRect.y),
      width: Math.round(clipRect.width!),
      height: Math.round(clipRect.height!),
    };
  }

  // 去除剪切
  cleanReact() {
    this.clipRect.x = this.imageArea.x;
    this.clipRect.y = this.imageArea.y;
    this.clipRect.width = this.imageArea.width;
    this.clipRect.height = this.imageArea.height;
  }

  determineCropType() {
    let cropRatio = this.cropRatio;
    let imageRatio = (this.imageArea.height!) / this.imageArea.width!;
    if (cropRatio === 0) {
      this.clipRectMaxH = this.imageArea.height!;
      this.clipRectMaxW = this.imageArea.width!;
      this.clipRect = {
        x: Math.round(this.imageArea.x),
        y: Math.round(this.imageArea.y),
        width: Math.round(this.clipRectMaxW),
        height: Math.round(this.clipRectMaxH),
      };
    } else {
      if (this.imageArea.width! > this.imageArea.height!) {
        if (cropRatio < imageRatio) {
          this.clipRectMaxH = this.imageArea.width! * cropRatio;
          this.clipRectMaxW = this.imageArea.width!;
          this.clipRect = {
            x: Math.round(this.imageArea.x),
            y: Math.round(this.imageArea.y + (this.imageArea.height! - this.imageArea.width! * cropRatio) / 2),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        } else {
          this.clipRectMaxH = this.imageArea.height!;
          this.clipRectMaxW = (this.imageArea.height!) / cropRatio;
          this.clipRect = {
            x: Math.round(this.imageArea.x + (this.imageArea.width! - (this.imageArea.height!) / cropRatio) / 2),
            y: Math.round(this.imageArea.y),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        }
      } else {
        if (cropRatio > 1) {
          this.clipRectMaxH = this.imageArea.height!;
          const clipRectMaxW = (this.imageArea.height!) / cropRatio;
          this.clipRectMaxW = Math.min(clipRectMaxW, this.imageArea.width!);
          this.clipRect = {
            x: Math.round(this.imageArea.x + (this.imageArea.width! - this.clipRectMaxW) / 2),
            y: Math.round(this.imageArea.y),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        } else {
          this.clipRectMaxH = this.imageArea.width! * cropRatio;
          this.clipRectMaxW = this.imageArea.width!;
          this.clipRect = {
            x: Math.round(this.imageArea.x),
            y: Math.round(this.imageArea.y + (this.imageArea.height! - this.clipRectMaxH) / 2),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        }
      }
    }
  }
}