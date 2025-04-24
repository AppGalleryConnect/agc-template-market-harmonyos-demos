@ObservedV2
export class ServiceItem {
  @Trace logo: string = '';
  @Trace name: string = '';
  @Trace linkNextPagePath: string = '';
  @Trace linkNextPageDesc: string = '';

  constructor(logo: string, name: string, linkNextPagePath: string, linkNextPageDesc: string) {
    this.logo = logo;
    this.name = name;
    this.linkNextPageDesc = linkNextPageDesc;
    this.linkNextPagePath = linkNextPagePath;
  }
}