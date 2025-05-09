import {
  RouterMap,
  RouterModule,
  PickerResourceType,
  PickerPreviewItem,
} from 'commonlib';

@ObservedV2
export class FullScreenMediaVM {
  @Trace mediaType: PickerResourceType = PickerResourceType.IMAGE;
  @Trace imageResource: ResourceStr = '';
  @Trace videoResource: ResourceStr = '';
  @Trace audioResource: ResourceStr = '';
  private static _instance: FullScreenMediaVM;

  public static get instance() {
    if (!FullScreenMediaVM._instance) {
      FullScreenMediaVM._instance = new FullScreenMediaVM();
    }
    return FullScreenMediaVM._instance;
  }

  @Computed
  public get pageTitle() {
    const titleMap: Map<number, string> = new Map([
      [PickerResourceType.IMAGE, '图片预览'],
      [PickerResourceType.VIDEO, '视频预览'],
      [PickerResourceType.AUDIO, '音频播放'],
    ]);
    return titleMap.get(this.mediaType) ?? '';
  }

  public getMediaResource() {
    const param = RouterModule.getNavParam<PickerPreviewItem>({
      url: RouterMap.ACTIVITY_FULL_SCREEN_MEDIA,
    });
    if (param) {
      this.mediaType = param.type;
      if (this.mediaType === PickerResourceType.IMAGE) {
        this.imageResource = param.uri;
      } else if (this.mediaType === PickerResourceType.VIDEO) {
        this.videoResource = param.uri;
      } else if (this.mediaType === PickerResourceType.AUDIO) {
        this.audioResource = param.uri;
      }
    }
  }

}