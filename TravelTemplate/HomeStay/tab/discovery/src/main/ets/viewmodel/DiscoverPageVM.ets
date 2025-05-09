import { AccountUtil } from 'account';
import { https, TravelNoteResp } from 'network';
import { TravelNote } from 'type';
import { LazyDataSource } from 'util';

@ObservedV2
export class DiscoverPageVM {
  @Trace openId: string | undefined = AccountUtil.getOpenId();
  @Trace travelNotes: TravelNote[] = [];
  @Trace list: LazyDataSource<TravelNote> = new LazyDataSource();
  private static _instance: DiscoverPageVM;

  private constructor() {
    this.getTravelNotes();
  }

  async getTravelNotes() {
    const res: TravelNoteResp = await https.queryTravelNotes();
    if (res.code === 200) {
      this.mapTravelNoteInfo(res.data);
    }
  }

  mapTravelNoteInfo(data: TravelNote[]) {
    const travelResp: TravelNote[] = data;
    travelResp.forEach((item: TravelNote) => {
      let travelNoteItem: TravelNote = {
        id: item.id,
        banner: item.banner,
        imageList: item.imageList,
        title: item.title,
        notes: item.notes,
        createTime: item.createTime,
      };
      this.travelNotes.push(travelNoteItem);
    });
    this.list.pushArrayData(this.travelNotes);
  }

  public static get instance() {
    if (!DiscoverPageVM._instance) {
      DiscoverPageVM._instance = new DiscoverPageVM();
    }
    return DiscoverPageVM._instance;
  }
}
