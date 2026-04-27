/**
 * @usage: 音频格式转换首页,作为格式转换功能的入口页面。
 * 接收从SelectPage传递的音频文件信息,然后跳转到AudioFormatPage进行格式转换操作。
 * 提供默认的回调处理逻辑,将转换成功的音频保存到作品列表并切换到作品Tab页。
 * @layout: 页面直接渲染AudioFormatPage组件,传递音频文件信息(标题、时长、大小、格式、路径)和回调函数。
 * 使用NavDestination包裹,支持路由导航。
 * @constraints: 必须从SelectPage传递音频文件信息。转换成功后自动保存到作品列表,并切换到作品Tab页展示。
 * @domain: 音频编辑
 * @zhName: 音频格式转换首页
 * @isGen: true
 * @fileType: page
 * @subPage: AudioFormatPage
 * @component: AudioFormatPage
 * @image: screenshots/audioEditHome/audio_format_conversion.jpg
 */
import {
  FileUtil, PersistenceV2Util, TValueType
} from 'audio_common';
import { common } from '@kit.AbilityKit';
import { getFormatSize } from '../util/CommonUtil';
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel';
import { phoneRouterControl } from 'oh_router';
import { fileIo } from '@kit.CoreFileKit';
import { MusicParam } from 'common_view';
import { media } from '@kit.MediaKit';
import { MusicViewModelArray } from 'common_view/src/main/ets/viewModel/MusicListViewModel';
import { AudioFormatPage } from 'audio_format_conversion'
import { BarVM, ChangeTabUtilContr, GlobalContext } from 'common';
import { NavPageInfo } from 'oh_router/src/main/ets/router/interface/RouterPageInfo';

@Builder
export function AudioFormatConversionPageBuilder(params: TValueType) {
  AudioFormatHome()
}


@ComponentV2
export struct AudioFormatHome {
  @Local resultCallBack: ((outPath: string) => void) | undefined = undefined;
  @Local title: string = ''
  @Local duration: number = 0
  @Local sizePos: string = '0KB'
  @Local format: string = ''
  @Local sourcePath: string = '' //音频源文件文件沙箱路径
  persistenceV2Util = new PersistenceV2Util();
  backHandle = () => {
    phoneRouterControl.popPage()
  }
  // 默认的回调处理逻辑：持久化保存并提示
  defaultResultCallBack = async (outPath: string) => {
    const fileUtil = new FileUtil(this.getUIContext().getHostContext() as common.UIAbilityContext);
    const format = fileUtil.splitFilePath(outPath)[2];
    let fileName = fileUtil.splitFilePath(outPath)[1];
    const fd = fileIo.openSync(outPath).fd;
    let musicParam: MusicParam | undefined = undefined;
    try {
      const fileInfo = await fileIo.stat(fd);
      // 创建AVMetadataExtractor对象。
      let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor();
      avMetadataExtractor.fdSrc = { fd: fd };
      const avMetaData = await avMetadataExtractor.fetchMetadata();
      let title = fileName;
      let duration = Number(avMetaData.duration);
      let size = getFormatSize(fileInfo.size);
      musicParam = {
        uri: '',
        title: title,
        duration: duration,
        size: size,
        format: format,
        path: outPath
      };
      avMetadataExtractor.release();
    } catch (e) {
    } finally {
      fileIo.closeSync(fd);
    }

    const tempStr = this.persistenceV2Util.getData('work');
    let tmepData: MusicViewModelArray = [];
    if (tempStr) {
      tmepData = JSON.parse(tempStr) as MusicViewModelArray;
    }
    if (!musicParam) {
      return;
    }
    const tempMusicViewModel =
      new MusicViewModel(musicParam.uri, musicParam.title, musicParam.duration, musicParam.size, musicParam.format,
        musicParam.path);
    tmepData.unshift(tempMusicViewModel);
    if (!this.persistenceV2Util.setData(JSON.stringify(tmepData), 'work')) {
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '数据存储超出限制'
      })
    }

    this.getUIContext().getPromptAction().showToast({
      message: '格式转换已成功',
      duration: 3000
    });

    ChangeTabUtilContr.isBackHome = true
    let navPageInfoList: NavPageInfo[] = phoneRouterControl.getNavPageInfoList()
    phoneRouterControl.popIndex(0)

  }

  build() {
    NavDestination() {
      Column() {
        AudioFormatPage({
          // 如果外部传入了 resultCallBack，则使用外部的；否则使用默认的持久化逻辑
          resultCallBack: this.defaultResultCallBack,
          backHandle: this.backHandle,
          sourcePath: this.sourcePath,
          musicTitle: this.title,
          duration: this.duration,
          format: this.format,
          sizePos: this.sizePos
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0A0D1E')
      .padding({
        top: BarVM.instance.staBarH
      })
    }
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .hideTitleBar(true)
    .onReady((context) => {
      let param = context.pathInfo.param as Record<string, string | number>
      this.title =  param.title as string || ''
      this.duration =  param.duration as number || 0
      this.sizePos =  param.size as string || ''
      this.format =  param.format as string || ''
      this.sourcePath = param.sourcePath as string
    })
  }
}

