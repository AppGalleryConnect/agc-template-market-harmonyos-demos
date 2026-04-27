@ObservedV2
export class HealthKnowledgeSingleModel {
  @Trace img: PixelMap | ResourceStr | DrawableDescriptor = ''
  @Trace title: string = '';
  @Trace subTitle: string = '';
  @Trace content: string = '';
}