export class CreateFeedRequest{
  uid:number;
  feedMsg:string|null;
  resourceUrls:string[];

  constructor(uid: number, feedMsg: string|null, resourceUrls: string[]) {
    this.uid = uid;
    this.feedMsg = feedMsg;
    this.resourceUrls = resourceUrls;
  }
}