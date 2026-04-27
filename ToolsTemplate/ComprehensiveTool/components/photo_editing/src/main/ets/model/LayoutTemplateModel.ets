@ObservedV2
export class LayoutRegion {
  @Trace path: string = '' // SVG Path
}

@ObservedV2
export class LayoutTemplateModel {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace image?: Resource
  @Trace selectedImage?: Resource
  @Trace count: number = 0
  @Trace width: string = '100%'
  @Trace height: string = 'calc(100% - 160vp)'
  @Trace regions: LayoutRegion[] = []
}
