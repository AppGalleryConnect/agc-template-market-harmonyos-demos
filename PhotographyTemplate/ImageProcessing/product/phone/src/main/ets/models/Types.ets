export interface TabListItem {
  label: string;
  icon: Resource;
  iconChecked: Resource;
  component: WrappedBuilder<[]>;
}

/**
 * want-跳转模型
 */
@ObservedV2
export class FormCardJumpModel {
  @Trace formCardId: string = '';
  @Trace formCardPageUrl: string = '';
  @Trace shortcutId: string = '';
  @Trace shortcutPageUrl: string = '';
  @Trace pageParam: string = '';
}