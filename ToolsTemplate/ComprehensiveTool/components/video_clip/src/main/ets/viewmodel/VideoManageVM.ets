import { UtilLog } from '@hw-agconnect/util-log';
import { BusinessError } from '@ohos.base';
import { fileIo as fs } from '@kit.CoreFileKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { MemberSheetUtils } from 'membership';
import { LoginManageUtil, MAX_FREE_USE_TIME, MemberManageUtil, UsedCount } from 'module_base';
import sdk from 'libveditor.so';
import { EditVideo, VideoAsset, VideoDraftList } from '../model/Index';
import { LoginSheetUtils } from 'aggregated_login';
import { Util } from '../util/Util';
import { VideoUtil } from '../util/VideoUtil';
import { Constant } from '../common/Constant';

@ObservedV2
export class VideoManageVM {
  private static _instance: VideoManageVM;
  @Trace videoUri: string | undefined = undefined;
  @Trace draftTabIndex: number = 0;
  @Trace drafts: VideoDraftList =
    PersistenceV2.connect(VideoDraftList, 'VideoDraftList', () => new VideoDraftList())!;
  @Trace recycles: VideoDraftList =
    PersistenceV2.connect(VideoDraftList, 'VideoRecycleList', () => new VideoDraftList())!;
  @Trace usedCount: UsedCount =
    PersistenceV2.connect(UsedCount, 'VideoUsedCount', () => new UsedCount())!;
  @Trace isMember: boolean = false;
  @Trace screenWidth: Length | undefined = 0;
  @Trace oldScreenWidth: Length | undefined = 0;
  @Trace screenHeight: Length | undefined = 0;
  @Trace oldScreenHeight: Length | undefined = 0;
  @Trace pathStack: NavPathStack = new NavPathStack();
  @Trace selectedDrafts: EditVideo[] = [];
  @Trace selectedRecycles: EditVideo[] = [];
  @Trace isEdit: boolean = false;
  @Trace isAccept: boolean = false;
  @Trace timeStamp: number = 0;
  fd: number = 0;
  file: fs.File | undefined = undefined;
  draftCategory: string[] = ['剪辑', '回收站'];

  public static get instance() {
    if (!VideoManageVM._instance) {
      VideoManageVM._instance = new VideoManageVM();
    }
    return VideoManageVM._instance;
  }

  showMemberSubscribeDialog(uiContext: UIContext) {
    let memberManageUtil = new MemberManageUtil(uiContext);
    MemberSheetUtils.open(memberManageUtil.productsInfo, uiContext);
  }

  handleDraftClickEvent(uiContext: UIContext, loginManageUtil: LoginManageUtil, video: EditVideo) {
    try {
      if (this.draftTabIndex === 1) {
        uiContext.getPromptAction().showToast({
          message: '回收站内的草稿不支持编辑',
          duration: 1000,
        });
        return;
      }

      if (!loginManageUtil.userInfoModel.isLogin) {
        LoginSheetUtils.open(loginManageUtil.params, uiContext);
        return;
      } else if (!this.isMember && this.usedCount.count > MAX_FREE_USE_TIME) {
        this.showMemberSubscribeDialog(uiContext);
        return;
      }

      // 记录当前操作时间戳
      let timeStamp = Date.now();
      let interval = timeStamp - this.timeStamp;

      if (this.timeStamp && interval <= 3000) {
        uiContext.getPromptAction().showToast({message : '操作太快了，请稍后重试'});
        return;
      } else {
        this.timeStamp = timeStamp;
      }

      this.videoUri = video.mediaUri;
      this.file = fs.openSync(video.mediaUri);
      this.fd = this.file.fd;

      let res: number = sdk.SetVideo(this.videoUri, this.fd);

      UtilLog.info(0xFF00, 'VideoClip', `selected draft URI: ${this.videoUri}, fd: ${this.fd}`);

      if (res === 0) {
        let videoAsset: VideoAsset = {
          videoUri: video.mediaUri,
          fd: this.fd,
          screenWidth: this.screenWidth,
          screenHeight: this.screenHeight,
        };
        this.pathStack.pushPathByName('VideoEdit', videoAsset, (popInfo: PopInfo) => {
          let draft = popInfo.result as EditVideo;
          this.drafts.list.unshift(draft);
        });
      }
    } catch (e) {
      uiContext.getPromptAction().showToast({ message: '请排查草稿视频是否存在或其他异常' });
      UtilLog.info(0xFF00, 'VideoClip', `请排查草稿视频是否存在或其他原因 ${e}`);
    }
  }

  async selectVideo(uiContext: UIContext) {
    try {
      let productModel: string = deviceInfo.productModel;
      if (productModel === 'emulator') {
        uiContext.getPromptAction().showToast({ message: '当前设备不支持剪辑，请使用真机使用~' });
        return
      }

      let options: photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE,
        isEditSupported: false,
        maxSelectNumber: 1,
        isPhotoTakingSupported: false,
        isSearchSupported: true,
        isOriginalSupported: true,
      };
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(options).then((selectResult: photoAccessHelper.PhotoSelectResult) => {
        if (selectResult.photoUris.length === 0) {
          UtilLog.info(0xFF00, 'VideoClip', `no photo are selected.`);
        } else {
          selectResult.photoUris.forEach(async (uri) => {
            UtilLog.info(0xFF00, 'VideoClip', `selected photo URI: ${uri}`);
            this.videoUri = uri;

            let asset = await Util.getVideoAsset(this.videoUri, uiContext.getHostContext()!);

            const fileSize = VideoUtil.fileBytesToMB(asset?.get(photoAccessHelper.PhotoKeys.SIZE) as number);

            if (fileSize >= Constant.MAX_FILE_SIZE) {
              uiContext.getPromptAction().showToast({ message: `最大支持剪辑${Constant.MAX_FILE_SIZE}MB以内视频!` });
              return;
            }

            this.file = fs.openSync(this.videoUri);
            this.fd = this.file.fd;

            let res: number = sdk.SetVideo(this.videoUri, this.fd);

            if (res === 0) {
              let videoAsset: VideoAsset = {
                videoUri: this.videoUri,
                fd: this.fd,
                screenWidth: this.screenWidth,
                screenHeight: this.screenHeight,
              };
              this.pathStack.pushPathByName('VideoEdit', videoAsset, (popInfo: PopInfo) => {
                this.drafts.list.unshift(popInfo.result as EditVideo);
              });
            } else {
              uiContext.getPromptAction().showToast({
                message: '请选择要创作的视频',
              });
            }
          });
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(0xFF00, 'VideoClip', `PhotoPicker,select failed with err: ${err.code},${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      UtilLog.error(0xFF00, 'VideoClip', `PhotoPicker,select failed with err: ${err.code},${err.message}`);
    }
  }

  clearCheckStatus() {
    if (this.draftTabIndex === 0) {
      this.drafts.list.map(item => item.isSelect = false);
    } else {
      this.recycles.list.map(item => item.isSelect = false);
    }
  }

  selectDraft(video: EditVideo, value: boolean) {
    // 如为勾选
    if (value) {
      this.selectedDrafts.push(video);
    } else {
      this.selectedDrafts = this.selectedDrafts.filter(item => item.videoId !== video.videoId);
    }
  }

  selectRecycle(video: EditVideo, value: boolean) {
    // 如为勾选
    if (value) {
      this.selectedRecycles.push(video);
    } else {
      this.selectedRecycles = this.selectedRecycles.filter(item => item.videoId !== video.videoId);
    }
  }

  moveToRecycle() {
    this.recycles.list.push(...this.selectedDrafts);
    // 从草稿箱删除
    this.selectedDrafts.forEach(item => {
      this.drafts.list = this.drafts.list.filter(draft => draft.videoId !== item.videoId);
    });
    // 清空选择列表
    this.selectedDrafts = [];
    this.isEdit = false;
  }

  restoreToDraft() {
    this.drafts.list.push(...this.selectedRecycles);
    this.selectedRecycles.forEach(item => {
      this.recycles.list = this.recycles.list.filter(recycle => recycle.videoId !== item.videoId);
    });
    this.selectedRecycles = [];
    this.isEdit = false;
  }

  deletePermanently() {
    this.selectedRecycles.forEach(item => {
      this.recycles.list = this.recycles.list.filter(recycle => recycle.videoId !== item.videoId);
    });
    this.selectedRecycles = [];
    this.isEdit = false;
  }
}