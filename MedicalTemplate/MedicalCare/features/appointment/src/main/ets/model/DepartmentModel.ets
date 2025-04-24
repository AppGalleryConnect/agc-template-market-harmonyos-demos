@ObservedV2
export class DepartmentModel {
  @Trace id: string = ''
  @Trace name: string = ''
  @Trace children: DepartmentModel[] = []
}