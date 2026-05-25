/*
 * Copyright (c) 2026.
 */

@ObservedV2
export class NotesRefreshSignal {
  /**
   * 递增触发笔记列表刷新。
   * 用于平板/PC 分栏嵌入编辑时：保存笔记不会让首页重新 aboutToAppear，因此需要显式通知刷新。
   */
  @Trace tick: number = 0;
}

