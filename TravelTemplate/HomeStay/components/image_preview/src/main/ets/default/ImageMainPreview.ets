import { ImagePreviewComponent } from '../components/ImagePreviewComponent';
import { PreviewConstants } from '../constants/Constants';
import { ImagePreviewOptions } from '../models/ImagePreviewOptions';

@ComponentV2
export struct ImageMainPreview {
  @Param option: ImagePreviewOptions = new ImagePreviewOptions()

  build() {
    ImagePreviewComponent({
      options: this.option,
      topBuilder: this.option.topBuilder,
      bottomBuilder: this.option.bottomBuilder,
    })
      .width(PreviewConstants.FULL_SIZE)
      .height(PreviewConstants.FULL_SIZE)
  }
}

@Builder
export function ImageMainPreviewBuilder(option: ImagePreviewOptions) {
  ImageMainPreview({
    option: option,
  })
}