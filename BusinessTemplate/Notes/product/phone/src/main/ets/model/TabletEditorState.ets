/*
 * Copyright (c) 2026.
 */

@ObservedV2
export class TabletEditorState {
  /** 平板分栏：右侧嵌入编辑器模式 */
  @Trace embedMode: boolean = false;
  /** 平板分栏：当前选中的笔记 ID（右侧展示/编辑） */
  @Trace selectedNoteId: string = '';
  /** 新建草稿：分类（尚未入库，getNoteById 查不到时在 EditNotes 写入 currentNote） */
  @Trace pendingNewNoteCategoryId: string = '';
  /** 新建草稿：是否从录音入口进入 */
  @Trace pendingIsRecordingNote: boolean = false;
  /** 分栏编辑：切换笔记时，待切换的目标 noteId（用于二次确认后继续） */
  @Trace pendingSwitchNoteId: string = '';
}

