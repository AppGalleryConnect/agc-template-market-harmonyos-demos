import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview';

@Builder
export function ImagePreviewPageBuilder() {
  ImagePreviewPage()
}

@ComponentV2
struct ImagePreviewPage {
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local pathParams: ImagePreviewRouter = new ImagePreviewRouter();

  build() {
    NavDestination()
      .hideTitleBar(true)
      .onReady((context) => {
        this.pathStack = context.pathStack;
        this.pathParams = context.pathInfo.param as ImagePreviewRouter;
        this.openPreviewDialog();
      })
  }

  openPreviewDialog() {
    const options = new ImagePreviewOptions()
    options.setImageList(this.pathParams.srcList.map(v => new SourceImageModel({ imageUrl: v })))
      .setInitIndex(this.pathParams.index)
      .setLoop(true)
      .setLongTake(false)
      .setPreviewListener({
        onBack: () => {
          this.pathStack.pop(false);
        },
      })
    ImagePreview.open(this.getUIContext(), options);
  }
}

class ImagePreviewRouter {
  srcList: string[] = [];
  index: number = 0;
}