export interface GetNoteDetailResp {
  noteId: number;
  name: string;
  banner: ResourceStr;
  banners: ResourceStr[];
  detail: string;
  createTime: string
}

export interface GetNoteDetailsResp extends Array<GetNoteDetailResp> {}