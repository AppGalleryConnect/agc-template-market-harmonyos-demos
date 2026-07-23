import { UIUtils } from '@kit.ArkUI';
import { LoginSheetUtils } from 'lib_account';
import { BaseViewModel, FormatCount } from 'lib_common';
import { MineServiceApi, NewsResponse } from 'lib_news_api';
import { VideoService } from '../services/VideoService';

@ObservedV2
export class SideBarVM extends BaseViewModel {
  @Trace videoInfo: NewsResponse = {} as NewsResponse

  async getVideoInfo(videoId: string) {
    const videoDetailInfo = await VideoService.queryVideoDataById(videoId);
    if (videoDetailInfo) {
      this.videoInfo = UIUtils.makeObserved(videoDetailInfo);
    }
  }

  isFollow() {
    return this.userInfoModel.watchers.includes(this.videoInfo.author.authorId)
  }

  // 关注操作
  followOperation() {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    if (!this.isFollow()) {
      this.follow()
      return
    }
    this.unfollow()
  }

  follow() {
    let authorId = this.videoInfo.author.authorId
    this.userInfoModel.watchers.push(authorId)
    MineServiceApi.addWatch(authorId)
  }

  unfollow() {
    let watchIndex = this.userInfoModel.watchers.findIndex(v => v === this.videoInfo.author.authorId)
    this.userInfoModel.watchers.splice(watchIndex, 1)
    MineServiceApi.cancelWatch(this.videoInfo.author.authorId)
  }

  handlerCoverImage(newsDetails: NewsResponse): string {
    return newsDetails.coverUrl || ''
  }

  // 点赞数
  getLikeCount(): string {
    if (!this.videoInfo.likeCount) {
      return '点赞';
    }
    return this.getLikeNum();
  }

  getLikeNum() {
    return FormatCount.formatNumberToW(this.videoInfo.likeCount);
  }

  // 点赞操作
  likeAction() {
    this.videoInfo.isLiked = !this.videoInfo.isLiked;
    if (this.videoInfo.isLiked) {
      MineServiceApi.addLike(this.videoInfo.id)
      this.videoInfo.likeCount++
      return
    }
    MineServiceApi.cancelLike(this.videoInfo.id)
    this.videoInfo.likeCount--
  }

  // 收藏数
  getMarkCount(): string {
    if (!this.videoInfo.markCount) {
      return '收藏';
    }
    return this.getMarkNum();
  }

  getMarkNum() {
    return FormatCount.formatNumberToW(this.videoInfo.markCount);
  }

  // 收藏操作
  saveAction() {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }

    this.videoInfo.isMarked = !this.videoInfo.isMarked
    if (this.videoInfo.isMarked) {
      MineServiceApi.addMark(this.videoInfo.id)
      this.videoInfo.markCount++
      return
    }
    MineServiceApi.cancelMark(this.videoInfo.id)
    this.videoInfo.markCount--
  }
}