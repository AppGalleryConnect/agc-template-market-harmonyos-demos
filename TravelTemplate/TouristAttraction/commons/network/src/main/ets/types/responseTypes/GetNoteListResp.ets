export interface NoteListItem {
  noteId: number;
  name: string;
  banner: ResourceStr;
  tag: number;
  location: string;
}

export interface GetNoteListResp extends Array<NoteListItem> {}