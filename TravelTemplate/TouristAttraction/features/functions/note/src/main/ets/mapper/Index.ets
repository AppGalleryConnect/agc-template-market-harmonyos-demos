import { GetNoteDetailResp, GetNoteListResp } from 'network';
import { NoteInfo } from 'types';

export function mapperNoteInfo(getNoteDetailResp: GetNoteDetailResp) {
  let noteInfo = new NoteInfo;
  noteInfo.noteId = getNoteDetailResp.noteId;
  noteInfo.name = getNoteDetailResp.name;
  noteInfo.banner = getNoteDetailResp.banner;
  noteInfo.banners = getNoteDetailResp.banners;
  noteInfo.detail = getNoteDetailResp.detail;
  noteInfo.createTime = getNoteDetailResp.createTime;
  return noteInfo;
}

export function mapperNoteList(getNoteListResp: GetNoteListResp) {
  let noteList: NoteInfo[] = [];
  getNoteListResp.forEach(item => {
    let noteInfo = new NoteInfo();
    noteInfo.noteId = item.noteId;
    noteInfo.name = item.name;
    noteInfo.banner = item.banner;
    noteList.push(noteInfo);
  });
  return noteList;
}