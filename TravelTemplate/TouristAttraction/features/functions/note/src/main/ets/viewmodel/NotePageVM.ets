import { LazyDataSource } from 'common';
import { httpsMock } from 'network';
import { NoteInfo } from 'types';
import { mapperNoteList } from '../mapper/Index';

@ObservedV2
export class NotePageVM {
  public static _instance: NotePageVM;
  @Trace noteList: LazyDataSource<NoteInfo> = new LazyDataSource();

  public static get instance() {
    if (!NotePageVM._instance) {
      NotePageVM._instance = new NotePageVM();
    }
    return NotePageVM._instance;
  }

  public constructor() {
    this.getNoteList();
  }

  getNoteList() {
    httpsMock.getNoteList().then((res) => {
      this.noteList.pushArrayData(mapperNoteList(res.data));
    });
  }
}