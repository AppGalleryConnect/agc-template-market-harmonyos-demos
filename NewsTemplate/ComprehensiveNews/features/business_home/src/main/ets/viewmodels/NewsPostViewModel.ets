import { AppStorageV2 } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import {
  BaseViewModel,
  BreakpointModel,
  BreakpointNameEnum,
  CoverUri,
  EventEnum,
  RouterMap,
  RouterUtils,
} from 'lib_common'
import { ArticleServiceApi, PostImgList } from 'lib_news_api'
import { Constants, NewsStyleEnum, newsStyleList, videoSetting } from '../constants/NewsConstants'

@ObservedV2
export class NewsPostViewModel extends BaseViewModel {
  @Trace title: string = ''
  @Trace content: string = ''
  @Trace coverThreeList: CoverUri[] = [new CoverUri(), new CoverUri(), new CoverUri()]
  @Trace coverSingleList: CoverUri[] = [new CoverUri()]
  @Trace selectedId: string = NewsStyleEnum.IMAGE_NONE
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get isSmDevice() {
    return this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM
  }

  @Computed
  get isLgDevice() {
    return this.breakpointModel.currentBreakpoint === BreakpointNameEnum.LG
  }

  public getPostVideoWidth() {
    return this.isSmDevice || this.isLgDevice ? Constants.VIDEO_SIZE_SM_W : Constants.VIDEO_SIZE_LG_W
  }

  public getPostVideoHeight() {
    return this.isSmDevice || this.isLgDevice ? Constants.VIDEO_SIZE_SM_H : Constants.VIDEO_SIZE_LG_H
  }

  public async publishNews() {
    let message = await this.validate()
    if (message) {
      this.contextModel.showToast({ message: message })
      return
    }
    /*
     * 确定文章发布需要用到的模板
     * 一张图需要左文右图
     * 三张图需要上文下图
     * */
    let postImgList: PostImgList[] = []
    if (this.selectedId === NewsStyleEnum.IMAGE_SINGLE) {
      postImgList.push({
        picVideoUrl: this.coverSingleList[0].uri,
        surfaceUrl: '',
      })
    }
    if (this.selectedId === NewsStyleEnum.IMAGE_THREE) {
      this.coverThreeList.forEach(item => postImgList.push({
        picVideoUrl: item.uri,
        surfaceUrl: '',
      }))
    }
    let setting = newsStyleList.find(item => item.id === this.selectedId)?.setting as string
    ArticleServiceApi.addArticle(this.title, this.handleImageSize(this.content), setting, postImgList).then(() => {
      // 添加到动态布局文件中
      RouterUtils.popToName(RouterMap.INDEX_PAGE);
      // 通知关注刷新
      emitter.emit(EventEnum.HOME_FOLLOW_REFRESH);
    })
  }

  public async publishVideo(surface: string, videoUri: string, title: string) {
    if (title.length > 30) {
      this.contextModel.showToast({ message: '描述不超过30字' })
      return;
    }
    if (!surface) {
      this.contextModel.showToast({ message: '未上传视频' })
      return;
    }
    /**
     * 使用视频模板
     */
    const postImgList: PostImgList[] = [
      {
        picVideoUrl: videoUri,
        surfaceUrl: surface,
      },
    ]
    ArticleServiceApi.addArticle(title, '', videoSetting, postImgList).then(async (articleInfo) => {
      // 添加到动态布局文件中
      await ArticleServiceApi.addFlexLayout(articleInfo.id, videoSetting);
      RouterUtils.replacePathByName(RouterMap.INDEX_PAGE);
      // 通知首页刷新
      emitter.emit(EventEnum.HOME_FOLLOW_REFRESH);
    })
  }

  public handleImageSize(content: string) {
    // 需要统一处理富文本image的宽高
    const contentResp = content.replaceAll('<img', '<img class="image-preview post-image"')
    return contentResp
  }

  public async validate() {
    let message = ''
    if (this.selectedId === NewsStyleEnum.IMAGE_SINGLE) {
      message = this.coverSingleList[0].uri ? '' : '封面图未上传'
    }
    if (this.selectedId === NewsStyleEnum.IMAGE_THREE) {
      let len = this.coverThreeList.filter(item => !item.uri).length
      message = len ? `还有${len}张封面未上传` : ''
    }
    return message
  }
}