import { PHOTO_FRAMES } from '../constant/PhotoFrameData';
import { CanvasTextItem } from './BeautificationParam';
import ImageModel from './ImageModel';
import { PhotoFrameModel } from './PhotoFrameModel';

export interface TextEditDialogParams {
  cloneText: string
  canvasItemStack: CanvasTextItem
  close: Function
}

export class DisPlaySize {
  width: number = 0;
  height: number = 0;
}

@ObservedV2
export class ImageVM {
  @Trace id: string = ''
  @Trace src: string = ''
  @Trace x: number = 0
  @Trace y: number = 0
  @Trace width: number = 100
  @Trace height: number = 100
  @Trace scale: number = 1
  @Trace rotate: number = 0

  updateFromModel(model: ImageModel) {
    this.id = model.id
    this.src = model.src
    this.x = model.x
    this.y = model.y
    this.width = model.width
    this.height = model.height
    this.scale = model.scale
    this.rotate = model.rotate
  }
}

@ObservedV2
export default class PhotoFrameVM {
  @Trace photoFrame: PhotoFrameModel = PHOTO_FRAMES[0]

  selectFrame(frame: PhotoFrameModel) {
    this.photoFrame = frame
  }
}

@ObservedV2
export class FilterEdit {
  @Trace isEdit: boolean = true;
}
