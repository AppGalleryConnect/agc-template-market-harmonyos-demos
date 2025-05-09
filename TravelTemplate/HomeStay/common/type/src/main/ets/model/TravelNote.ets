export class TravelNote {
  id: number = 0;
  banner: string | Resource = $r('app.media.icon');
  imageList: string[] | Resource[] = [];
  title: string = '';
  notes: string = '';
  createTime: string = '';
}