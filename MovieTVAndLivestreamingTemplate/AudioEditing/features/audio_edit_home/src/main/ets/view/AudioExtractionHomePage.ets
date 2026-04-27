/**
 * @usage: 音频提取首页,作为音频提取功能的入口页面。
 * 用户点击后直接进入AudioExtractionPage进行视频选择和音频提取操作。
 * 提供默认的回调处理逻辑,将提取成功的音频保存到作品列表并切换到作品Tab页。
 * @layout: 页面直接渲染AudioExtractionPage组件,传递回调函数和VIP等级参数。
 * 使用NavDestination包裹,支持路由导航。
 * @constraints: 需要VIP权限控制,通过userInfo.vipLevel传递VIP等级。
 * 提取成功后自动保存到作品列表,并切换到作品Tab页展示。
 * @domain: 音频编辑
 * @zhName: 音频提取首页
 * @isGen: true
 * @fileType: page
 * @subPage: AudioExtractionPage
 * @component: AudioExtractionPage
 * @image: screenshots/audioEditHome/audio_extraction.jpg
 */
import { phoneRouterControl } from 'oh_router';
import { AudioExtractionPage } from 'audio_extraction';
import { FileUtil, PersistenceV2Util } from 'audio_common';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { media } from '@kit.MediaKit';
import { MusicParam } from 'common_view';
import { MusicViewModelArray } from 'common_view/src/main/ets/viewModel/MusicListViewModel';
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel';
import { getFormatSize } from '../util/CommonUtil';
import { BarVM, ChangeTabUtilContr, UserInfo } from 'common';
import { PersistenceV2 } from '@kit.ArkUI';
import { NavPageInfo } from 'oh_router/src/main/ets/router/interface/RouterPageInfo';

const TAG = 'AudioExtractionHome';

@ComponentV2
export struct AudioExtractionHome {
  @Local resultCallBack: ((outPath: string) => void) | undefined = undefined;
  @Local backHandle: (() => void) | undefined = undefined;
  persistenceV2Util = new PersistenceV2Util();
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  onReady(context: NavDestinationContext) {
    // 从路由参数中获取回调函数
    const params = context.pathInfo.param as Record<string, Object>;
    if (params) {
      if (params.resultCallBack) {
        this.resultCallBack = params.resultCallBack as (outPath: string) => void;
      }
      if (params.backHandle) {
        this.backHandle = params.backHandle as () => void;
      }
    }
  }

  // 默认的回调处理逻辑：持久化保存并提示
  defaultResultCallBack = async (outPath: string) => {
    try {
      const fileUtil = new FileUtil(this.getUIContext().getHostContext() as common.UIAbilityContext);
      const format = fileUtil.splitFilePath(outPath)[2];
      let fileName = fileUtil.splitFilePath(outPath)[1];

      let title = fileName;
      let duration = 0;
      let size = '0KB';

      // 尝试打开文件获取详细信息，失败不影响保存
      try {
        const fd = fileIo.openSync(outPath).fd;
        try {
          const fileInfo = await fileIo.stat(fd);
          size = getFormatSize(fileInfo.size);

          // 创建AVMetadataExtractor对象。
          let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
          // // 获取rawfile目录下资源文件描述符，设置fdSrc属性。
          avMetadataExtractor.fdSrc = { fd: fd };
          const avMetaData = await avMetadataExtractor.fetchMetadata();
          duration = Number(avMetaData.duration);
          avMetadataExtractor.release();
        } catch (e) {
        } finally {
          fileIo.closeSync(fd);
        }
      } catch (err) {
      }

      let musicParam: MusicParam = {
        uri: '',
        title: title,
        duration: duration,
        size: size,
        format: format,
        path: outPath
      };

      const tempStr = this.persistenceV2Util.getData('work');
      let tmepData: MusicViewModelArray = [];
      if (tempStr) {
        tmepData = JSON.parse(tempStr) as MusicViewModelArray;
      }

      const tempMusicViewModel =
        new MusicViewModel(musicParam.uri, musicParam.title, musicParam.duration, musicParam.size, musicParam.format,
          musicParam.path);
      // 优化：将新数据插入到列表头部
      tmepData.unshift(tempMusicViewModel);
      if (!this.persistenceV2Util.setData(JSON.stringify(tmepData), 'work')) {
        this.getUIContext().getPromptAction().showToast({
          message: '数据存储超出限制',
        });
        return
      }
      this.persistenceV2Util.setData(JSON.stringify(tmepData), 'work');

      this.getUIContext().getPromptAction().showToast({
        message: '保存成功',
        duration: 1000
      });
      ChangeTabUtilContr.isBackHome = true
      let navPageInfoList: NavPageInfo[] = phoneRouterControl.getNavPageInfoList()
      phoneRouterControl.popIndex(0)


      // 延迟退出
      // setTimeout(() => {
      //   this.handleBack();
      // }, 500);
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({
        message: '保存失败，请重试',
        duration: 2000
      });
    }
  }
  handleBack = () => {
    if (this.backHandle) {
      this.backHandle();
    } else {
      phoneRouterControl.popPage();
    }
  }

  build() {
    NavDestination() {
      Column() {
        AudioExtractionPage({
          // 如果外部传入了 resultCallBack，则使用外部的；否则使用默认的持久化逻辑
          resultCallBack: this.resultCallBack ? this.resultCallBack : this.defaultResultCallBack,
          backHandle: this.handleBack,
          vipLevel: this.userInfo.vipLevel
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0A0D1E')
      .padding({
        top: BarVM.instance.staBarH
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .onReady((context: NavDestinationContext) => {
      this.onReady(context);
    })
  }
}

phoneRouterControl.registerPageBuilder('AudioExtractionPage', wrapBuilder(AudioExtractionHomeBuilder));

@Builder
export function AudioExtractionHomeBuilder(params: object) {
  AudioExtractionHome()
}
