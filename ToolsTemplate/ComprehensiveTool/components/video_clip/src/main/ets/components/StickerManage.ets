import { UtilLog } from '@hw-agconnect/util-log';
import sdk from 'libveditor.so';
import { Sticker } from '../model/Sticker';
import { Point } from '../model/Index';
import { VideoEditVM } from '../viewmodel/VideoEditVM';

let maxX: number = 0;
let minX: number = 0;
let maxY: number = 0;
let minY: number = 0;

@ComponentV2
export struct StickerManage {
  vm: VideoEditVM = VideoEditVM.instance;
  @Param @Require sticker: Sticker;
  @Local stickerX: number = 0;
  @Local stickerY: number = 0;

  // 初始化视频区域信息
  aboutToAppear() {
    // 获取视频区域原始坐标
    const videoArea: Point[] | undefined = sdk.GetDrawableArea();
    if (videoArea && videoArea.length >= 2) {
      // 计算视频实际宽高
      maxX = videoArea[1].x;
      minX = videoArea[0].x;
      maxY = videoArea[2].y;
      minY = videoArea[0].y;
    }
    // 初始化贴纸位置
    this.stickerX = this.getUIContext().px2vp(this.sticker.screenWidth);
    this.stickerY = this.getUIContext().px2vp(this.sticker.screenHeight);
  }

  panEnd(event: GestureEvent) {
    this.stickerX = this.stickerX + event.offsetX;
    this.stickerY = this.stickerY + event.offsetY;
    // 计算Y向边界须减去返回栏高度
    if (this.stickerX <= this.getUIContext().px2vp(minX) || this.stickerX >= this.getUIContext().px2vp(maxX) ||
      this.stickerY <= this.getUIContext().px2vp(minY + this.getUIContext().vp2px(40)) ||
      this.stickerY >= this.getUIContext().px2vp(maxY - this.getUIContext().vp2px(40))) {
      this.getUIContext().getPromptAction().showToast({ message: '仅可在视频范围内拖动贴纸' });
      this.stickerX = this.getUIContext().px2vp(this.sticker.screenWidth);
      this.stickerY = this.getUIContext().px2vp(this.sticker.screenHeight);
      return;
    }

    this.sticker.offsetX = this.stickerX;
    this.sticker.offsetY = this.stickerY;
    sdk.MoveImage(this.sticker.id, this.getUIContext().vp2px(this.sticker.offsetX),
      this.getUIContext().vp2px(this.sticker.offsetY));
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image(this.sticker.uri)
        .objectFit(ImageFit.Contain)
        .width(this.getUIContext().px2vp(this.sticker.width))
        .height(this.getUIContext().px2vp(this.sticker.height))
        .stickerGestureGroup(this)
        .onClick(() => {
          this.sticker.isSelected = true;
        });

      Image($r('app.media.clear')).size({ width: 16, height: 16 }).offset({ x: 4, y: -4 }).onClick(() => {
        this.vm.deleteSticker(this.sticker.id);
      });
    }.zIndex(2).position({
      x: this.stickerX - this.getUIContext().px2vp(this.sticker.width / 2),
      y: this.stickerY - this.getUIContext().px2vp(this.sticker.height / 2),
    });
  }
}

@Extend(Image)
function stickerGestureGroup(stickerManage: StickerManage) {
  .gesture(GestureGroup(GestureMode.Exclusive,
    GestureGroup(GestureMode.Parallel,
      PanGesture({ fingers: 1 })
        .onActionStart(() => {
          UtilLog.info('video sticker pan start');
        })
        .onActionUpdate((event: GestureEvent) => {
          UtilLog.info(`video sticker pan update with x ${event.offsetX} and y ${event.offsetY} `);
        })
        .onActionEnd((event: GestureEvent) => {
          stickerManage.panEnd(event);
        }),
    ),
  ));
}
