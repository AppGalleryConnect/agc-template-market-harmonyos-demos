import { ImageMainPreviewBuilder } from '../default/ImageMainPreview';
import { ImagePreviewOptions } from '../models/ImagePreviewOptions';
import { PreviewCloseParam } from '../models/PreviewModel';
import { PromptActionTool } from '../utils/PromptActionTool';

export class ImagePreview {
  static open(uiContext: UIContext, options: ImagePreviewOptions): string {
    PromptActionTool.openCustomDialog(uiContext, {
      builder: wrapBuilder(ImageMainPreviewBuilder),
      params: options,
    })
    return options.dialogId
  }

  static close(params?: PreviewCloseParam) {
    PromptActionTool.closePreview(params)
  }
}