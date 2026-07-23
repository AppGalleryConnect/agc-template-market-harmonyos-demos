import { UtilLog } from '@hw-agconnect/util-log';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { SourceImageModel } from '../models/PreviewModel';

const TAG = '[MovingPhotoVM]'

@ObservedV2
export class MovingPhotoVM {
  imageFileUri: string | undefined = undefined
  videoFileUri: string | undefined = undefined
  context: UIContext
  @Trace movingPhoto: photoAccessHelper.MovingPhoto | undefined

  constructor(context: UIContext) {
    this.context = context
  }

  setResource(imageSrc: SourceImageModel) {
    this.imageFileUri = imageSrc?.imageUrl as string
    this.videoFileUri = imageSrc?.videoUrl
    this.movingPhoto = imageSrc?.movingPhoto
  }

  /**
   * 优先取用movingPhoto对象
   * 否则使用沙箱路径组合成movingPhoto对象
   * */
  async getMovingPhoto() {
    if (!this.movingPhoto) {
      try {
        let movingPhoto =
          await photoAccessHelper.MediaAssetManager.loadMovingPhoto(this.context.getHostContext(), this.imageFileUri,
            this.videoFileUri);
        this.movingPhoto = movingPhoto
        UtilLog.info(TAG, 'load moving photo successfully');
      } catch (err) {
        UtilLog.error(TAG, `load moving photo failed with error: ${err.code}, ${err.message}`);
      }
    }
  }
}