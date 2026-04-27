
@ObservedV2
export class IdCardInfo {
  id: number = 0;
  title: ResourceStr = '';
  icon: ResourceStr = '';
  @Trace cardImg: ResourceStr = '';

  constructor(id: number, title: ResourceStr, icon: ResourceStr) {
    this.id = id;
    this.title = title;
    this.icon = icon
  }
}