import { JSON, util } from '@kit.ArkTS';
import { BreakpointNameEnum, CommonConstants, OperateType, WindowUtil } from 'commonlib';
import { StickerShowModel } from '../model/PageParams';
import { Constants } from '../constant/Constants';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { ToolBarHeader } from './ToolBarHeader';
import { LayerType } from '../constant/Enum';

@ComponentV2
export struct StickerToolBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  @Local stickerTabIndex: number = 0;
  @Local currentStickerList: StickerShowModel[] = [];
  @Local stickerShowList: Map<string, StickerShowModel[]> = new Map<string, StickerShowModel[]>();

  @Computed
  get gridMaxHeight() {
    return this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 112 : 60;
  }

  aboutToAppear(): void {
    this.vm.currentStickerIndex = 0;
    WindowUtil.setGestureBackEnabled(false);
    this.getCurrentStickerList();
  }

  aboutToDisappear(): void {
    WindowUtil.setGestureBackEnabled(true);
  }

  async getCurrentStickerList() {
    this.currentStickerList =
      await this.getList(Constants.stickerTagListMap.get(Constants.stickerTagList[this.stickerTabIndex])!);
  }

  async getList(item: string): Promise<StickerShowModel[]> {
    let result: StickerShowModel[] = [];
    let value = await this.getUIContext().getHostContext()?.resourceManager.getRawFileList('sticker');

    if (value) {
      for (let i = 0; i < value.length; i++) {
        if (value[i].toString().includes(item)) {
          let path = 'sticker/' + value[i];
          let stickerShow: StickerShowModel = {
            imageSource: $rawfile(path),
            tag: [item],
          };
          result.push(stickerShow);
        }
      }
    }
    return result;
  }

  exitSticker() {
    // 切换操作时，图片需要复原位置和大小
    this.vm.matrix4TransitVM.resetImageTransform(() => {
      this.vm.operateType = OperateType.NONE;
    });
    this.stickerTabIndex = 0;
    this.vm.stickerList = [];
  }

  saveSticker() {
    this.vm.currentStickerIndex = -1;
    setTimeout(() => {
      this.vm.saveImage(LayerType.STICKER);
      this.exitSticker();
    }, 20)
  }

  build() {
    Column({ space: 16 }) {
      ToolBarHeader({
        close: () => {
          this.exitSticker();
        },
        confirm: () => {
          this.saveSticker()
        },
        centerBuilder: () => {
          this.stickerTitle();
        }
      })

      this.stickerContentBuilder()
    }
    .padding({ bottom: CommonConstants.PADDING_M })
    .borderRadius({ topLeft: 16, topRight: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  stickerTitle() {
    Row({ space: 32 }) {
      ForEach(Constants.stickerTagList, (item: string, index: number) => {
        Text(item)
          .fontWeight(this.vm.carouselCutTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
          .fontSize(16)
          .fontColor(this.stickerTabIndex === index ? $r('sys.color.multi_color_aux_01')  : Color.Black)
          .onClick(() => {
            this.stickerTabIndex = index;
            this.getCurrentStickerList();
          });
      }, (item: string) => item);
    }
  }

  @Builder
  stickerContentBuilder() {
    Grid() {
      ForEach(this.currentStickerList, (item: StickerShowModel) => {
        GridItem() {
          Stack() {
            Image(item.imageSource).size({ width: 40, height: 40 });
          }
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(8)
          .padding(4)
          .onClick(() => {
            this.vm.stickerList.push({
              id: util.generateRandomUUID(),
              positionX: 0,
              positionY: 0,
              img: item.imageSource,
            });
            this.vm.currentStickerIndex = this.vm.stickerList.length - 1;
          });
        };
      }, (item: StickerShowModel) => JSON.stringify(item));
    }
    .width(CommonConstants.FULL_PERCENT)
    .constraintSize({ maxHeight: this.gridMaxHeight })
    .scrollBar(BarState.Off)
    .columnsTemplate('repeat(auto-fit, 70)')
    .rowsGap(12)
    .columnsGap(12)
  }
}