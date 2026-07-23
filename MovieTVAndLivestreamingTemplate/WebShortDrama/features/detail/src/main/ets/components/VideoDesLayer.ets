import { DramaInfo } from '@agctemplate/server';
import { Logger } from '@agctemplate/utils';
import { CastService } from 'module_cast';
import { PlayController } from 'video_swiper';
import { SerialPicker } from './SerialPicker';
import { Params, PromptActionClass } from './PromptActionClass';
import { FontModel, fp2pxUtil } from '@agctemplate/widgets';
import { AppStorageV2, display } from '@kit.ArkUI';

const TAG = '[VideoDesLayer]'

// 展示视频相关信息
@ComponentV2
export struct VideoDesLayer {
  @Param @Require dramaInfo: DramaInfo;
  @Local isShowSerialPickerSheet: boolean = false; //是否展示选集
  @Param @Require playController: PlayController
  @Event isLocked: Function;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Local isHover: boolean = false;
  private foldStatusChange: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    this.getHover();
  };

  aboutToAppear(): void {
    this.getHover()
    try {
      display.on('foldStatusChange', this.foldStatusChange);
    } catch (e) {
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange', this.foldStatusChange);
    } catch (e) {
    }
  }

  build() {
    Row() {
      Text(this.playController.isLocked ? `共${this.dramaInfo.totalCount}集·VIP抢先看` :
        `共${this.dramaInfo.totalCount}集·免费观看`)
        .height(19)
        .fontSize(this.fontModel.getFg(14))
        .fontWeight(400)
        .fontColor('rgba(255, 255, 255, 0.6)')
      Text('选集')
        .width(72)
        .height(28)
        .borderRadius(14)
        .backgroundColor('rgba(255, 255, 255, 0.4)')
        .fontSize(fp2pxUtil(14))
        .fontColor('#fff')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.isShowSerialPickerSheet = !this.isShowSerialPickerSheet
        })
        .bindSheet($$this.isShowSerialPickerSheet,
          this.serialPickerSheetBuilder(this.playController.curentIndex, (index: number) => {
            Logger.info(TAG, `onIndexSelect:${index}`)
            this.isShowSerialPickerSheet = !this.isShowSerialPickerSheet
            if (CastService.getInstance().castStatusModel.isCasting && this.isLocked?.(index)) {
              PromptActionClass.setParam(new Params('当前视频解锁后，可投屏观看？', [{
                content: '退出投屏', action: () => {
                  PromptActionClass.closeDialog()
                  CastService.getInstance().endCasting()
                  this.playController?.changeIndex(index)
                }
              }, {
                content: '知道了', action: () => {
                  PromptActionClass.closeDialog()
                }
              }
              ]));
              PromptActionClass.setOptions({
                alignment: DialogAlignment.Center,
                maskColor: $r('sys.color.mask_fourth')
              });
              PromptActionClass.openDialog()
            } else {
              this.playController?.changeIndex(index)
            }

          }), {
            detents: [SheetSize.MEDIUM, SheetSize.LARGE, 600],
            preferType: SheetType.CENTER,
            showClose: false,
            enableHoverMode: true
          })
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  serialPickerSheetBuilder(curIndex: number, onIndexSelect: (index: number) => void) {
    Column() {
      SerialPicker({
        dramaInfo: this.dramaInfo,
        playController: this.playController,
        onIndexSelect: onIndexSelect,
        currentIndex: curIndex,
        spliceNum: 30,
        closeSheet: () => {
          this.isShowSerialPickerSheet = false
        }
      })
    }
  }

  getHover() {
    try {
      let orientation: display.Orientation = display.getDefaultDisplaySync().orientation;
      if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_HALF_FOLDED &&
        (orientation === display.Orientation.LANDSCAPE || orientation === display.Orientation.LANDSCAPE_INVERTED)
      ) {
        this.isHover = true;
      } else {
        this.isHover = false;
      }
    } catch (error) {
    }
  }
}