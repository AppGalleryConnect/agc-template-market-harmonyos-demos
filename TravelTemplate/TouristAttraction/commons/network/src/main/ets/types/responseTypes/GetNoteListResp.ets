export interface NoteListItem {
  noteId: number;
  name: string;
  banner: ResourceStr;
}

export interface GetNoteListResp extends Array<NoteListItem> {}