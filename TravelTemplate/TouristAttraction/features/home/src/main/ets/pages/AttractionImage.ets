import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum, BreakpointType, Constant, GridRowColSetting } from 'common';
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';
import { TitleBar } from 'uicomponents';

@Builder
export function AttractionImageBuilder() {
  AttractionImage();
}

@ComponentV2
export struct AttractionImage {
  @Local detailImages: ResourceStr[] = [];
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local resources: SourceImageModel[] = [];
  options: ImagePreviewOptions = new ImagePreviewOptions();

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '图片/视频', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Grid() {
          ForEach(this.detailImages, (item: ResourceStr, index: number) => {
            GridItem() {
              Image(item)
                .width('100%')
                .aspectRatio(1)
                .objectFit(ImageFit.Cover)
                .id(this.options.snapshotId(item, index))
                .onClick(() => {
                  this.options
                    .setImageList(this.resources)
                    .setInitIndex(index);
                  ImagePreview.open(this.getUIContext(), this.options);
                });
            };
          }, (item: ResourceStr) => item.toString());
        }
        .columnsTemplate(new BreakpointType({
          [BreakpointNameEnum.SM]: '1fr '.repeat(3),
          [BreakpointNameEnum.MD]: '1fr '.repeat(5),
          [BreakpointNameEnum.LG]: '1fr '.repeat(8),
          [BreakpointNameEnum.XL]: '1fr '.repeat(8),
        }).getValue(this.breakPointModel.currentBreakpoint))
        .columnsGap(GridRowColSetting.getGutter(this.breakPointModel.currentBreakpoint))
        .rowsGap(2)
        .width(Constant.FULL_PERCENT)
        .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding, top: 8 });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.detailImages = context.pathInfo.param as ResourceStr[];
      this.resources = this.detailImages.map((imageUrl) => {
        return new SourceImageModel({ imageUrl });
      });
    });
  }
}