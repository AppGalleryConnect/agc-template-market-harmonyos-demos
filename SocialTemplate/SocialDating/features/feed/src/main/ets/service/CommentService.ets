import { BaseService, CommonRsp,Comment, Constants, MockService } from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import { http } from '@kit.NetworkKit';

export class CommentService extends BaseService {
  async createComment(currentUid: number | null | undefined, feedId: number | null | undefined, commentTxt: string,
    theCommentToReply?: Comment | null): Promise<CommonRsp | null> {
    if (currentUid == null || currentUid === undefined || feedId == null || feedId === undefined) {
      Logger.error('createComment req invalid, currentUid=' + currentUid + ', feedId=' + feedId)
      return null;
    }
    if (this.serviceConfig.isMock) {
      return MockService.createComment(currentUid, feedId, commentTxt, theCommentToReply)
    }
    let rsp =
      await this.doRequest<CommonRsp>('/comment', http.RequestMethod.POST,
        JSON.stringify(new CreateCommentReq(currentUid, feedId, commentTxt, theCommentToReply?.recipientUid,
          theCommentToReply?.recipientNickName)));
    if (rsp == null || rsp.retCode !== Constants.RET_SUCCESS_CODE) {
      Logger.error('createComment failed, uid=' + currentUid + ', feedId=' + feedId);
      return null;
    } else {
      return rsp;
    }
  }
}

export default new CommentService({
  baseUrl: BaseService.BASE_URL_MOCK, isMock: true
});

class CreateCommentReq {
  uid: number;
  feedId: number;
  content: string;
  recipientUid: number | undefined;
  recipientNickName: string | undefined;

  constructor(uid: number, feedId: number, content: string, recipientUid: number | undefined | null,
    recipientNickName: string | null | undefined) {
    this.uid = uid;
    this.feedId = feedId;
    this.content = content;
    if (recipientUid != null && recipientUid !== undefined) {
      this.recipientUid = recipientUid;
    }
    if (recipientNickName != null && recipientNickName !== undefined) {
      this.recipientNickName = recipientNickName;
    }
  }
}