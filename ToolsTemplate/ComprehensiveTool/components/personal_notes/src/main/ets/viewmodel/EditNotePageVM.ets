import { unifiedDataChannel } from '@kit.ArkData';
import { pasteboard } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { Note } from '../models/Note';
import { RichEditorController } from '../controller/RichEditorController'
import { ThemeController } from '../controller/ThemeController';
import { SnapShotController } from '../controller/SnapShotController';
import { NoteUtil } from '../utils/NoteUtil';
import { ACTION_NAME, MoreFunction, SNAPSHOT_ID } from '../commons/Constant';
import { ChangeRecord } from '../models/ChangeRecord';
import { Category } from '../models/Category';

@ObservedV2
export class EditNotePageVM {
  richEditorController: RichEditorController = RichEditorController.instance;
  themeController: ThemeController = ThemeController.instance;
  noteUtil: NoteUtil = NoteUtil.instance;
  snapShotController: SnapShotController = new SnapShotController(SNAPSHOT_ID, new Scroller());

  @Trace currentNote: Note = new Note(new MutableStyledString(''));
  @Trace noteTitle: string = '';
  @Trace isEditNote: boolean = false;

  uiContext?: UIContext;
  pathStack: NavPathStack = new NavPathStack();

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  init(params: Record<string, Object>) {
    let noteId = params.noteId as string;
    if (noteId === '') {
      this.isEditNote = false;
    } else {
      this.isEditNote = true;
      let note = this.noteUtil.getNoteById(noteId);
      if (note) {
        this.currentNote = note;
      }
    }

    this.richEditorController.currentIndex = 0;
    this.richEditorController.historyRecordArray.push(new ChangeRecord(this.currentNote.styledString))
    if (!this.currentNote.categoryId) {
      this.currentNote.categoryId = (params.currentCategory as Category).id;
    }
  }

  // 返回事件
  onBack() {
    // 若已处于显示更多选项状态，直接返回，否则先退出编辑态，处于更多选项状态
    if (this.richEditorController.showMoreFunction) {
      this.pathStack.pop();
      return true;
    }
    // 按返回键弹出弹窗
    this.showConfirmDialog()
    return true;
  }

  // 页面销毁事件
  handleDisappear() {
    this.richEditorController.currentIndex = -1;
    // 操作记录
    this.richEditorController.historyRecordArray = [];
    this.richEditorController.initState();
  }

  showConfirmDialog() {
    this.uiContext?.getPromptAction().showDialog({
      title: '确认返回',
      message: '当前笔记尚未保存，立刻返回则无法保存当前笔记内容，是否确定返回？',
      alignment: 	DialogAlignment.Center,
      buttons: [
        {
          text: '取消',
          color: $r('sys.color.icon_emphasize')
        },
        {
          text: '确定',
          color: $r('sys.color.icon_emphasize')
        }
      ]
    }, (err, data) => {
      if (err) {
        return;
      }
      if (data.index === 1) {
        this.pathStack.pop()
      }
    });
  }

  // 获取撤销图标
  getUnDoIcon() {
    return this.richEditorController.currentIndex < 1 ?
      $r('app.media.undo_expire') : $r('app.media.undo_effect');
  }

  // 获取重新编写图标
  getRedoIcon() {
    let undoLen = this.richEditorController.undoRecordArray.length;
    return undoLen === 0 ? $r('app.media.redo_expire') : $r('app.media.redo_effect')
  }

  // 更多操作
  onMoreAction(item: MoreFunction) {
    if (item.name === ACTION_NAME.share) {
      this.snapShotController.onceSnapshot()
    } else if (item.name === ACTION_NAME.copy) {
      this.copyNoteText()
    }
  }

  // 保存笔记
  saveNote() {
    if (this.handleSaveNote()){
      // 点击保存后退出选中状态
      this.richEditorController.controller.setSelection(0, 0);
      // 退出编辑状态
      this.richEditorController.textInputController.stopEditing();
      this.richEditorController.controller.stopEditing();
      this.richEditorController.showMoreFunction = true;
    }
  }

  // 处理保存笔记
  handleSaveNote(): boolean {
    let styledString = this.richEditorController.controller.getStyledString();
    let content = styledString.getString();
    // 若新增笔记 内容和标题为空，不保存
    // 修改笔记   内容和标题为空，按返回无响应
    if (content === '' && this.noteTitle === '') {
      return this.isEditNote ? false: true;
    }

    if (this.isEditNote) {
      this.currentNote.updateContent(styledString, this.noteTitle);
    } else {
      this.currentNote.title = this.noteTitle
      this.currentNote.styledString = this.richEditorController.controller.getStyledString();
      this.currentNote.description = this.currentNote.styledString.getString();
      this.noteUtil.addNote(this.currentNote);
      this.isEditNote = true;
    }
    return true;
  }

  // 复制操作
  copyNoteText() {
    if (this.currentNote?.description === '') {
      this.showToast('请输入内容后复制！')
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

    this.showToast('复制成功')
  }

  showToast(message: string) {
    ToastDialog.showToast({
      message: message,
      toastAlignment: DialogAlignment.Center,
      duration: 1500
    })
  }
}