@ObservedV2
export class HealthCardModel {
  @Trace img: PixelMap | ResourceStr | DrawableDescriptor = ''
  @Trace title: string = '';
  @Trace type: number = 1;
  @Trace value: string = '';
  @Trace diastolicValue?: string = '';
  @Trace desc: string = '';
  @Trace icon: PixelMap | ResourceStr | DrawableDescriptor = '';
  @Trace timeStatus: string = '';
}

