import { Note } from 'richeditor';
import { CategoryService } from './CategotyService';
import { SortEnum } from './Model';
import { KVStore, SerializeUtil } from 'serializer';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { PreferencesUtil } from './PreferencesUtil';
import { BusinessError } from '@kit.BasicServicesKit';

@ObservedV2
export class NoteService {
  logTag: string = '[NoteService]';
  domainId: number = 0x0000;
  private static _instance: NoteService;

  public static get instance() {
    if (!NoteService._instance) {
      NoteService._instance = new NoteService();
    }
    return NoteService._instance;
  }

  @Trace private notes: Note[] = []; // 笔记
  @Trace private dumpsters: Note[] = []; // 回收站

  private categoryService: CategoryService = CategoryService.instance;

  /**
   * 读取有效笔记
   * @param kvStore
   * @param hostContext 添加context参数用于获取preferences
   */
  public async loadEffectiveNote(kvStore: KVStore, hostContext?: Context) {
    kvStore.getAll('EffectiveNote').then(async (dataList) => {
      const promises = dataList?.map(async data => {
        const serializedNote = JSON.parse(data.value as string) as Note;

        let mss = await SerializeUtil.deserialize(serializedNote.serializedStyledString) as MutableStyledString;
        const note = this.constructNote(mss, serializedNote);

        this.addNote(note);
        hilog.info(this.domainId, this.logTag, `Load note ${note.id} success.`);
      }) || [];
      await Promise.all(promises);
      this.saveNotesToPreferences(hostContext as Context);
      hilog.info(this.domainId, this.logTag, `Load note data success.`);
    });
  }

  /**
   * 获取卡片展示用的前两条笔记（按创建时间倒序），按 id 去重，不修改 this.notes。
   * 返回 [最新, 次新]；卡片展示顺序为：第一行=最新，第二行=次新（保持与首页列表前两条一致）。
   */
  public getRecentNotesForCard(sortType: SortEnum = SortEnum.CREATE_TIME): Note[] {
    const seenIds = new Set<string>();
    const list = this.notes.filter((n) => {
      if (seenIds.has(n.id)) {
        return false;
      }
      seenIds.add(n.id);
      return true;
    });
    if (sortType === SortEnum.CREATE_TIME) {
      list.sort((a, b) => parseInt(b.createTime) - parseInt(a.createTime));
    } else {
      list.sort((a, b) => parseInt(b.updateTime) - parseInt(a.updateTime));
    }
    return list.slice(0, 2);
  }

  /**
   * 将笔记数据保存到preferences
   */
  private saveNotesToPreferences(hostContext?: Context): void {
    try {
      if (!hostContext) {
        hilog.info(this.domainId, this.logTag, 'saveNotesToPreferences: hostContext is undefined');
        return;
      }

      const preferencesUtil = PreferencesUtil.getInstance();
      const preference = preferencesUtil.getPreferences(hostContext);

      const recentNotes = this.getRecentNotesForCard(SortEnum.CREATE_TIME);
      const firstNote = recentNotes.length >= 1 ? recentNotes[0] : null; // 首页列表的第一条（最新）
      const secondNote = recentNotes.length >= 2 ? recentNotes[1] : null; // 首页列表的第二条（次新）

      const totalNotesCount = this.notes.length;
      preferencesUtil.preferencesPut(preference, 'totalNotesCount', totalNotesCount);

      if (firstNote) {
        preferencesUtil.preferencesPut(preference, 'firstNoteTitle', firstNote.title);
        preferencesUtil.preferencesPut(preference, 'firstNoteTime', firstNote.createTime);
      } else {
        preferencesUtil.preferencesPut(preference, 'firstNoteTitle', '');
        preferencesUtil.preferencesPut(preference, 'firstNoteTime', '');
      }
      if (secondNote) {
        preferencesUtil.preferencesPut(preference, 'secondNoteTitle', secondNote.title);
        preferencesUtil.preferencesPut(preference, 'secondNoteTime', secondNote.createTime);
      } else {
        preferencesUtil.preferencesPut(preference, 'secondNoteTitle', '');
        preferencesUtil.preferencesPut(preference, 'secondNoteTime', '');
      }

      preferencesUtil.preferencesPut(preference, 'hasNotes', recentNotes.length > 0);
      preferencesUtil.preferencesPut(preference, 'hasTwoNotes', recentNotes.length >= 2);

      hilog.info(this.domainId, this.logTag, 'saveNotesToPreferences 卡片数据已更新');
      hilog.info(this.domainId, this.logTag,
        `saveNotesToPreferences 第一条标题=${firstNote?.title ?? ''}, 第一条时间=${firstNote?.createTime ?? ''}, 第二条标题=${secondNote?.title ?? ''}, 第二条时间=${secondNote?.createTime ?? ''}`);

      this.updateFormCards(hostContext, preferencesUtil, preference, firstNote, secondNote, totalNotesCount);
    } catch (error) {
      hilog.error(this.domainId, this.logTag, `保存笔记到preferences失败: ${JSON.stringify(error)}`);
    }
  }

  private updateFormCards(
    hostContext: Context,
    preferencesUtil: PreferencesUtil,
    preference: preferences.Preferences,
    firstNote: Note | null,
    secondNote: Note | null,
    totalNotesCount: number,
  ): void {
    try {
      hilog.info(this.domainId, this.logTag,
        `updateFormCards 第一条标题=${firstNote?.title ?? ''}, 第一条时间=${firstNote?.createTime ?? ''}, 第二条标题=${secondNote?.title ?? ''}, 第二条时间=${secondNote?.createTime ?? ''}`);
      const cardData: Record<string, preferences.ValueType> = {
        'hasNotes': firstNote !== null || secondNote !== null,
        'hasTwoNotes': firstNote !== null && secondNote !== null,
        'firstNoteTitle': firstNote?.title ?? '',
        'firstNoteTime': firstNote?.createTime ?? '',
        'secondNoteTitle': secondNote?.title ?? '',
        'secondNoteTime': secondNote?.createTime ?? '',
        'totalNotesCount': totalNotesCount,
        'time':new Date().getTime()
      };
      const formData = formBindingData.createFormBindingData(cardData);
      hilog.info(this.domainId, this.logTag,
        `createFormBindingData 后 cardData 第一条标题=${cardData.firstNoteTitle ??
          ''}, 第二条标题=${cardData.firstNoteTitle ?? ''}`);

      formProvider.getPublishedRunningFormInfos().then((data: formInfo.RunningFormInfo[]) => {
        hilog.info(this.domainId, this.logTag,
          `formProvider getPublishedRunningFormInfos, data: ${JSON.stringify(data)}`);

        data.forEach((form) => {
          let formId = form.formId
          formProvider.updateForm(formId, formData)
            .then(() => hilog.info(this.domainId, this.logTag, '更新成功'))
            .catch((err: ESObject) => hilog.error(this.domainId, this.logTag, `更新失败: ${JSON.stringify(err)}`));
        })
      }).catch((error: BusinessError) => {
        hilog.error(this.domainId, this.logTag,
          `promise error, code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      hilog.warn(this.domainId, this.logTag, `updateFormCards: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 读取回收站笔记
   * @param kvStore
   */
  public async loadDeleteNote(kvStore: KVStore) {
    kvStore.getAll('DeleteNote').then(async (dataList) => {
      const promises = dataList?.map(async data => {
        const serializedNote = JSON.parse(data.value as string) as Note;

        let mss = await SerializeUtil.deserialize(serializedNote.serializedStyledString) as MutableStyledString;
        const note = this.constructNote(mss, serializedNote);

        this.dumpsters.push(note);
        hilog.info(this.domainId, this.logTag, `Load note ${note.id} success.`);
      }) || [];

      await Promise.all(promises);
      hilog.info(this.domainId, this.logTag, `Load note data success.`);
    });
  }


  /**
   * 添加笔记
   * @param note 笔记
   * @param kvStore 可选
   * @param uiContext 可选
   * @param skipPersist
   */
  public async addNote(note: Note, kvStore?: KVStore, uiContext?: UIContext, skipPersist?: boolean) {
    const existingIndex = this.notes.findIndex((n) => n.id === note.id);
    if (existingIndex >= 0) {
      this.notes.splice(existingIndex, 1, note);
      if (kvStore && uiContext && !skipPersist) {
        putNoteInKvStore(note, uiContext, kvStore, 'EffectiveNote');
      }
      if (uiContext) {
        this.saveNotesToPreferences(uiContext.getHostContext() as Context);
      }
      return;
    }
    this.notes.unshift(note);
    let category = this.categoryService.getCategoryList().find((item) => item.id === note.categoryId);
    if (category) {
      category.totalCount++;
      if (category.id !== '-1') {
        this.categoryService.getCategoryList()[0].totalCount++;
      }
    }

    if (kvStore && uiContext && !skipPersist) {
      putNoteInKvStore(note, uiContext, kvStore, 'EffectiveNote');
    }
    if (uiContext) {
      this.saveNotesToPreferences(uiContext.getHostContext() as Context);
    }
  }

  /**
   * 更新笔记
   * @param hostContext 可选，用于刷新卡片
   */
  public updateNote(note: Note, kvStore?: KVStore, uiContext?: UIContext, hostContext?: Context) {
    const index = this.notes.findIndex((item) => item.id === note.id);
    this.notes.splice(index, 1, note);

    if (kvStore && uiContext) {
      putNoteInKvStore(note, uiContext, kvStore, 'EffectiveNote');
    }

    const recentNotes = this.getRecentNotesForCard(SortEnum.CREATE_TIME);
    const firstNote = recentNotes.length >= 1 ? recentNotes[0] : null;
    const secondNote = recentNotes.length >= 2 ? recentNotes[1] : null;
    hilog.info(this.domainId, this.logTag,
      `updateNote 第一条标题=${firstNote?.title ?? ''}, 第一条时间=${firstNote?.createTime ?? ''}, 第二条标题=${secondNote?.title ?? ''}, 第二条时间=${secondNote?.createTime ?? ''}`);
    const ctx = hostContext ?? (uiContext?.getHostContext() as Context | undefined);
    this.saveNotesToPreferences(ctx);
  }

  /**
   * 删除笔记到回收站
   * @param id
   */
  public deleteNoteToTrash(id: string | undefined, categoryId?: string, kvStore?: KVStore, uiContext?: UIContext) {
    if (!id) {
      return;
    }
    const index = this.notes.findIndex((item) => item.id === id);
    let delNote: Note = this.notes[index];
    this.dumpsters.push(delNote);
    this.notes.splice(index, 1);
    // 分类数量-1
    this.categoryService.getCategoryList()[0].totalCount--;
    if (categoryId && categoryId !== '-1') {
      let category = this.categoryService.getCategoryById(categoryId);
      if (category) {
        category.totalCount--;
      }
    }

    if (kvStore && uiContext) {
      deleteNoteInKvStore(id, 'EffectiveNote', kvStore);
      putNoteInKvStore(delNote, uiContext, kvStore, 'DeleteNote');
    }

    this.saveNotesToPreferences(uiContext?.getHostContext() as Context);

  }

  /**
   * 查询笔记列表
   * @param id
   * @returns
   */
  public getNoteList(id?: string, sortType?: SortEnum, keyWord: string = ''): Note[] {
    let notes: Note[] = this.search(keyWord);
    hilog.debug(this.domainId, this.logTag, `getNoteList notes: ${JSON.stringify(notes)}`);
    if (id !== undefined && id !== '-1') {
      notes = notes.filter((item) => item.categoryId === id);
    }
    if (sortType === SortEnum.CREATE_TIME) {
      notes = notes.sort((a, b) => parseInt(b.createTime) - parseInt(a.createTime));
    } else if (sortType === SortEnum.UPDATE_TIME) {
      notes = notes.sort((a, b) => parseInt(b.updateTime) - parseInt(a.updateTime));
    }

    return notes;
  }

  /**
   * 在回收站中搜索笔记
   * @param keyword
   * @returns
   */
  public searchInDumpsters(keyword: string): Note[] | undefined {
    if (!keyword) {
      return this.dumpsters; // 空关键词返回所有回收站笔记
    }
    const lowerKeyword = keyword.toLowerCase();

    return this.dumpsters.filter((item) => {
      return item.title.toLowerCase().includes(lowerKeyword) ||
      item.description.toLowerCase().includes(lowerKeyword);
    });
  }

  /**
   * 根据id获取笔记
   * @param id
   * @returns
   */
  public getNoteById(id: string): Note | undefined {
    if (id === '') {
      return undefined;
    }
    return this.notes.find((item) => item.id === id);
  }

  /**
   * 简单搜索
   * @param keyword
   * @returns
   */
  public search(keyword: string): Note[] {
    hilog.debug(this.domainId, this.logTag, `search notes count: ${this.notes.length}`);
    if (!keyword) {
      return this.notes; // 空关键词返回所有笔记
    }
    const lowerKeyword = keyword.toLowerCase();

    return this.notes.filter((item) => {
      return item.title.toLowerCase().includes(lowerKeyword) ||
      item.description.toLowerCase().includes(lowerKeyword);
    });
  }

  /**
   * 查询回收站数据
   * @returns
   */
  public getDumpstersData(): Note[] {
    return this.dumpsters;
  }

  /**
   * 永久删除
   * @param id
   */
  public deletePermanently(id: string, kvStore?: KVStore) {
    const index = this.dumpsters.findIndex((item) => item.id === id);
    if (index !== -1) {
      this.dumpsters.splice(index, 1);
    }

    if (kvStore) {
      deleteNoteInKvStore(id, 'DeleteNote', kvStore);
    }
  }

  /**
   * 恢复
   * @param id
   */
  public recoverNote(id: string, kvStore?: KVStore, uiContext?: UIContext) {
    const index = this.dumpsters.findIndex((item) => item.id === id);
    if (index !== -1) {
      const note = this.dumpsters[index];
      this.notes.push(note);
      this.dumpsters.splice(index, 1);

      // 更新分类计数
      const category = this.categoryService.getCategoryById(note.categoryId);
      if (category) {
        category.totalCount++;
        if (category.id !== '-1') {
          this.categoryService.getCategoryList()[0].totalCount++;
        }
      }

      if (kvStore && uiContext) {
        deleteNoteInKvStore(id, 'DeleteNote', kvStore);
        putNoteInKvStore(note, uiContext, kvStore, 'EffectiveNote');
      }

      this.saveNotesToPreferences(uiContext?.getHostContext() as Context);

    }
  }

  /**
   * 移动笔记分类
   * @param categoryId 源id
   */
  public moveNotesCategory(categoryId: string, kvStore: KVStore, uiContext: UIContext) {
    this.notes.filter(note => note.categoryId === categoryId)?.forEach(note => {
      note.categoryId = '-1';

      deleteNoteInKvStore(note.id, 'EffectiveNote', kvStore);
      putNoteInKvStore(note, uiContext, kvStore, 'EffectiveNote');
    });
  }

  public deleteNotesToTrash(notes: Note[], kvStore?: KVStore, uiContext?: UIContext): Note[] {
    notes.forEach((item) => {
      this.deleteNoteToTrash(item.id, item.categoryId, kvStore, uiContext);
    });
    if (uiContext) {
      this.saveNotesToPreferences(uiContext.getHostContext() as Context);
    }
    return this.notes;
  }

  private constructNote(value: MutableStyledString, serializedNote: Note) {
    const note = new Note(value);
    note.id = serializedNote.id;
    note.title = serializedNote.title;
    note.categoryId = serializedNote.categoryId;
    note.createTime = serializedNote.createTime;
    note.updateTime = serializedNote.updateTime;
    note.description = serializedNote.description;
     // 新增字段向下兼容：未保存过的新字段时使用默认值
     note.noteType = (serializedNote as ESObject).noteType ?? 'normal';
     note.audioUri = (serializedNote as ESObject).audioUri ?? '';
    return note;
  }
}

/**
 * 持久化 删除笔记
 * @param id
 * @param kvStore
 */
function deleteNoteInKvStore(id: string, prefix: string, kvStore: KVStore) {
  const key = prefix + '_' + id;
  kvStore.delete(key);
}

/**
 * 持久化 保存笔记
 * @param note
 * @param uiContext
 * @param kvStore
 * @param prefix
 */
function putNoteInKvStore(note: Note, uiContext: UIContext, kvStore: KVStore, prefix: string) {
  SerializeUtil.serialize(note.styledString, uiContext).then(value => {
    let key = prefix + '_' + note.id;
    note.serializedStyledString = value;
    if (!note.handwriteFileName && note.id) {
      note.handwriteFileName = `handwrite_${note.id}`;
    }
    kvStore.put(key, JSON.stringify(note).replace(/__ob_/g, ''));
  });
}
