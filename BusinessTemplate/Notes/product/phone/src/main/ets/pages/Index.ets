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
import { Category, CategoryService, NoteService, SortEnum } from '@ohos_agcit/notes_datasource';
import {
  BreakpointType,
  BreakpointTypeEnum,
  DateConstants,
  DateUtil,
  GlobalInfoModel,
  NotificationUtil,
} from '@ohos_agcit/notes_utils';
import { AppStorageV2, PersistenceV2, window, router } from '@kit.ArkUI';
import { SecretLock } from 'secretlock';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SortController } from '../controller/SortController';
import { NoteSearchController } from '../controller/NoteSearchController';
import { CategoryController } from '../controller/CategoryController';
import { SearchNoResult } from '../components/SearchNoResult';
import { EmptyNotes } from '../components/EmptyNotes';
import { EditNotesBuilder } from './EditNotes';
import { TabletEditorState } from '../model/TabletEditorState';
import { JSON } from '@kit.ArkTS';
import { SelectedController } from '../controller/SelectedController';
import { LazyDataSource, Note } from 'richeditor';
import {
  SHOW_METHOD_ENUM,
  ShowMethod,
  showType,
  sortData,
  SortType,
  TOOL_BAR_NAME,
  ToolBar,
  toolBarList,
} from '../constants/HomeUiConstant';
import { SettingController } from '../controller/SettingController';
import { KVStore, SerializeUtil } from 'serializer';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { distributedKVStore } from '@kit.ArkData';
import { ContinueModel, ContinueUtils } from 'continue';
import { resourceManager } from '@kit.LocalizationKit';
import { UserInfo } from 'login';
import { NotesRefreshSignal } from '../model/NotesRefreshSignal';

@Entry
@ComponentV2
struct Index {
  logTag: string = '[Index]';
  domainId: number = 0x0000;
  @Provider('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  noteService: NoteService = NoteService.instance;
  categoryService: CategoryService = CategoryService.instance;
  sortController: SortController = SortController.instance;
  noteSearchController: NoteSearchController = NoteSearchController.instance;
  categoryController: CategoryController = CategoryController.instance;
  selectedController: SelectedController = SelectedController.instance;
  settingController: SettingController = SettingController.instance;
  uiContext: UIContext = this.getUIContext() as UIContext;
  hostContext: common.Context = this.uiContext.getHostContext() as Context;
  @Provider() kvStore: KVStore | undefined = undefined;
  securityLevel: distributedKVStore.SecurityLevel = distributedKVStore.SecurityLevel.S1;
  @Local secretLock: SecretLock = PersistenceV2.connect(SecretLock, () => new SecretLock())!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  @Local tabletEditorState: TabletEditorState =
    AppStorageV2.connect(TabletEditorState, 'tabletEditorState', () => new TabletEditorState())!;
  @Local notesRefreshSignal: NotesRefreshSignal =
    AppStorageV2.connect(NotesRefreshSignal, 'notesRefreshSignal', () => new NotesRefreshSignal())!;
  private userInfo: UserInfo = UserInfo.instance;
  @Local noteList: Note[] = [];
  @Local currentCategory: Category = this.categoryService.getFirstCategory();
  @Local dataList: LazyDataSource<Note> = new LazyDataSource();
  @Local showListType: SHOW_METHOD_ENUM = SHOW_METHOD_ENUM.normalList;
  /** PC 三栏：左侧“全部笔记（分类列表）”是否展开 */
  @Local pcCategoryExpanded: boolean = true;
  /** PC 三栏：是否显示第一栏（用户信息+搜索+分类） */
  @Local pcShowFirstPane: boolean = true;
  @Local hasShownSplashAd: boolean = false;
  /** PC：笔记卡片连续两次点击同一笔记，切换至该笔记所属分类 */
  private lastPcNoteTapId: string = '';
  private lastPcNoteTapTime: number = 0;
  private categoryDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.tabletCategoryDialog();
    },
    alignment: DialogAlignment.Center,
    customStyle: true,
  });
  private showMethodDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.tabletShowMethodDialog();
    },
    alignment: DialogAlignment.Center,
    customStyle: true,
  });

  private pcSwitchNoteDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.pcSwitchNoteDialog();
    },
    alignment: DialogAlignment.Center,
    customStyle: true,
  });
  private gestureShareCheckTimerId: number = -1;

  async aboutToAppear() {
    // 判断通知是否授权
    NotificationUtil.authorizeNotification().then(grant => {
      this.settingController.isNoticeGrant = grant;
    });

    if (this.secretLock.gesture) {
      const params: Record<string, Object> = { 'fromEntrance': true, 'appPathStack': this.appPathStack };
      this.appPathStack.pushPathByName('DrawLock', params);
    }

    // 创建KV数据库
    this.kvStore = new KVStore();
    try {
      this.kvStore.kvStore = await this.kvStore.createKVStore(false, this.securityLevel, this.uiContext);
    } catch (e) {
      const err = e as BusinessError;
      hilog.error(0x0000, 'Index', `createKVStore failed: ${err.code} ${err.message}`);
    }

    // 读取持久化数据
    this.noteService.loadEffectiveNote(this.kvStore, this.hostContext);
    this.noteService.loadDeleteNote(this.kvStore);
    this.categoryService.loadCategoryList(this.kvStore, this.noteList);
    this.syncPcCategorySelection();
    AppStorage.setOrCreate('notes_pc_current_category_id', this.currentCategory.id);

    // 检查接续场景
    this.checkAndHandleContinueScene();
    // 检查隔空传送（传内容 / 仅链接）：立即检查 + 短时轮询（热启动时 payload 在 onNewWant 里设置，Index 已加载不会再次 aboutToAppear）
    this.checkAndHandleGestureShare();
    this.gestureShareCheckTimerId = setInterval(() => this.checkAndHandleGestureShare(), 800);
    this.tabletEditorState.embedMode = this.isTabletLayout() || this.isPcLayout();
  }

  private isPcLayout(): boolean {
    try {
      const type = this.hostContext.resourceManager.getDeviceCapabilitySync().deviceType;
      return type === resourceManager.DeviceType.DEVICE_TYPE_2IN1;
    } catch (e) {
      return false;
    }
  }

  private isTabletLayout(): boolean {
    try {
      const type = this.hostContext.resourceManager.getDeviceCapabilitySync().deviceType;
      return type === resourceManager.DeviceType.DEVICE_TYPE_TABLET;
    } catch (e) {
      return false;
    }
  }

  /**
   * 折叠屏（展开态）通常表现为：非平板/非PC，但断点进入 md/lg（宽度 >= 600vp）。
   * 这里用于做弹窗布局微调，不影响平板自定义弹窗。
   */
  private isFoldExpandedLayout(): boolean {
    return !this.isTabletLayout() && !this.isPcLayout() && this.globalInfo.currentBreakpoint !== BreakpointTypeEnum.SM;
  }

  private getNoteListHorizontalInset(): ResourceStr {
    return new BreakpointType<ResourceStr>({
      sm: $r('sys.float.padding_level8'),
      md: $r('sys.float.padding_level12'),
      lg: $r('sys.float.padding_level16'),
    }).getValue(this.globalInfo.currentBreakpoint);
  }


  private getPcSecondPaneHorizontalInset(): number {
    switch (this.globalInfo.currentBreakpoint) {
      case BreakpointTypeEnum.SM:
        return 8;
      case BreakpointTypeEnum.MD:
        return 11;
      default:
        return 14;
    }
  }

  /**
   * 笔记列表区域右侧内边距。平板侧栏较窄时适当小于左侧，避免卡片右缘离第一栏右边界过远。
   */
  private getNoteListRightInset(): ResourceStr | number {
    if (!this.isTabletLayout()) {
      return this.getNoteListHorizontalInset();
    }
    return this.getTabletListRightInsetVp();
  }

  /**
   * 平板侧栏搜索框：在「与笔记列表同宽的条带」内再左右缩进，使输入条比笔记卡片略窄。
   */
  private getTabletSearchExtraHorizontalInset(): number {
    return 14;
  }

  private getTabletListLeftInsetVp(): number {
    switch (this.globalInfo.currentBreakpoint) {
      case BreakpointTypeEnum.SM:
        return 8;
      case BreakpointTypeEnum.MD:
        return 12;
      default:
        return 16;
    }
  }

  private getTabletListRightInsetVp(): number {
    switch (this.globalInfo.currentBreakpoint) {
      case BreakpointTypeEnum.SM:
        return 10;
      case BreakpointTypeEnum.MD:
        return 12;
      default:
        return 14;
    }
  }

  /**
   * 搜索条带整体略向左移：外侧左边比笔记区少 4vp，右边多 4vp，条带总宽度与笔记内容区一致。
   */
  private getTabletSearchOuterLeftInset(): number {
    return this.getTabletListLeftInsetVp() - 4;
  }

  private getTabletSearchOuterRightInset(): number {
    return this.getTabletListRightInsetVp() + 4;
  }

  /** 与 PC 侧栏（个人信息页等）同步当前选中分类 */
  private syncPcCategorySelection(): void {
    const saved: string | undefined = AppStorage.get<string>('notes_pc_current_category_id');
    if (saved) {
      const cat = this.categoryService.getCategoryById(saved);
      if (cat) {
        this.currentCategory = cat;
      }
    }
  }

  /**
   * 打开笔记编辑页：平板/PC 分栏下在右侧嵌入展示，不走 Navigation 栈。
   */
  private openEditNotesPage(params: Record<string, Object>): void {
    if (!this.isTabletLayout() && !this.isPcLayout()) {
      this.appPathStack.pushPathByName('EditNotes', params);
      return;
    }

    interface EditNotesRouteParams {
      noteId?: string;
      currentCategory?: Category;
      isRecordingNote?: boolean;
    }

    const p: EditNotesRouteParams = params as EditNotesRouteParams;
    const noteId: string = p.noteId ?? '';
    const currentCategory: Category = p.currentCategory ?? this.currentCategory;
    const isRecordingNote: boolean = p.isRecordingNote === true;

    if (noteId === '') {
      const draft = new Note(new MutableStyledString(''));
      draft.categoryId = currentCategory.id;
      this.tabletEditorState.pendingNewNoteCategoryId = currentCategory.id;
      this.tabletEditorState.pendingIsRecordingNote = isRecordingNote;
      this.tabletEditorState.selectedNoteId = draft.id;
      return;
    }

    this.tabletEditorState.pendingNewNoteCategoryId = '';
    this.tabletEditorState.pendingIsRecordingNote = false;
    this.tabletEditorState.selectedNoteId = noteId;
  }

  private getTabletSideBarWidthVp(): number {
    const viewWidthVp =
      typeof this.globalInfo.screenWidthVp === 'number' && this.globalInfo.screenWidthVp > 0
        ? this.globalInfo.screenWidthVp
        : (AppStorage.get<number>('screenWidth') ?? 1000);
    const gap = 12;
    const usable = Math.max(0, viewWidthVp - gap);
    const side = Math.floor(usable / 3);
    return Math.max(1, side);
  }

  @Builder
  private tabletEmptyRightPane() {
    Column({ space: 16 }) {
      Image($r('app.media.writing_pen'))
        .width(120)
        .height(120);
      Text('岁月悠悠，心事悄悄，记录一下吧。')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'));
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private tabletRightPane() {
    Column() {
      if (!this.tabletEditorState.selectedNoteId) {
        this.tabletEmptyRightPane();
      } else {
        Column() {
          Text(this.tabletEditorState.selectedNoteId)
            .fontSize(0)
            .opacity(0)
            .height(0)
            .width(0);
          EditNotesBuilder();
        };
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /** 与手机端 bindSheet 标题栏关闭一致：描边圆 + 中心叉号 */
  @Builder
  private sheetStyleCloseButton(onClose: () => void) {
    Stack({ alignContent: Alignment.Center }) {
      Circle({ width: 28, height: 28 })
        .fillOpacity(0)
        .borderWidth(1)
        .borderColor($r('sys.color.comp_divider'))
        .borderRadius(14);
      Image($r('app.media.exit_ctrl'))
        .width(16)
        .height(16);
    }
    .width(28)
    .height(28)
    .onClick(() => {
      onClose();
    });
  }

  @Builder
  private tabletCategoryDialog() {
    Column() {
      // 标题
      Row() {
        Text($r('app.string.note_category'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
        Blank();
        this.sheetStyleCloseButton(() => {
          this.categoryDialogController.close();
        });
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 8,
      });

      // 列表：与手机端 showCategoryDialog 一致，整块列表圆角 8vp
      Column() {
        List() {
          ForEach(this.categoryService.getCategoryList(), (category: Category, index: number) => {
            ListItem() {
              Column() {
                if (index !== 0) {
                  Divider()
                    .color($r('sys.color.comp_divider'));
                }
                Row() {
                  Text(category.name)
                    .fontSize(16)
                    .fontColor(this.currentCategory.id === category.id ?
                      $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
                    .fontWeight(this.currentCategory?.id === category.id ? FontWeight.Medium : FontWeight.Regular)
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });

                  Text(String(category.totalCount))
                    .fontSize(16)
                    .margin({ left: 12 });
                }
                .width('100%')
                .height(50);
              };
            }
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.resetCategory(category);
              this.categoryDialogController.close();
            });
          }, (category: Category) => category.id);
        }
        .borderRadius(8)
        .clip(true)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None);
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 16, right: 16, top: 8 });

      // 底部按钮
      Row() {
        Button() {
          Row() {
            Text($r('app.string.go_note_category'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium);
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontWeight(FontWeight.Medium)
              .fontSize(18)
              .fontColor([Color.White])
              .padding({ left: 13 });
          };
        }
        .height(40)
        .width('100%')
        .backgroundColor('#FFAA00')
        .onClick(() => {
          this.categoryDialogController.close();
          if (this.currentCategory) {
            const params: Record<string, Object | undefined> =
              { 'isEditCategory': true, 'currentCategory': this.currentCategory, 'noteList': undefined };
            this.appPathStack.pushPathByName('EditCategory', params);
          }
        });
      }
      .padding({ left: 16, right: 16, top: 8 });
    }
    .width(480)
    .height(344)
    .padding({ bottom: 12 })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(32)
    .clip(true);
  }

  @Builder
  private tabletShowMethodDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .onClick(() => this.showMethodDialogController.close());

      Column() {
        Column() {
          Row() {
            Blank();
            this.sheetStyleCloseButton(() => {
              this.showMethodDialogController.close();
            });
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 12,
            bottom: 0,
          })
          .alignItems(VerticalAlign.Center);
        };

        Column() {
          this.sortSheet();
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ top: 14, bottom: 12 });
      }
      .width(480)
      .height(440)
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius(32)
      .clip(true)
      .onClick(() => {
      });
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  private pcSwitchNoteDialog() {
    Column({ space: 18 }) {
      Text('确认切换')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));

      Column() {
        Text('当前笔记内容尚未保存，切换将丢失修改。')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'));
        Text('是否继续切换？')
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
          this.pcSwitchNoteDialogController.close();
          this.tabletEditorState.pendingSwitchNoteId = '';
        });

        Row() {
          Text('继续切换')
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize(16);
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          const target = this.tabletEditorState.pendingSwitchNoteId;
          this.pcSwitchNoteDialogController.close();
          this.tabletEditorState.pendingNewNoteCategoryId = '';
          this.tabletEditorState.pendingIsRecordingNote = false;
          this.tabletEditorState.pendingSwitchNoteId = '';
          AppStorage.setOrCreate('notes_embed_dirty', false);
          if (target) {
            this.tabletEditorState.selectedNoteId = target;
          }
        });
      }
      .padding({ top: 10 });
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(32)
    .height(170)
    .width(420);
  }

  aboutToDisappear(): void {
    if (this.gestureShareCheckTimerId >= 0) {
      clearInterval(this.gestureShareCheckTimerId);
      this.gestureShareCheckTimerId = -1;
    }
  }

  /**
   * 检查并处理隔空传送：传内容则新建笔记并打开，仅链接则按 noteId 打开
   */
  private checkAndHandleGestureShare(): void {
    const fromContent: boolean | undefined = AppStorage.get<boolean>('from_gesture_share_content');
    const payload: Record<string, Object> | undefined = AppStorage.get<Record<string, Object>>('shared_note_payload');
    if (fromContent === true && payload) {
      AppStorage.setOrCreate('from_gesture_share_content', false);
      AppStorage.delete('shared_note_payload');
      if (this.gestureShareCheckTimerId >= 0) {
        clearInterval(this.gestureShareCheckTimerId);
        this.gestureShareCheckTimerId = -1;
      }
      this.createNoteFromSharePayload(payload);
      return;
    }
    const fromLink: boolean | undefined = AppStorage.get<boolean>('from_gesture_share');
    const noteId: string | undefined = AppStorage.get<string>('share_note_id');
    if (fromLink === true && noteId) {
      AppStorage.setOrCreate('from_gesture_share', false);
      AppStorage.delete('share_note_id');
      const note = this.noteService.getNoteById(noteId);
      if (note) {
        setTimeout(() => {
          const params: Record<string, Object> = {
            'noteId': noteId,
            'currentCategory': this.categoryService.getCategoryById(note.categoryId) ||
            this.categoryService.getFirstCategory(),
          };
          this.openEditNotesPage(params);
        }, 300);
      } else {
        this.showToast('未找到该笔记，可能尚未同步到本机');
      }
    }
  }

  /**
   * 用隔空传送的 payload 新建笔记并跳转编辑页
   */
  private createNoteFromSharePayload(payload: Record<string, Object>): void {
    const serializedStyledString = payload.serializedStyledString as string;
    if (!serializedStyledString) {
      this.showToast('分享数据不完整');
      return;
    }
    SerializeUtil.deserialize(serializedStyledString).then((mss: MutableStyledString) => {
      const note = new Note(mss);
      note.title = (payload.title as string) || '我的笔记';
      const rawCategoryId = (payload.categoryId as string) || '-1';
      note.categoryId = this.categoryService.getCategoryById(rawCategoryId) ? rawCategoryId : '-1';
      note.description = (payload.description as string) || '';
      note.createTime = (payload.createTime as string) || String(Date.now());
      note.updateTime = (payload.updateTime as string) || note.createTime;
      note.serializedStyledString = serializedStyledString;
      this.noteService.addNote(note, this.kvStore, this.uiContext, true);
      this.noteList = this.noteService.getNoteList(
        this.currentCategory.id, this.sortController.sortBy, this.noteSearchController.searchKeyword);
      this.updateDataList();
      const category = this.categoryService.getCategoryById(note.categoryId) ||
      this.categoryService.getFirstCategory();
      setTimeout(() => {
        const params: Record<string, Object> = {
          'noteId': note.id,
          'currentCategory': category,
        };
        this.openEditNotesPage(params);
        this.showToast('已接收隔空传送的笔记');
      }, 300);
    }).catch((err: Error) => {
      hilog.error(this.domainId, this.logTag, `隔空传送反序列化失败: ${err.message}`);
      this.showToast('笔记内容解析失败');
    });
  }

  /**
   * 检查并处理接续场景
   */
  private async checkAndHandleContinueScene(): Promise<void> {
    if (!ContinueUtils.isContinueScene()) {
      return;
    }

    const continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;

    if (!continueModel.noteId) {
      return;
    }

    // 验证笔记是否存在
    const note = this.noteService.getNoteById(continueModel.noteId);
    if (!note) {
      this.showToast('接续的笔记不存在');
      ContinueUtils.clearContinueFlag();
      return;
    }

    // 直接跳转到编辑页面
    await new Promise<void>(resolve => setTimeout(resolve, 300));

    const params: Record<string, Object> = {
      'noteId': continueModel.noteId,
      'currentCategory': this.categoryService.getCategoryById(note.categoryId) ||
      this.categoryService.getFirstCategory(),
    };

    this.openEditNotesPage(params);

    hilog.info(this.domainId, this.logTag,
      `接续跳转到编辑页面: noteId=${continueModel.noteId}, title=${continueModel.noteTitle}`);
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

  // 更新瀑布流卡片数据
  updateDataList() {
    this.dataList.clear();
    this.noteList.forEach((item: Note) => {
      this.dataList.pushData(item);
    });
  }

  @Monitor('notesRefreshSignal.tick')
  private onNotesRefreshTickChange(): void {
    this.noteList = this.noteService.getNoteList(
      this.currentCategory.id,
      this.sortController.sortBy,
      this.noteSearchController.searchKeyword,
    );
    this.updateDataList();
  }

  // 笔记卡片长按事件
  handleLangPress(item: Note) {
    // 非多选状态下生效
    if (!this.selectedController.isCtrl) {
      this.selectedController.isCtrl = true;
      item.isSelected = true;
      this.selectedController.selectedCount = 1;
    }
  }

  getSelectedImage(isSelect: boolean): ResourceStr {
    return isSelect ? $r('app.media.selected') : $r('app.media.unselected');
  }

  getNoteItemBgColor(isSelect: boolean): ResourceStr {
    if (this.selectedController.isCtrl) {
      return isSelect ? $r('sys.color.background_tertiary') : $r('sys.color.comp_background_list_card');
    }
    return $r('sys.color.comp_background_list_card');
  }

  // 获取选中的笔记
  getSelectData(): Note[] {
    let tempArray: Note[] = [];
    this.noteList.forEach((item) => {
      if (item.isSelected) {
        tempArray.push(item);
      }
    });
    if (tempArray.length === 0) {
      this.getUIContext().getPromptAction().showToast({
        message: '还未选中任何笔记',
        alignment: Alignment.Center,
      });
    }
    return tempArray;
  }

  // 全选
  handleSelectAll() {
    if (this.selectedController.selectedCount === this.noteList.length) {
      this.noteList.forEach(item => item.isSelected = false);
      this.selectedController.selectedCount = 0;
    } else {
      this.noteList.forEach(item => item.isSelected = true);
      this.selectedController.selectedCount = this.noteList.length;
    }
  }

  // 底部工具栏点击事件 分类、删除、全选
  handleToolBarClick(name: TOOL_BAR_NAME) {
    if (name === TOOL_BAR_NAME.select_all) {
      this.handleSelectAll();
      return;
    }

    const selectDataList = this.getSelectData();
    if (selectDataList.length === 0) {
      return;
    }

    if (name === TOOL_BAR_NAME.move_category) {
      const params: Record<string, Object> =
        { 'isEditCategory': false, 'currentCategory': this.currentCategory, 'noteList': selectDataList };
      this.appPathStack.pushPathByName('EditCategory', params);
      return;
    }

    if (name === TOOL_BAR_NAME.delete) {
      const params: Record<string, Object> = { 'noteList': selectDataList };
      this.appPathStack.pushPathByName('DeleteNoteDialog', params);
    }
  }

  // 重置分类
  resetCategory(category: Category) {
    AppStorage.setOrCreate('notes_pc_current_category_id', category.id);
    AppStorage.delete('notes_pc_search_keyword');
    this.currentCategory = category;
    this.noteSearchController.isSearching = false; // 重置搜索状态
    this.noteSearchController.searchKeyword = '';
    this.noteList = this.noteService.getNoteList(
      this.currentCategory.id, this.sortController.sortBy, this.noteSearchController.searchKeyword);
    this.categoryController.openCategorySheet = false;
    this.updateDataList();
  }

  // 列表排序
  sort = (type: SortEnum) => {
    this.sortController.onSortConfirm(this.currentCategory.id, type,
      this.noteSearchController.searchKeyword);
  };
  // 列表展示方式
  toggleShowType = (useWaterFlow: SHOW_METHOD_ENUM) => {
    this.showListType = useWaterFlow;
    if (this.showListType === SHOW_METHOD_ENUM.waterFlowList) {
      this.updateDataList();
    }
    this.sortController.openSortSheet = false;
  };

  @Builder
  addNoteBuilder() {
    if (this.selectedController.isCtrl === false) {
      Row() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontColor([Color.White])
          .fontSize(35);
      }
      .justifyContent(FlexAlign.Center)
      .width(50)
      .height(50)
      .borderRadius(44)
      .backgroundColor('#FFAA00')
      .zIndex(10)
      .position({
        right: (this.isPcLayout() ? this.getPcSecondPaneHorizontalInset() : 32) as Dimension,
        bottom: (this.isPcLayout() ? 40 : 100) as Dimension,
      })
      .onClick(() => {
        const params: Record<string, Object> = { 'noteId': '', 'currentCategory': this.currentCategory };
        this.openEditNotesPage(params);
      });
    }
  }

  @Builder
  toolBarBuilder() {
    if (this.selectedController.isCtrl) {
      Row() {
        ForEach(toolBarList, (item: ToolBar) => {
          Column({ space: 5 }) {
            Image(item.icon)
              .width(24)
              .height(24);

            Text(item.name)
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'));
          }
          .onClick(() => {
            this.handleToolBarClick(item.name);
          });
        }, (item: ToolBar) => {
          try {
            return JSON.stringify(item);
          } catch (error) {
            hilog.error(this.domainId, this.logTag, 'ToolBar key stringify error');
            return item.name;
          }
        });
      }
      .margin({ top: 10 })
      .padding({ bottom: 10 })
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .height(70)
      .backgroundColor($r('sys.color.comp_background_list_card'));
    }
  }

  @Styles
  topAreaStyle() {
    .width('100%')
    .padding(new BreakpointType<Padding>({
      sm: {
        top: 12,
        bottom: 20,
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      },
      md: {
        top: 12,
        bottom: 20,
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      },
      lg: {
        top: 12,
        bottom: 20,
        left: $r('sys.float.padding_level16'),
        right: $r('sys.float.padding_level16'),
      },
    }).getValue(this.globalInfo.currentBreakpoint));
  }

  @Builder
  topArea() {
    Row() {
      Text(this.selectedController.isCtrl ? `已选${this.selectedController.selectedCount}项` :
        $r('app.string.homepage'))
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
      Blank();
      Image(this.selectedController.isCtrl ? $r('app.media.exit_ctrl') : $r('app.media.user_avatar'))
        .width(this.selectedController.isCtrl ? 24 : 40)
        .height(this.selectedController.isCtrl ? 24 : 40)
        .onClick(() => {
          if (this.selectedController.isCtrl) {
            this.noteList.forEach(item => item.isSelected = false);
            this.selectedController.recoverInitState();
          } else {
            this.appPathStack.pushPathByName('MineView', undefined);
          }
        });
    }
    .topAreaStyle();
  }

  @Builder
  editorNoteList() {
    if (!this.selectedController.isCtrl) {
      Row() {
        Row({ space: 4 }) {
          Text(this.currentCategory.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'));

          SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
            .fontColor([$r('sys.color.font_secondary')]);
        }.onClick(() => {
          if (this.isTabletLayout()) {
            this.categoryDialogController.open();
          } else {
            this.categoryController.openCategorySheet = true;
          }
        })
        .bindSheet($$this.categoryController.openCategorySheet, this.showCategoryDialog(), {
          title: { title: $r('app.string.note_category') },
          width: this.globalInfo.currentBreakpoint === BreakpointTypeEnum.SM ? '100%' : 480,
          height: this.globalInfo.currentBreakpoint === BreakpointTypeEnum.SM ? 400 : 344,
          radius: {
            topLeft: 32,
            topRight: 32,
            bottomLeft: 32,
            bottomRight: 32,
          },
        });

        Blank();
        Image($r('app.media.icon_more'))
          .height(20)
          .width(20)
          .onClick(() => {
            if (this.isTabletLayout()) {
              this.showMethodDialogController.open();
            } else {
              this.sortController.openSortSheet = true;
            }
          })
          .bindSheet($$this.sortController.openSortSheet,
            this.isFoldExpandedLayout() ? this.sortSheetBottom() : this.sortSheet(), {
              width: this.globalInfo.currentBreakpoint === BreakpointTypeEnum.SM ? '100%' : 480,
              showClose: true,
              height: this.globalInfo.currentBreakpoint === BreakpointTypeEnum.SM ? 376 : 426,
              radius: {
                topLeft: 32,
                topRight: 32,
                bottomLeft: 32,
                bottomRight: 32,
              },
            });
      }
      .width('100%')
      .padding(this.isTabletLayout() ? {
        left: this.getNoteListHorizontalInset(),
        right: this.getNoteListRightInset(),
        top: 12,
        bottom: 12,
      } : new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
          top: 12,
          bottom: 12,
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
          top: 12,
          bottom: 12,
        },
        lg: {
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
          top: 12,
          bottom: 12,
        },
      }).getValue(this.globalInfo.currentBreakpoint));
    }
  }

  @Builder
  cardItem(item: Note, maxLines: number) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 12 }) {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Text(item.description)
          .maxLines(maxLines)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(14)
          .lineHeight(19)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular);

        Text(DateUtil.getFormatDateStr(item.createTime, DateConstants.DATE_FORMAT4))
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'));
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(
        ((this.isTabletLayout() || this.isPcLayout()) && !this.selectedController.isCtrl &&
          !!this.tabletEditorState.selectedNoteId && item.id === this.tabletEditorState.selectedNoteId)
          ? $r('sys.color.comp_background_tertiary')
          : this.getNoteItemBgColor(item.isSelected),
      )
      .borderRadius(16)
      .width('100%')
      .padding(12);

      if (this.selectedController.isCtrl) {
        Image(this.getSelectedImage(item.isSelected))
          .width(35)
          .height(35)
          .padding({ top: 10, right: 10 });
      }
    }
    .onClick(() => {
      if (this.selectedController.isCtrl) {
        item.isSelected = !item.isSelected;
        let count: number = 0;
        this.noteList.forEach(item => {
          if (item.isSelected) {
            count++;
          }
        });
        this.selectedController.selectedCount = count;
      } else {
        if (this.isTabletLayout() || this.isPcLayout()) {
          // PC/PAD 分栏：切换笔记前，如果当前笔记未保存则二次确认
          const dirty = AppStorage.get<boolean>('notes_embed_dirty') === true;
          const dirtyId = AppStorage.get<string>('notes_embed_dirty_note_id') ?? '';
          if (dirty && dirtyId && dirtyId === this.tabletEditorState.selectedNoteId &&
            this.tabletEditorState.selectedNoteId !== '' && this.tabletEditorState.selectedNoteId !== item.id) {
            this.tabletEditorState.pendingSwitchNoteId = item.id;
            this.pcSwitchNoteDialogController.open();
            return;
          }
          if (this.isPcLayout()) {
            const now: number = Date.now();
            if (item.id === this.lastPcNoteTapId && (now - this.lastPcNoteTapTime) < 450) {
              const noteCat: Category | undefined = this.categoryService.getCategoryById(item.categoryId);
              if (noteCat) {
                this.resetCategory(noteCat);
              }
              this.lastPcNoteTapId = '';
              this.lastPcNoteTapTime = 0;
            } else {
              this.lastPcNoteTapId = item.id;
              this.lastPcNoteTapTime = now;
            }
          }
          this.tabletEditorState.pendingNewNoteCategoryId = '';
          this.tabletEditorState.pendingIsRecordingNote = false;
          this.tabletEditorState.selectedNoteId = item.id;
        } else {
          // 进入编辑器
          const params: Record<string, Object> = { 'noteId': item.id, 'currentCategory': this.currentCategory };
          this.appPathStack.pushPathByName('EditNotes', params);
        }
      }
    });
  }

  @Builder
  private phoneLikeHomeColumn() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.topArea();
        // 搜索框：外边与笔记列表左右对齐，内边再缩进以缩短输入条
        Column() {
          Search({
            placeholder: $r('app.string.search_note'),
          })
            .width('100%')
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .placeholderColor($r('sys.color.font_secondary'))
            .fontColor($r('sys.color.font_primary'))
            .onSubmit((value: string) => { // 提交搜索
              this.noteList = this.noteSearchController.onSearch(this.currentCategory.id, value,
                this.sortController.sortBy);
              this.updateDataList();
            })
            .onChange((value: string) => { // 输入变化时
              if (!value) {
                // 清空搜索时恢复列表
                this.noteList =
                  this.noteSearchController.onSearch(this.currentCategory.id, '', this.sortController.sortBy);
                this.updateDataList();
              }
            });
        }
        .width('100%')
        .padding({
          left: this.getTabletSearchExtraHorizontalInset(),
          right: this.getTabletSearchExtraHorizontalInset(),
        })
        .margin({
          bottom: 12,
          left: this.getTabletSearchOuterLeftInset(),
          right: this.getTabletSearchOuterRightInset(),
        });

        // 上方工具栏
        this.editorNoteList();

        // 卡片列表
        this.showNoteList();

        // 多选底部工具栏
        this.toolBarBuilder();
      }
      .width('100%')
      .height('100%')
      // 平板侧栏：与顶栏、搜索同一左缘对齐（避免子组件默认居中等导致视觉不齐）
      .alignItems(HorizontalAlign.Start);

      this.addNoteBuilder();
    }
    .width('100%')
    .height('100%');
  }

  @Styles
  cardWrapperStyle() {
    .width('100%')
    .margin({ bottom: 10 })
    .padding({
      left: this.isPcLayout() ? this.getPcSecondPaneHorizontalInset() : this.getNoteListHorizontalInset(),
      right: this.isPcLayout() ? this.getPcSecondPaneHorizontalInset() : this.getNoteListRightInset(),
    })
    .layoutWeight(1);
  }

  @Builder
  cardList() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.noteList, (item: Note) => {
          ListItem() {
            this.cardItem(item, 1);
          }
          .gesture(
            // 绑定可以重复触发的LongPressGesture
            LongPressGesture({ repeat: false, fingers: 1, duration: 500 })
              .onAction((event: GestureEvent | undefined) => {
                if (event) {
                  this.handleLangPress(item);
                }
              }),
          );
        }, (item: Note) => item.id);
      }
      // “按列表展示”统一为单列（折叠屏/大屏也保持列表观感）
      .lanes(1, obtainGutter(this.globalInfo.currentBreakpoint, 'List'))
      .scrollBar(BarState.Off);
    }
    .cardWrapperStyle();
  }

  @Builder
  waterCardList() {
    Column() {
      WaterFlow() {
        LazyForEach(this.dataList, (item: Note, index: number) => {
          FlowItem() {
            this.cardItem(item, 9);
          }
          .onAppear(() => {
            if (index === this.dataList.totalCount()) {
              this.updateDataList();
            }
          })
          .width('100%')
          .gesture(
            // 绑定可以重复触发的LongPressGesture
            LongPressGesture({ repeat: false, fingers: 1, duration: 500 })
              .onAction((event: GestureEvent | undefined) => {
                if (event) {
                  this.handleLangPress(item);
                }
              }),
          );
        }, (item: Note) => item.id);
      }
      .cachedCount(1)
      .columnsTemplate('1fr 1fr')
      .columnsGap(obtainGutter(this.globalInfo.currentBreakpoint, 'WaterFlow'))
      .rowsGap(16)
      .width('100%')
      .height('100%');
    }
    .cardWrapperStyle();
  }

  @Builder
  showNoteList() {
    if (this.noteSearchController.isSearching && this.noteList.length === 0) {
      SearchNoResult({ alignStart: this.isTabletLayout() });
    }
    if (!this.noteSearchController.isSearching && this.noteList.length === 0) {
      EmptyNotes();
    } else if (this.showListType === SHOW_METHOD_ENUM.normalList) {
      this.cardList();
    } else {
      this.waterCardList();
    }
  }

  @Builder
  showCategoryDialog() {
    Column() {
      Column() {
        List() {
          ForEach(this.categoryService.getCategoryList(), (category: Category, index: number) => {
            ListItem() {
              Column() {
                if (index !== 0) {
                  Divider()
                    .color($r('sys.color.comp_divider'));
                }
                Row() {
                  Text(category.name)
                    .fontSize(16)
                    .fontColor(this.currentCategory.id === category.id ?
                      $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
                    .fontWeight(this.currentCategory?.id === category.id ? FontWeight.Medium : FontWeight.Regular);

                  Blank();
                  Text(String(category.totalCount))
                    .fontSize(16);
                }
                .width('100%')
                .height(50);
              };
            }
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .padding({
              left: 12,
              right: 12,
            })
            .onClick(() => {
              this.resetCategory(category);
            });
          }, (category: Category) => category.id);
        }
        .borderRadius(8)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None);
      }
      .height(this.globalInfo.currentBreakpoint === BreakpointTypeEnum.SM ? 250 : '70%');

      Button() {
        Row() {
          Text($r('app.string.go_note_category'))
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium);
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .fontColor([Color.White])
            .padding({
              left: 13,
            });
        };
      }
      .height(40)
      .width('100%')
      .backgroundColor('#FFAA00')
      .margin({
        // 折叠屏/大屏：减小底部留白，让按钮更贴近底部
        bottom: this.globalInfo.currentBreakpoint === BreakpointTypeEnum.SM ? 30 : 16,
      })
      .onClick(() => {
        this.categoryController.openCategorySheet = false;
        if (this.currentCategory) {
          const params: Record<string, Object | undefined> =
            { 'isEditCategory': true, 'currentCategory': this.currentCategory, 'noteList': undefined };
          this.appPathStack.pushPathByName('EditCategory', params);
        }
      });
    }
    // 内容区域占满 sheet，避免百分比二次缩放导致列表区域被挤没
    .width('100%')
    .height('100%')
    .padding(new BreakpointType<Padding>({
      sm: {
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      },
      md: {
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      },
      lg: {
        left: $r('sys.float.padding_level16'),
        right: $r('sys.float.padding_level16'),
      },
    }).getValue(this.globalInfo.currentBreakpoint))
    .backgroundColor($r('sys.color.background_secondary'));
  }

  @Builder
  sheetCard(title: string, data: SortType[] | ShowMethod[], callBack: Function, group: string) {
    Column() {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 16 });

      List({ space: 24 }) {
        ForEach(data, (item: SortType | ShowMethod) => {
          ListItem() {
            Row() {
              Text(item.name)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'));
              Blank();
              Radio({ value: item.type, group: group })
                .checked(group === 'showType' ? this.showListType === item.type :
                  this.sortController.sortBy === item.type)
                .onChange((isChecked: boolean) => {
                  if (isChecked === true) {
                    callBack(item.type);
                  }
                });
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
            .onClick(() => callBack(item.type));
          };
        }, (item: SortType) => {
          try {
            return JSON.stringify(item);
          } catch (error) {
            hilog.error(this.domainId, this.logTag, 'SortType key stringify error');
            return item.type;
          }
        });
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(8)
      .padding({
        top: 16,
        bottom: 16,
      })
      .divider({
        strokeWidth: 1,
        startMargin: 12,
        endMargin: 12,
      });
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .padding(new BreakpointType<Padding>({
      sm: {
        top: 20,
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      },
      md: {
        top: 20,
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      },
      lg: {
        top: 20,
        left: $r('sys.float.padding_level16'),
        right: $r('sys.float.padding_level16'),
      },
    }).getValue(this.globalInfo.currentBreakpoint));
  }

  @Builder
  sortSheet() {
    Column() {
      this.sheetCard('展示形式', showType, this.toggleShowType, 'showType');
      this.sheetCard('排序方式', sortData, this.sort, 'sortGroup');
    };
  }

  @Builder
  private sortSheetBottom() {
    Column() {
      this.sortSheet();
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.End)
    // 让折叠屏展开态的内容“靠下但不贴底”
    .padding({ bottom: 28 });
  }

  @Builder
  private pcUserCard() {
    Row() {
      Image(this.userInfo.userAvatar)
        .width(56)
        .height(56)
        .borderRadius(28)
        .margin({ left: 12 });

      Text(this.userInfo.userName)
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: 12 });
    }
    .width('100%')
    .height(72)
    .onClick(() => {
      if (this.userInfo.isLogin) {
        this.appPathStack.pushPathByName('MineViewHost', undefined);
      } else {
        this.appPathStack.pushPathByName('QuickLoginPage', undefined);
      }
    });
  }

  @Builder
  private pcCategoryList() {
    Column() {
      Button() {
        Row() {
          Text($r('app.string.go_note_category'))
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium);
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .fontColor([Color.White])
            .padding({ left: 13 });
        };
      }
      .height(40)
      .width('100%')
      .backgroundColor('#FFAA00')
      .borderRadius(12)
      .margin({ bottom: 8 })
      .onClick(() => {
        const params: Record<string, Object | undefined> =
          { 'isEditCategory': true, 'currentCategory': this.currentCategory, 'noteList': undefined };
        this.appPathStack.pushPathByName('EditCategory', params);
      });

      Row({ space: 8 }) {
        Text('全部笔记')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            const defaultCategory =
              this.categoryService.getCategoryById('-1') ?? this.categoryService.getFirstCategory();
            this.resetCategory(defaultCategory);
          });
        Blank();
        SymbolGlyph(this.pcCategoryExpanded ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right'))
          .fontSize(18)
          .fontColor([$r('sys.color.font_secondary')])
          .onClick(() => {
            this.pcCategoryExpanded = !this.pcCategoryExpanded;
          });
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 12 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(12);

      if (this.pcCategoryExpanded) {
        Column() {
          ForEach(this.categoryService.getCategoryList().filter((c) => c.id !== '-1'),
            (category: Category, index: number) => {
              Column() {
                if (index !== 0) {
                  Divider().color($r('sys.color.comp_divider'));
                }
                Row() {
                  Text(category.name)
                    .fontSize(14)
                    .fontColor(this.currentCategory.id === category.id ?
                      $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
                    .fontWeight(this.currentCategory.id === category.id ? FontWeight.Medium : FontWeight.Regular);

                  Blank();
                  Text(String(category.totalCount))
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'));
                }
                .width('100%')
                .height(44);
              }
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.resetCategory(category);
              });
            }, (category: Category) => category.id);
        }
        .borderRadius(12)
        .clip(true)
        .margin({ top: 0, bottom: 12 });
      }
    }
    .width('100%');
  }

  @Builder
  private pcFirstPane() {
    Column({ space: 8 }) {
      this.pcUserCard();
      Scroll() {
        Column({ space: 8 }) {
          Search({
            placeholder: $r('app.string.search_note'),
          })
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .placeholderColor($r('sys.color.font_secondary'))
            .fontColor($r('sys.color.font_primary'))
            .borderRadius(20)
            .onSubmit((value: string) => {
              this.noteList = this.noteSearchController.onSearch(this.currentCategory.id, value,
                this.sortController.sortBy);
              this.updateDataList();
            })
            .onChange((value: string) => {
              if (!value) {
                this.noteList =
                  this.noteSearchController.onSearch(this.currentCategory.id, '', this.sortController.sortBy);
                this.updateDataList();
              }
            });

          this.pcCategoryList();
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .justifyContent(FlexAlign.Start);
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .layoutWeight(1)
      .width('100%');
    }
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12,
    })
    .width('100%')
    .height('100%');
  }

  @Builder
  private pcSecondPane() {
    Column() {
      Row() {
        // 与「我的」等页 PC 顶栏一致：系统左箭头，用于展开/收起第一栏分类侧栏
        SymbolGlyph($r('sys.symbol.arrow_left'))
          .fontSize(20)
          .fontColor([$r('sys.color.font_primary')])
          .margin({ right: 8 })
          .onClick(() => {
            this.pcShowFirstPane = !this.pcShowFirstPane;
          });
        Blank();
        if (this.selectedController.isCtrl) {
          // PC 端多选态：显示“取消选择”按钮
          Image($r('app.media.exit_ctrl'))
            .height(24)
            .width(24)
            .onClick(() => {
              this.noteList.forEach(item => item.isSelected = false);
              this.selectedController.recoverInitState();
            });
        } else {
          Image($r('app.media.icon_more'))
            .height(20)
            .width(20)
            .onClick(() => this.showMethodDialogController.open());
        }
      }
      .width('100%')
      .height(44)
      .alignItems(VerticalAlign.Center)
      .padding({
        left: this.getPcSecondPaneHorizontalInset(),
        right: this.getPcSecondPaneHorizontalInset(),
        top: 0,
        bottom: 8,
      });

      // 列表区域始终占满剩余高度，避免空态时底部工具栏“跑到上面去”
      Column() {
        this.showNoteList();
      }
      .layoutWeight(1)
      .width('100%');

      this.toolBarBuilder();
      this.addNoteBuilder();
    }
    .width('100%')
    .height('100%');
  }

  build() {
    Navigation(this.appPathStack) {
      if (this.isPcLayout()) {
        Row() {
          if (this.pcShowFirstPane) {
            Column() {
              this.pcFirstPane();
            }
            .layoutWeight(2)
            .height('100%');

            Divider()
              .vertical(true)
              .strokeWidth(1)
              .color($r('sys.color.comp_divider'))
              .height('100%');
          }

          Column() {
            this.pcSecondPane();
          }
          .layoutWeight(this.pcShowFirstPane ? 3 : 5)
          .height('100%')
          .backgroundColor($r('sys.color.background_secondary'));

          Column() {
            Stack({ alignContent: Alignment.TopStart }) {
              Column() {
                this.tabletRightPane();
              }
              .width('100%')
              .height('100%')
              .padding({
                top: '8px',
                bottom: '16px',
                left: 0,
                right: '16px',
              })
              .backgroundColor($r('sys.color.comp_background_list_card'))
              .borderRadius(16)
              .clip(true);
            }
            .width('100%')
            .height('100%');
          }
          .layoutWeight(5)
          .height('100%')
          .backgroundColor($r('sys.color.background_secondary'))
          .padding({
            top: 44,
            bottom: '20px',
            left: '8px',
            right: '32px',
          });
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height('100%');
      } else if (this.isTabletLayout()) {
        SideBarContainer() {
          Column() {
            this.phoneLikeHomeColumn();
          }
          .height('100%')
          .width('100%')
          .backgroundColor($r('sys.color.background_secondary'))
          .padding({ right: 12 })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

          Column() {
            this.tabletRightPane();
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
        }
        .sideBarWidth(this.getTabletSideBarWidthVp())
        .sideBarPosition(SideBarPosition.Start)
        .autoHide(false)
        .showControlButton(false)
        .showSideBar(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height('100%');
      } else {
        Column() {
          this.topArea();
          Search({
            placeholder: $r('app.string.search_note'),
          })
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .placeholderColor($r('sys.color.font_secondary'))
            .fontColor($r('sys.color.font_primary'))
            .margin(new BreakpointType<Margin>({
              sm: {
                bottom: 12,
                left: $r('sys.float.padding_level8'),
                right: $r('sys.float.padding_level8'),
              },
              md: {
                bottom: 12,
                left: $r('sys.float.padding_level12'),
                right: $r('sys.float.padding_level12'),
              },
              lg: {
                bottom: 12,
                left: $r('sys.float.padding_level16'),
                right: $r('sys.float.padding_level16'),
              },
            }).getValue(this.globalInfo.currentBreakpoint))
            .onSubmit((value: string) => { // 提交搜索
              this.noteList = this.noteSearchController.onSearch(this.currentCategory.id, value,
                this.sortController.sortBy);
              this.updateDataList();
            })
            .onChange((value: string) => { // 输入变化时
              if (!value) {
                // 清空搜索时恢复列表
                this.noteList =
                  this.noteSearchController.onSearch(this.currentCategory.id, '', this.sortController.sortBy);
                this.updateDataList();
              }
            });

          // 上方工具栏
          this.editorNoteList();

          // 卡片列表
          this.showNoteList();

          // 多选底部工具栏
          this.toolBarBuilder();

          // 新增笔记
          this.addNoteBuilder();
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
        .backgroundColor($r('sys.color.background_secondary'))
        .width('100%')
        .height('100%');
      }
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .onNavBarStateChange(() => {
      this.resetLayout();
    });
  }

  private resetLayout() {
    this.syncPcCategorySelection();
    const kw: string | undefined = AppStorage.get<string>('notes_pc_search_keyword');
    if (kw !== undefined && kw !== '') {
      this.noteSearchController.searchKeyword = kw;
      this.noteSearchController.isSearching = true;
      this.noteList = this.noteSearchController.onSearch(this.currentCategory.id, kw, this.sortController.sortBy);
      AppStorage.delete('notes_pc_search_keyword');
    } else {
      this.noteSearchController.searchKeyword = '';
      this.noteSearchController.isSearching = false;
      this.noteList = this.noteService.getNoteList(
        this.currentCategory.id, this.sortController.sortBy, '');
    }
    this.updateDataList();
  }
}

/**
 * 获取列间距（列表 lane / 瀑布流列间距）
 * 平板、PC 等大屏下瀑布流两列之间原先用 padding12/16，视觉过宽，WaterFlow 单独收紧。
 */
function obtainGutter(breakPoint: BreakpointTypeEnum, type: string): Dimension {
  const isWaterFlow: boolean = type === 'WaterFlow';
  switch (breakPoint) {
    case BreakpointTypeEnum.SM:
      return type === 'List' ? 0 : $r('sys.float.padding_level8');
    case BreakpointTypeEnum.MD:
      return isWaterFlow ? 8 : $r('sys.float.padding_level12');
    default:
      return isWaterFlow ? 8 : $r('sys.float.padding_level16');
  }
}