import { SortEnum } from '../commons/Enum';
import { Note } from '../models/Note';
import { CategoryUtil } from './CategotyUtil';

@ObservedV2
export class NoteUtil {
  private static _instance: NoteUtil;

  public static get instance() {
    if (!NoteUtil._instance) {
      NoteUtil._instance = new NoteUtil();
    }
    return NoteUtil._instance;
  }

  @Trace private notes: Note[] = []; // 笔记
  @Trace private dumpsters: Note[] = []; // 回收站

  private categoryUtil: CategoryUtil = CategoryUtil.instance;

  /**
   * 添加笔记
   * @param note
   */
  public addNote(note: Note) {
    this.notes.unshift(note);
    let category = this.categoryUtil.getCategoryList().find((item) => item.id === note.categoryId);
    if (category) {
      category.totalCount++;
      if (category.id !== '-1') {
        this.categoryUtil.getCategoryList()[0].totalCount++;
      }
    }
  }

  /**
   * 更新笔记
   * @param note
   */
  public updateNote(note: Note) {
    const index = this.notes.findIndex((item) => item.id === note.id);
    this.notes.splice(index, 1, note);
  }

  /**
   * 删除笔记
   * @param id
   */
  public deleteNote(id: string | undefined, categoryId?: string) {
    if (!id) {
      return;
    }
    const index = this.notes.findIndex((item) => item.id === id);
    this.dumpsters.push(this.notes[index]);
    this.notes.splice(index, 1);
    // 分类数量-1
    this.categoryUtil.getCategoryList()[0].totalCount--;
    if (categoryId && categoryId !== '-1') {
      let category = this.categoryUtil.getCategoryById(categoryId);
      if (category) {
        category.totalCount--;
      }
    }
  }

  /**
   * 查询笔记列表
   * @param id
   * @returns
   */
  public getNoteList(id?: string, sortType?:SortEnum, keyWord:string = ''): Note[] {
    let notes: Note[] = this.search(keyWord);
    if (id !== undefined && id !== '-1') {
      notes = notes.filter((item) => item.categoryId === id);
    }
    if (sortType === SortEnum.CREATE_TIME) {
      notes = notes.sort((a, b) => parseInt(b.createTime) - parseInt(a.createTime));
    } else if (sortType === SortEnum.UPDATE_TIME){
      notes = notes.sort((a, b) =>  parseInt(b.updateTime) - parseInt(a.updateTime));
    }

    return notes;
  }

  /**
   * 根据分类ID查询回收站笔记列表
   * @param id
   * @returns
   */
  public getNoteListTrash(id?: string): Note[] {
    if (id !== undefined && id !== '-1') {
      return this.dumpsters.filter((item) => item.categoryId === id);
    }
    return this.dumpsters;
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
  public search(keyword: string): Note[]  {
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
  public deletePermanently(id: string) {
    const index = this.dumpsters.findIndex((item) => item.id === id);
    if (index !== -1) {
      this.dumpsters.splice(index, 1);
    }
  }

  /**
   * 恢复
   * @param id
   */
  public recoverNote(id: string) {
    const index = this.dumpsters.findIndex((item) => item.id === id);
    if (index !== -1) {
      const note = this.dumpsters[index];
      this.notes.push(note);
      this.dumpsters.splice(index, 1);

      // 更新分类计数
      const category = this.categoryUtil.getCategoryById(note.categoryId);
      if (category) {
        category.totalCount++;
        if (category.id !== '-1') {
          this.categoryUtil.getCategoryList()[0].totalCount++;
        }
      }
    }
  }

  /**
   * 移动笔记分类
   * @param fromId 源id
   * @param targetId 目标id
   */
  public moveNotesCategory(fromId: string, targetId?: string) {
    if (targetId) {
      this.notes.filter((item) => item.categoryId === fromId)?.forEach((item) => {
        item.categoryId = targetId;
      });
      return;
    }
    this.notes.filter((item) => item.categoryId === fromId)?.forEach((item) => {
      item.categoryId = '-1';
    });
  }


  public initSelectedState(){
    this.notes.forEach(item => item.isSelected = false)
  }

  public deleteNotes(notes: Note[]): Note[]{
    notes.forEach((item) => {this.deleteNote(item.id, item.categoryId)})
    return this.notes
  }
}