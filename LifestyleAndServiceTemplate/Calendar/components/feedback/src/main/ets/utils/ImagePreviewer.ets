import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'image_preview'
import { IDGenerator } from '../common/CustomTypes';

@ObservedV2
export class ImagePreviewer {

  private _uiContext: UIContext;

  private _options: ImagePreviewOptions = new ImagePreviewOptions();

  private _sourceImageModels: SourceImageModel[] = [];

  @Trace
  public previewIndex: number = -1;

  public updateImagesByUris(uris: string[]): ImagePreviewer {
    const models: SourceImageModel[] = [];
    for (const uri of uris) {
      models.push(new SourceImageModel({
        imageUrl: uri
      }));
    }
    this._sourceImageModels = models;
    return this;
  }

  public previewImage(index: number, idGenerator: IDGenerator): void {
    this._options
      .setLongTake(true)
      .setSnapshotId(idGenerator)
      .setImageActionListener({
        onPageChanged: (_: SourceImageModel, index: number) => {
          this.previewIndex = index;
        }
      })
      .setPreviewListener({
        onBack: () => this.previewIndex = -1,
      })
      .setImageList(this._sourceImageModels)
      .setInitIndex(index);
    ImagePreview.open(this._uiContext, this._options);
  }

  constructor(uiContext: UIContext) {
    this._uiContext = uiContext;
  }
}
