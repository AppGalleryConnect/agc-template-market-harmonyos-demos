/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  ACTION_NAME,
  ChangeRecord,
  MORE_ACTION_LIST,
  MoreFunction,
  Note,
  RichEditorArea,
  RichEditorController,
  SNAPSHOT_ID,
  SnapShotController,
} from 'richeditor';
import { AppStorageV2, KeyboardAvoidMode } from '@kit.ArkUI';
import { Category, NoteService } from '@ohos_agcit/notes_datasource';
import { ThemeController } from '../controller/ThemeController';
import { unifiedDataChannel } from '@kit.ArkData';
import { pasteboard, BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { KVStore, SerializeUtil } from 'serializer';
import common from '@ohos.app.ability.common';
import { GesturesShareService, NoteSharePayload } from 'grabthransfer';
import { ContinueModel, ContinueUtils } from 'continue';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { commentManager } from '@kit.AppGalleryKit';
import { AppUtil } from '@ohos_agcit/notes_utils';
import { HandwriteController } from '@kit.Penkit';
import { AudioRecordHelper } from '../utils/AudioRecordHelper';
import { fileIo } from '@kit.CoreFileKit';
import { Constants as VoiceAudioConstants } from '../utils/VoiceAudioConstants';
import { TabletEditorState } from '../model/TabletEditorState';
import { NotesRefreshSignal } from '../model/NotesRefreshSignal';

@Builder
export function EditNotesBuilder() {
  EditNotes();
}

@ComponentV2
struct EditNotes {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Consumer() kvStore: KVStore | undefined = undefined;
  @Local tabletEditorState: TabletEditorState =
    AppStorageV2.connect(TabletEditorState, 'tabletEditorState', () => new TabletEditorState())!;
  @Local notesRefreshSignal: NotesRefreshSignal =
    AppStorageV2.connect(NotesRefreshSignal, 'notesRefreshSignal', () => new NotesRefreshSignal())!;
  @Local continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  @Local handwriteController: HandwriteController = new HandwriteController();
  @Local isContinueRestored: boolean = false; // 接续是否已恢复
  @Local hasShownRateDialog: boolean = false; // 本次会话是否已弹出过评分
  richEditorController: RichEditorController = RichEditorController.instance;
  themeController: ThemeController = ThemeController.instance;
  noteService: NoteService = NoteService.instance;
  snapShotController: SnapShotController = new SnapShotController(SNAPSHOT_ID, new Scroller(), this.getUIContext());
  uiContext: UIContext = this.getUIContext() as UIContext;
  hostContext: common.Context = this.uiContext.getHostContext() as Context;
  @Local currentNote: Note = new Note(new MutableStyledString(''));
  @Local noteTitle: string = '';
  @Local isEditNote: boolean = false;
  /** 是否为录音笔记（从首页麦克风入口进入或笔记类型为录音） */
  @Local isRecordingNote: boolean = false;
  @Local showRecordingBar: boolean = false;
  audioRecordHelper: AudioRecordHelper = new AudioRecordHelper();
  @Local isRecording: boolean = false;
  @Local isPlaying: boolean = false;
  @Local playCurrentMs: number = 0;
  @Local playDurationMs: number = 0;
  @Local recordDurationSec: number = 0;
  recordTimerId: number = -1;
  @Local fileSize: number = 0;
  playTimerId: number = -1;
  // 隔空传送服务
  private gesturesShareService: GesturesShareService = GesturesShareService.getInstance();
  private noteSharePayloadCache: string | null = null;
  private noteShareCacheTimerId: number = -1;

  private initFromNoteId(noteId: string, isRecordingNoteParam: boolean = false): void {
    if (!noteId) {
      return;
    }
    this.isEditNote = true;
    const note = this.noteService.getNoteById(noteId);
    if (note) {
      this.tabletEditorState.pendingNewNoteCategoryId = '';
      this.tabletEditorState.pendingIsRecordingNote = false;
      this.currentNote = note;
      this.noteTitle = note.title;
      this.isRecordingNote = note.noteType === 'recording';
    } else {
      this.isEditNote = false;
      this.currentNote = new Note(new MutableStyledString(''));
      this.currentNote.id = noteId;
      this.currentNote.handwriteFileName = `handwrite_${noteId}`;
      if (this.tabletEditorState.pendingNewNoteCategoryId !== '') {
        this.currentNote.categoryId = this.tabletEditorState.pendingNewNoteCategoryId;
      }
      const fromPendingRecording = this.tabletEditorState.pendingIsRecordingNote;
      this.tabletEditorState.pendingNewNoteCategoryId = '';
      this.tabletEditorState.pendingIsRecordingNote = false;
      this.noteTitle = '';
      this.isRecordingNote = fromPendingRecording || isRecordingNoteParam;
      ContinueUtils.disableContinue(this.hostContext as common.UIAbilityContext);
    }
    // 打开已有录音的笔记时，自动展示录音条
    this.showRecordingBar = this.isRecordingNote || (this.currentNote.audioUri !== '');

    // 初始化历史记录（用于撤销/重做）
    this.richEditorController.currentIndex = 0;
    this.richEditorController.historyRecordArray = [];
    this.richEditorController.historyRecordArray.push(new ChangeRecord(this.currentNote.styledString));

    // 更新接续数据
    if (this.isEditNote && this.currentNote.id) {
      ContinueUtils.updateContinueData(this.currentNote.id, this.currentNote.title);
    }
  }

  @Monitor('tabletEditorState.selectedNoteId')
  private onTabletSelectedNoteIdChange(): void {
    const noteId = this.tabletEditorState.selectedNoteId;
    if (!noteId) {
      return;
    }
    if (this.currentNote?.id === noteId) {
      return;
    }
    this.initFromNoteId(noteId);
  }

  aboutToAppear(): void {
    // 启用压缩模式避让软键盘
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET);

    this.getUIContext().getUIObserver().on('navDestinationSwitch', (info) => {
      if (info.to === 'navBar') {
        // 还原默认上抬模式
        this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
      }
    });

    // 开启隔空传送监听
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.gesturesShareService = GesturesShareService.getInstance(context);
    this.gesturesShareService.startGestureListening();
    // 初始化录音上下文
    this.audioRecordHelper.setContext(context);

    // 保存当前笔记的接续状态
    if (this.isEditNote && this.currentNote.id) {
      ContinueUtils.updateContinueData(this.currentNote.id, this.currentNote.title);
    }

    // 检查并处理接续场景（目标端）
    if (ContinueUtils.isContinueScene()) {
      this.handleContinueRestore();
    }

    // 定时刷新隔空传送缓存，手势时同步取缓存即可传内容
    this.noteShareCacheTimerId = setInterval(() => {
      this.refreshNoteSharePayloadCache();
    }, 2000);
    this.refreshNoteSharePayloadCache();

    // 分栏右侧嵌入：首次进入时根据选中的 noteId 初始化
    if (this.tabletEditorState.selectedNoteId && this.currentNote?.id !== this.tabletEditorState.selectedNoteId) {
      this.initFromNoteId(this.tabletEditorState.selectedNoteId);
    }
  }

  aboutToDisappear(): void {
    this.richEditorController.currentIndex = -1;
    // 操作记录
    this.richEditorController.historyRecordArray = [];
    this.richEditorController.initState();
    // 取消监听
    this.getUIContext().getUIObserver().off('navDestinationSwitch');

    if (this.noteShareCacheTimerId >= 0) {
      clearInterval(this.noteShareCacheTimerId);
      this.noteShareCacheTimerId = -1;
    }
    this.noteSharePayloadCache = null;
    this.gesturesShareService.setNotePayloadGetter(undefined);
    this.gesturesShareService.stopGestureListening();

    // 停止录音和播放，清理计时器
    this.getUIContext().getUIObserver().off('navDestinationSwitch');
    if (this.recordTimerId >= 0) {
      clearInterval(this.recordTimerId);
      this.recordTimerId = -1;
    }
    if (this.playTimerId >= 0) {
      clearInterval(this.playTimerId);
      this.playTimerId = -1;
    }
    this.audioRecordHelper.stopRecord();
    this.audioRecordHelper.stopPlay();

    // 清除接续标记（如果是目标端）
    if (this.continueModel.isTargetDevice) {
      ContinueUtils.clearContinueFlag();
    }

    // 确保页面退出时恢复默认避让模式
    AppUtil.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  /**
   * 刷新隔空传送缓存（定时调用），手势时同步返回此缓存即可传内容
   */
  private refreshNoteSharePayloadCache(): void {
    const note = this.currentNote;
    SerializeUtil.serialize(note.styledString, this.getUIContext()).then((serializedStyledString: string) => {
      const payload: NoteSharePayload = {
        title: note.title || '我的笔记',
        categoryId: note.categoryId || '-1',
        serializedStyledString,
        description: note.description || '',
        createTime: note.createTime || '',
        updateTime: note.updateTime || '',
      };
      try {
        this.noteSharePayloadCache = JSON.stringify(payload);
      } catch (err) {
        let error = err as Error;
        hilog.error(0x0000, 'EditNotes', `JSON序列化失败: ${error.message}`);
        throw new Error(`序列化分享数据失败: ${error.message}`);
      }
    }).catch(() => {
      this.noteSharePayloadCache = null;
    });
  }

  /**
   * 处理接续恢复（目标端）
   */
  private handleContinueRestore(): void {
    const continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;

    if (!continueModel.noteId) {
      return;
    }

    // 1. 加载接续的笔记
    const note = this.noteService.getNoteById(continueModel.noteId);
    if (!note) {
      this.showToast('接续的笔记不存在或已删除');
      ContinueUtils.clearContinueFlag();
      return;
    }

    // 2. 更新当前笔记
    this.currentNote = note;
    this.noteTitle = note.title;
    this.isEditNote = true;

    // 3. 显示接续提示
    setTimeout(() => {
      this.showToast(`已接续到笔记: ${continueModel.noteTitle}`);
    }, 300);

    // 4. 清除接续标记（在页面加载完成后）
    setTimeout(() => {
      ContinueUtils.clearContinueFlag();
    }, 1000);
  }

  /**
   * 从控制器获取对齐方式
   */
  private getTextAlignFromController(): TextAlign {
    switch (this.richEditorController.currentAlignment) {
      case 0:
        return TextAlign.Start;
      case 1:
        return TextAlign.Center;
      case 2:
        return TextAlign.End;
      case 3:
        return TextAlign.JUSTIFY;
      default:
        return TextAlign.Start;
    }
  }

  /**
   * 显示提示
   */
  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({
      message: message,
      alignment: Alignment.Center,
      duration: 2000,
    });
  }

  /**
   * 删除当前录音（
   */
  private async deleteCurrentRecording(): Promise<void> {
    const audioUri = this.currentNote?.audioUri;
    if (!audioUri) {
      return;
    }

    // 先停止播放/计时器，避免删除中读文件
    if (this.playTimerId >= 0) {
      clearInterval(this.playTimerId);
      this.playTimerId = -1;
    }
    this.isPlaying = false;
    this.playCurrentMs = 0;
    this.playDurationMs = 0;
    AppStorage.setOrCreate('RWOffset', 0);
    AppStorage.setOrCreate('AudioAtEnd', false);
    await this.audioRecordHelper.stopPlay();

    // 删除录音文件
    try {
      const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const filePath = `${ctx.cacheDir}/${audioUri}.pcm`;
      fileIo.unlinkSync(filePath);
    } catch (e) {
      // 文件可能已不存在；仍继续清理笔记字段。日志链路单独 try，避免 stringify/hilog throws 导致崩溃
      let detail = '';
      try {
        detail = JSON.stringify(e);
      } catch (_) {
        detail = '<<unserializable>>';
      }
      try {
        hilog.warn(0x0000, 'EditNotes', `delete recording file failed: ${detail}`);
      } catch (_) {
      }
    }

    // 清理笔记字段并持久化
    this.currentNote.audioUri = '';
    // 删除录音后，退出录音笔记模式并隐藏录音条（只能从工具栏录音入口重新打开）
    this.isRecordingNote = false;
    this.showRecordingBar = false;
    this.currentNote.noteType = 'normal';
    this.fileSize = 0;
    if (this.isEditNote) {
      this.noteService.updateNote(this.currentNote, this.kvStore, this.uiContext, this.hostContext);
    }
    this.showToast('已删除');
  }

  /**
   * 录音删除二次确认
   */
  private confirmDeleteRecording(): void {
    this.uiContext.showAlertDialog({
      title: '删除录音',
      message: '确认删除当前录音吗？删除后不可恢复。',
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        enabled: true,
        defaultFocus: true,
        style: DialogButtonStyle.DEFAULT,
        fontColor: Color.Red,
        value: '删除',
        action: async () => {
          await this.deleteCurrentRecording();
        },
      },
    });
  }

  /**
   * 将秒数格式化为 00:00:00
   */
  formatTime(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = Math.floor(seconds % 60);
    return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  /**
   * 播放进度（秒）
   */
  getPlayCurrentSec(): number {
    return Math.floor(this.playCurrentMs / 1000);
  }

  /**
   * 播放总时长（秒）
   */
  getPlayTotalSec(): number {
    return Math.floor(this.playDurationMs / 1000);
  }

  copyNoteText() {
    if (this.currentNote?.description === '') {
      this.getUIContext().getPromptAction().showToast({
        message: '请输入内容后复制！',
        alignment: Alignment.Center,
        duration: 1500,
      });
      return;
    }
    let copyText = this.currentNote?.description || '';
    let plainTextData = new unifiedDataChannel.UnifiedData();
    let plainText = new unifiedDataChannel.PlainText();
    plainText.details = {
      key: 'delayPlaintext',
      value: copyText,
    };
    plainText.textContent = copyText;
    plainText.abstract = 'delayTextContent';
    plainTextData.addRecord(plainText);
    let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setUnifiedData(plainTextData);
    this.getUIContext().getPromptAction().showToast({
      message: '复制成功',
      alignment: Alignment.Center,
      duration: 1500,
    });
  }

  /**
   * 显示更多选项视图
   */
  @Builder
  moreFunctionMenu() {
    Column() {
      List() {
        ForEach(MORE_ACTION_LIST, (item: MoreFunction) => {
          ListItem() {
            Row() {
              Image(item.icon)
                .width(24)
                .height(24)
                .margin({
                  left: 12,
                  right: 8,
                });

              Text(item.name)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'));
            }
            .width('100%')
            .height(48)
            .onClick(() => {
              if (item.name === ACTION_NAME.share) {
                this.snapShotController.onceSnapshot();
              } else if (item.name === ACTION_NAME.copy) {
                this.copyNoteText();
              }
            });
          };
        },  (item: MoreFunction) => {
          try {
            return JSON.stringify(item);
          } catch (err) {
            hilog.error(0x0000, 'EditNotes', `JSON.stringify失败: ${(err as Error).message}`);
            return '';
          }
        });
      }
      .divider({
        strokeWidth: 0.5,
      })
      .scrollBar(BarState.Off);
    }
    .width(114)
    .backgroundColor($r('app.color.bg_more_function'))
    .margin({ top: 4, bottom: 4 });
  }

  @Builder
  toolBar() {
    if (this.richEditorController.showMoreFunction === true) {
      Row() {
        Image($r('app.media.show_more_function'))
          .width(40)
          .height(40)
          .bindMenu(this.moreFunctionMenu);
      }
      .height('100%')
      .width(150)
      .justifyContent(FlexAlign.End)
      .margin({
        right: this.tabletEditorState.embedMode ? 0 : 16,
      });
    } else {
      Row({ space: 12 }) {
        Image(this.richEditorController.currentIndex < 1 ? $r('app.media.undo_expire') : $r('app.media.undo_effect'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.richEditorController.onDo();
          });

        Image(this.richEditorController.currentIndex >= this.richEditorController.historyRecordArray.length - 1 ?
          $r('app.media.redo_expire') : $r('app.media.redo_effect'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.richEditorController.reDo();
          });

        Image($r('app.media.save'))
          .height(40)
          .width(40)
          .onClick(async () => {
            let isSucc = await this.saveNote();
            if (isSucc) {
              hilog.debug(0x0000, 'EditNotes', 'saveNote succeeded');
              // 点击保存后退出选中状态
              this.richEditorController.controller.setSelection(0, 0);
              // 退出编辑状态
              this.richEditorController.textInputController.stopEditing();
              this.richEditorController.controller.stopEditing();
              // 退出手写模式，进入展示态后禁止继续画画
              this.richEditorController.isHandwriteMode = false;
              this.richEditorController.showMoreFunction = true;
            } else {
              hilog.debug(0x0000, 'EditNotes', 'saveNote returned false');
            }
          });
      }
      .height('100%')
      .width(150)
      .justifyContent(FlexAlign.Center)
      .margin({
        right: this.tabletEditorState.embedMode ? 0 : 16,
      });
    }
  }

  private isCurrentHandwriteDirty(): boolean {
    const dirty = AppStorage.get<boolean>('handwrite_dirty');
    const noteId = AppStorage.get<string>('handwrite_dirty_note_id');
    return dirty === true && noteId === this.currentNote.id;
  }

  private isEmbedEditorDirty(): boolean {
    const dirty = AppStorage.get<boolean>('notes_embed_dirty');
    const noteId = AppStorage.get<string>('notes_embed_dirty_note_id');
    return dirty === true && noteId === this.currentNote.id;
  }

  private clearEmbedEditorDirty(): void {
    const noteId = AppStorage.get<string>('notes_embed_dirty_note_id');
    if (noteId === this.currentNote.id) {
      AppStorage.setOrCreate('notes_embed_dirty', false);
    }
  }

  /**
   * 保存笔记
   */
  async saveNote(): Promise<boolean> {
    let styledString: MutableStyledString = this.richEditorController.controller.getStyledString();
    let content = styledString.getString();
    const hasTextOrTitle = !(content === '' && this.noteTitle === '');
    const hadHandwriteDirty = this.isCurrentHandwriteDirty();

    // 保存手写内容（无论是否处于手写模式，只要画布有改动就应保存）
    if (this.handwriteController && this.currentNote.id && hadHandwriteDirty) {
      try {
        const handwritePath = this.hostContext.filesDir + '/' + `handwrite_${this.currentNote.id}`;
        await this.handwriteController.save(handwritePath);
        hilog.info(0x0000, 'EditNotes', '手写内容已保存');
        AppStorage.setOrCreate('handwrite_dirty_note_id', this.currentNote.id);
        AppStorage.setOrCreate('handwrite_dirty', false);
      } catch (error) {
        let detail = '';
        try {
          detail = JSON.stringify(error);
        } catch (_) {
          detail = '<<unserializable>>';
        }
        try {
          hilog.error(0x0000, 'EditNotes', `保存手写内容失败: ${detail}`);
        } catch (_) {
        }
      }
    }

    if (!hasTextOrTitle && !hadHandwriteDirty) {
      return this.isEditNote ? false : true;
    }

    if (this.isEditNote) {
      if (hasTextOrTitle) {
        this.currentNote.updateContent(styledString, this.noteTitle);
      }
      // 更新录音笔记类型与音频路径
      this.currentNote.noteType = this.isRecordingNote ? 'recording' : 'normal';
      this.noteService.updateNote(this.currentNote, this.kvStore, this.uiContext, this.hostContext);
    } else {
      this.currentNote.title = this.noteTitle;
      this.currentNote.styledString = this.richEditorController.controller.getStyledString();
      this.currentNote.description = this.currentNote.styledString.getString();
      this.currentNote.handwriteFileName = `handwrite_${this.currentNote.id}`;
       // 新建时根据入口设置笔记类型
      this.currentNote.noteType = this.isRecordingNote ? 'recording' : 'normal';
      this.noteService.addNote(this.currentNote, this.kvStore, this.uiContext);
      this.isEditNote = true;

      // 全局第一次新建笔记并成功保存后，尝试拉起应用内评分弹窗
      this.showRateDialogOnce();
    }

    if (this.tabletEditorState.embedMode) {
      this.notesRefreshSignal.tick = this.notesRefreshSignal.tick + 1;
    }

    // 更新接续数据（确保当前笔记可以作为源端接续）
    if (this.isEditNote && this.currentNote.id) {
      ContinueUtils.updateContinueData(this.currentNote.id, this.currentNote.title);
    }

    this.clearEmbedEditorDirty();

    return true;
  }

  /**
   * 全局仅在第一次新建笔记成功后拉起评分弹窗
   */
  private async showRateDialogOnce(): Promise<void> {
    // 本页会话内已弹出过，直接返回
    if (this.hasShownRateDialog) {
      return;
    }

    // 先检查全局持久化标记，已弹出过则不再弹
    try {
      if (this.kvStore) {
        const record = await this.kvStore.get('rateDialogShown');
        if (record && record.value === true) {
          this.hasShownRateDialog = true;
          return;
        }
      }
    } catch (error) {
      hilog.error(0x0000, 'EditNotes', 'check rateDialogShown flag failed: %{public}s',
        (error as BusinessError)?.message ?? '');
    }

    this.hasShownRateDialog = true;
    try {
      const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await commentManager.showCommentDialog(ctx);
      // 调用成功后，写入全局标记，后续不再弹出
      if (this.kvStore) {
        await this.kvStore.put('rateDialogShown', true);
      }
    } catch (error) {
      hilog.error(0x0000, 'EditNotes', 'showCommentDialog failed: %{public}s',
        (error as BusinessError)?.message ?? '');
    }
  }

  backDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.backDialog();
    },
    alignment: DialogAlignment.Center,
  });


  /** 录音笔记：录音/播放条 */
  @Builder
  recordingBar() {
    Column({ space: 12 }) {
      Row({ space: 16 }) {
        // 左侧录音/停止/播放按钮
        if (!this.currentNote.audioUri && !this.isRecording) {
          Button({ type: ButtonType.Normal }) {
            SymbolGlyph($r('sys.symbol.play_fill'))
              .fontSize(24)
              .fontColor([Color.White]);
          }
          .width(44)
          .height(44)
          .borderRadius(22)
          .onClick(async () => {
            const granted = await this.audioRecordHelper.requestMicrophonePermission();
            if (!granted) {
              this.getUIContext().getPromptAction().showToast({
                message: '需要麦克风权限才能录音',
                alignment: Alignment.Center,
                duration: 2000,
              });
              return;
            }
            this.recordDurationSec = 0;
            const path = await this.audioRecordHelper.startRecord();
            if (path) {
              this.isRecording = true;
              this.recordTimerId = setInterval(() => {
                this.recordDurationSec++;
              }, 1000);
            }
          });
        } else if (this.isRecording) {
          Button({ type: ButtonType.Normal }) {
            SymbolGlyph($r('sys.symbol.AI_circle_viewfinder'))
              .fontSize(24)
              .fontColor([Color.White]);
          }
          .width(44)
          .height(44)
          .backgroundColor('#E74C3C')
          .borderRadius(22)
          .onClick(async () => {
            await this.audioRecordHelper.stopRecord();
            this.isRecording = false;
            if (this.recordTimerId >= 0) {
              clearInterval(this.recordTimerId);
              this.recordTimerId = -1;
            }
            const fileName = this.audioRecordHelper.getRecordFilePath();
            if (fileName) {
              // 这里只保存文件名（不带路径与后缀），播放时由 AudioRecordHelper 在 cacheDir 下查找同名 pcm
              this.currentNote.audioUri = fileName;
              // 计算文件总大小，用于进度条和总时长
              const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
              const pathDir = ctx.cacheDir;
              const filePath = `${pathDir}/${fileName}.pcm`;
              this.fileSize = fileIo.statSync(filePath).size;
              this.playCurrentMs = 0;
              if (this.fileSize > 0) {
                const bytesPerSec = VoiceAudioConstants.SAMPLING_RATE * VoiceAudioConstants.SAMPLE_BYTE *
                  VoiceAudioConstants.CHANNEL_NUM;
                const totalSec = this.fileSize / bytesPerSec;
                this.playDurationMs = totalSec * 1000;
              } else {
                this.playDurationMs = 0;
              }
            }
          });
        } else {
          Button({ type: ButtonType.Normal }) {
            SymbolGlyph(this.isPlaying ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
              .fontSize(24)
              .fontColor([Color.White]);
          }
          .width(44)
          .height(44)
          .borderRadius(22)
          .onClick(async () => {
            if (this.isPlaying) {
              await this.audioRecordHelper.pausePlay();
              this.isPlaying = false;
              if (this.playTimerId >= 0) {
                clearInterval(this.playTimerId);
                this.playTimerId = -1;
              }
            } else {
              const canResume = this.playDurationMs > 0 && this.playCurrentMs > 0 &&
                this.playCurrentMs < this.playDurationMs;
              let ok: boolean;
              if (canResume) {
                await this.audioRecordHelper.resumePlay();
                ok = true;
              } else {
                // 从头开始播放时，重置进度与偏移
                this.playCurrentMs = 0;
                AppStorage.setOrCreate('RWOffset', 0);
                const bytesPerSec = VoiceAudioConstants.SAMPLING_RATE * VoiceAudioConstants.SAMPLE_BYTE *
                  VoiceAudioConstants.CHANNEL_NUM;
                if (this.fileSize > 0) {
                  const totalSec = this.fileSize / bytesPerSec;
                  this.playDurationMs = totalSec * 1000;
                }
                ok = await this.audioRecordHelper.playByPath(this.currentNote.audioUri);
              }
              this.isPlaying = ok;
              if (!ok) {
                this.getUIContext().getPromptAction().showToast({
                  message: '音频播放失败',
                  alignment: Alignment.Center,
                  duration: 2000,
                });
              } else {
                // 启动进度轮询定时器
                if (this.playTimerId >= 0) {
                  clearInterval(this.playTimerId);
                }
                this.playTimerId = setInterval(() => {
                  const offset = AppStorage.get<number>('RWOffset') ?? 0;
                  if (this.fileSize > 0) {
                    const bytesPerSec = VoiceAudioConstants.SAMPLING_RATE * VoiceAudioConstants.SAMPLE_BYTE *
                      VoiceAudioConstants.CHANNEL_NUM;
                    const currentSec = offset / bytesPerSec;
                    const totalSec = this.fileSize / bytesPerSec;
                    this.playCurrentMs = currentSec * 1000;
                    this.playDurationMs = totalSec * 1000;
                  }
                  const atEnd = AppStorage.get<boolean>('AudioAtEnd') === true;
                  if (atEnd || (this.fileSize > 0 && offset >= this.fileSize)) {
                    if (this.playTimerId >= 0) {
                      clearInterval(this.playTimerId);
                      this.playTimerId = -1;
                    }
                    this.isPlaying = false;
                    this.playCurrentMs = 0;
                    AppStorage.setOrCreate('AudioAtEnd', false);
                  }
                }, 200);
              }
            }
          });
        }

        // 中间进度与时长
        Column({ space: 4 }) {
          if (this.isRecording) {
            Text(`录音中 ${this.formatTime(this.recordDurationSec)}`)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'));
          } else if (this.currentNote.audioUri) {
            Text(`${this.formatTime(this.getPlayCurrentSec())} / ${this.formatTime(this.getPlayTotalSec())}`)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'));

            Slider({
              value: this.playDurationMs > 0 ? this.playCurrentMs / this.playDurationMs : 0,
              min: 0,
              max: 1,
            })
              .width('100%')
              .onChange((value: number) => {
                if (this.audioRecordHelper && this.playDurationMs > 0 && this.isPlaying) {
                  const targetMs = value * this.playDurationMs;
                  this.playCurrentMs = targetMs;
                }
              });
          } else {
            Text('点击左侧按钮开始录音')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'));
          }
        }
        .layoutWeight(1);

        if (this.currentNote.audioUri && !this.isRecording) {
          Image($r('app.media.ic_public_delete'))
            .width(24)
            .height(24)
            .margin({ right: 16 })
            .onClick(() => {
              this.confirmDeleteRecording();
            });
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor($r('sys.color.comp_background_list_card'));
  }

  @Builder
  backDialog() {
    Column({ space: 18 }) {
      Text('确认返回')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));

      Column() {
        Text('当前笔记或画布内容尚未保存，立刻返回则')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'));

        Text('无法保存，是否确定返回？')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'));
      };

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Row() {
          Text('取消')
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize(16);
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.backDialogController.close();
        });

        Row() {
          Text('确定')
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize(16);
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(async () => {
          this.backDialogController.close();
          if (this.tabletEditorState.embedMode) {
            this.tabletEditorState.selectedNoteId = '';
          } else {
            this.appPathStack.pop();
          }
        });
      }
      .padding({
        top: 10,
      });
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeController.dialogBgWhite)
    .borderRadius(32)
    .height(158)
    .width('100%');
  }

  build() {
    if (this.tabletEditorState.embedMode) {
      Column() {
        Row() {
          // 左上角返回按钮（嵌入第三栏时返回到空态）
          SymbolGlyph($r('sys.symbol.arrow_left'))
            .fontSize(20)
            .fontColor([$r('sys.color.font_primary')])
            .onClick(() => {
              if (this.isEmbedEditorDirty() || this.isCurrentHandwriteDirty()) {
                this.backDialogController.open();
              } else {
                this.tabletEditorState.selectedNoteId = '';
              }
            });
          Blank();
          this.toolBar();
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 12, right: 12 });

        if (this.showRecordingBar) {
          Column() {
            this.recordingBar();
          }
          .width('100%');
        }

        // RichEditorArea 的 noteId/noteContent/noteTitle 为 @Once，需要通过 key 触发重建，否则切换笔记不会刷新
        ForEach([this.tabletEditorState.selectedNoteId], (_id: string) => {
          RichEditorArea({
            noteTitle: this.currentNote.title,
            noteContent: this.currentNote.styledString,
            snapShotController: this.snapShotController,
            noteId: this.currentNote.id,
            handwriteController: this.handwriteController,
            tapRecord: () => {
              this.isRecordingNote = true;
              this.showRecordingBar = true;
              this.richEditorController.showMoreFunction = false;
              this.richEditorController.isHandwriteMode = false;
            },
            titleChange: (title: string) => {
              this.noteTitle = title;
            },
          })
            .layoutWeight(1)
            .width('100%');
        }, (id: string) => id);
      }
      .height('100%')
      .width('100%');
    } else {
      NavDestination() {
        Stack() {
          // 富文本编辑区（含底部工具栏）
          RichEditorArea({
            noteTitle: this.currentNote.title,
            noteContent: this.currentNote.styledString,
            snapShotController: this.snapShotController,
            noteId: this.currentNote.id,
            handwriteController: this.handwriteController,
            tapRecord: () => {
              this.isRecordingNote = true;
              this.showRecordingBar = true;
              // 点击录音按钮后进入编辑模式（退出“更多/展示态”）
              this.richEditorController.showMoreFunction = false;
              // 避免手写层覆盖
              this.richEditorController.isHandwriteMode = false;
            },
            titleChange: (title: string) => {
              this.noteTitle = title;
            },
          })
          // 录音条浮层不挤压布局，但需要给内容留出顶部空间避免遮挡标题
          .padding({ top: this.showRecordingBar ? 120 : 0 });

          if (this.showRecordingBar) {
            Column() {
              this.recordingBar();
            }
            .width('100%')
            .position({ x: 0, y: 0 })
            .zIndex(1000);
          }
        }
        .height('100%')
        .width('100%');
      }
      .onShown(() => {
        // 激活接续能力
        if (this.isEditNote) {
          const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
          ContinueUtils.enableContinue(context);
        }
        // 每次页面显示时刷新隔空传送的当前笔记与同步 getter（返回缓存）
        this.gesturesShareService.setCurrentNote(this.currentNote.id, this.currentNote.title);
        this.gesturesShareService.setNotePayloadGetter(() => this.noteSharePayloadCache);
      })
      .menus(this.toolBar())
      .onReady((cxt: NavDestinationContext) => {
        // 平板分栏嵌入模式：不依赖 NavDestination 路由参数，由 tabletEditorState 驱动切换
        if (this.tabletEditorState.embedMode) {
          return;
        }

        const params = (cxt?.pathInfo?.param as Record<string, Object>) ?? {};
        let noteId = (params.noteId as string) ?? '';
        const isRecordingNoteParam = (params.isRecordingNote as boolean) === true;

        // 优先使用接续的笔记ID
        if (ContinueUtils.isContinueScene()) {
          const continueNoteId = ContinueUtils.getContinueNoteId();
          if (continueNoteId && continueNoteId !== '') {
            noteId = continueNoteId;
            hilog.info(0x0000, 'EditNotes', `使用接续的笔记ID: ${noteId}`);
          }
        }

        if (noteId === '') {
          this.isEditNote = false;
          this.currentNote = new Note(new MutableStyledString(''));
          this.noteTitle = '';
          this.isRecordingNote = isRecordingNoteParam;
          this.showRecordingBar = isRecordingNoteParam;
          const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
          ContinueUtils.disableContinue(context);
        } else {
          this.initFromNoteId(noteId, isRecordingNoteParam);
        }

        // 若已有录音，初始化 fileSize（用于进度与总时长）
        if (this.currentNote.audioUri) {
          try {
            const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
            const filePath = `${ctx.cacheDir}/${this.currentNote.audioUri}.pcm`;
            this.fileSize = fileIo.statSync(filePath).size;
            this.playCurrentMs = 0;
            if (this.fileSize > 0) {
              const bytesPerSec = VoiceAudioConstants.SAMPLING_RATE * VoiceAudioConstants.SAMPLE_BYTE *
                VoiceAudioConstants.CHANNEL_NUM;
              const totalSec = this.fileSize / bytesPerSec;
              this.playDurationMs = totalSec * 1000;
            } else {
              this.playDurationMs = 0;
            }
          } catch (e) {
            this.fileSize = 0;
            this.playCurrentMs = 0;
            this.playDurationMs = 0;
          }
        }

        // 供隔空传送使用：当前笔记 id/title + 同步返回缓存的 getter
        this.gesturesShareService.setCurrentNote(this.currentNote.id, this.currentNote.title);
        this.gesturesShareService.setNotePayloadGetter(() => this.noteSharePayloadCache);

        // historyRecordArray 已在 initFromNoteId / 新建分支中初始化
        if (noteId === '') {
          this.richEditorController.currentIndex = 0;
          this.richEditorController.historyRecordArray = [];
          this.richEditorController.historyRecordArray.push(new ChangeRecord(this.currentNote.styledString));
        }
        const category = params.currentCategory as Category | undefined;
        if (category?.id) {
          this.currentNote.categoryId = category.id;
        }

        // 打开编辑页面后更新接续数据，保证源端有“当前打开的笔记”
        if (this.isEditNote && this.currentNote.id) {
          ContinueUtils.updateContinueData(this.currentNote.id, this.currentNote.title);
        }
      })
      .onBackPressed(() => {
        // 平板右侧嵌入：返回键只清空右侧选中，不退出首页
        if (this.tabletEditorState.embedMode) {
          if (this.isEmbedEditorDirty() || this.isCurrentHandwriteDirty()) {
            this.backDialogController.open();
          } else {
            this.tabletEditorState.selectedNoteId = '';
          }
          return true;
        }
        // 三个点（更多）状态下：如果画布有改动，仍需弹窗确认并保存
        if (this.richEditorController.showMoreFunction) {
          if (this.isCurrentHandwriteDirty()) {
            this.backDialogController.open();
          } else {
            this.appPathStack.pop();
          }
          return true;
        }

        // 编辑态：按返回键弹出弹窗
        this.backDialogController.open();
        return true;
      });
    }
  }
}
