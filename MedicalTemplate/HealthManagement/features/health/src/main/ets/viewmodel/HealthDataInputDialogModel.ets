@ObservedV2
export class HealthDataInputDialogModel {
  @Trace title: ResourceStr = '';
  @Trace value: number = 0;
  @Trace unit: string = '';
  onValueConfirmClick = (_model: HealthDataInputDialogModel) => {
  };
}