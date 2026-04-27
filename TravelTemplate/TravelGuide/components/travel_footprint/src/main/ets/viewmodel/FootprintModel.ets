@ObservedV2
export class FootPrintItem {
  @Trace id: string = ''
  @Trace city: string = ''
  @Trace img: ResourceStr = ''
  @Trace year: string = ''
}

@ObservedV2
export class FootPrintList {
  @Trace year: string = ''
  @Trace list: FootPrintItem[] = []
}