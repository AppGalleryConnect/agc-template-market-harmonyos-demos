@ObservedV2
export class ExportStateVM {
  @Trace exportState: string | Resource = ''; //'starting finish '
  @Trace completeValue: number = 0;
  @Trace fileSize: number = 0
  @Trace speedValue: number = 0
}
