export interface TabListItem {
  label: string;
  icon: Resource;
  iconChecked: Resource;
  component: WrappedBuilder<[]>;
}

@ObservedV2
export class FormModel {
  @Trace id: number = 0
  @Trace url: string = ''
}

@ObservedV2
export class FormCardJump {
  @Trace form: FormModel = new FormModel()
}