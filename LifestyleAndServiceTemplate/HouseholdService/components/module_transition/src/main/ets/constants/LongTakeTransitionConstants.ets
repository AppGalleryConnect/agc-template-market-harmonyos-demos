export class LongTakeTransitionConstants {
  public static CONFIGURATION_UPDATE = 'ezCustomTransition_OnConfigurationUpdate';

  public static POST_PAGE_STACK_ID = 'ezCustomTransition_PostPage_StackId';

  public static POST_PAGE_SNAPSHOT_STACK_ID = 'ezCustomTransition_PostPage_SnapShot_StackId';

  public static ON_WINDOW_SIZE_CHANGED = 'ezCustomTransition_OnWindowSizeChanged';

  public static WINDOW_SIZE = 'ezCustomTransition_WindowSize';
}

export enum LongTakeTransitionType {
  // 一镜到底卡片与目标页组件做顶部对齐
  CardLongTake = 0,

  // 一镜到底卡片与目标页组件做中部对齐
  ImageLongTake
}