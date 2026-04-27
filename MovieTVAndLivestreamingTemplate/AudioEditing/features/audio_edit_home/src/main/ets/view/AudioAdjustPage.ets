/**
 * @usage: 音频调整页面,用户从SelectPage选择音频后跳转到此页面进行音频调整操作。
 * 根据pageType参数渲染不同的调整功能:音频调速(audioAdjustSpeed)、音频调节(audioAdjustTone)、
 * 降噪处理(audioNoiseReduction)。处理成功后自动保存到作品列表并切换到作品Tab页展示。
 * @layout: 页面采用NavDestination包裹Column垂直布局,顶部为状态栏占位,
 * 根据pageType条件渲染AudioAdjustSpeed、AudioAdjustTone或AudioNoiseReduction组件。
 * @constraints: 必须从SelectPage传递音频文件信息和pageType参数。
 * @domain: 音频编辑
 * @zhName: 音频调整页面
 * @isGen: true
 * @fileType: page
 * @subPage: 
 * @component: AudioAdjustSpeed,AudioAdjustTone,AudioNoiseReduction
 * @image: screenshots/audioEditHome/audio_adjust.jpg
 */
import { AudioAdjustSpeed } from 'audio_adjust_speed'
import { AudioAdjustTone } from 'audio_adjust_tone'
import { phoneRouterControl } from 'oh_router'
import { PersistenceV2Util } from 'audio_common'
import { common } from '@kit.AbilityKit'
import { AudioSave } from '../util/AudioSave'
import { AudioNoiseReduction } from '../components/AudioNoiseReduction'
import { NavPageInfo } from 'oh_router/src/main/ets/router/interface/RouterPageInfo'
import { BarVM, ChangeTabUtilContr } from 'common'


phoneRouterControl.registerPageBuilder('AudioAdjustPage', wrapBuilder(AudioAdjustPageBuilder))

@Builder
export function AudioAdjustPageBuilder(params: object) {
  AudioAdjustPage()
}

@ComponentV2
export struct AudioAdjustPage {
  @Local musicTitle: string = ''
  @Local pcmPath: string = '' //pcm路径
  @Local sourcePath: string = '' //源文件路径
  @Local channelLayout: number = 0 //声道数量
  @Local sampleRate: number = 0 //采样率
  @Local duration: number = 0 //音频时长（毫秒）
  @Local sampleFormat: number = 0 //音频时长（毫秒）
  @Local format: string = ''
  @Local label: string = ''
  persistenceV2Util = new PersistenceV2Util()
  @Local pageType: string = ''
  resultCallBack = (outPath: string) => {
    new AudioSave(this.getUIContext()).save(this.getUIContext().getHostContext() as common.UIAbilityContext, outPath)
    ChangeTabUtilContr.isBackHome = true
    let navPageInfoList: NavPageInfo[] = phoneRouterControl.getNavPageInfoList()


  }
  backHandle = () => {
    if (ChangeTabUtilContr.isBackHome) {
      return
    }
    phoneRouterControl.popPage()
  }

  build() {
    NavDestination() {
      Column() {
        if (this.pageType === 'audioAdjustSpeed') {
          AudioAdjustSpeed({
            musicTitle: this.musicTitle,
            pcmPath: this.pcmPath,
            sourcePath: this.sourcePath,
            channelLayout: this.channelLayout,
            sampleRate: this.sampleRate,
            duration: this.duration,
            sampleFormat: this.sampleFormat,
            resultCallBack: this.resultCallBack,
            backHandle: this.backHandle,
            format: this.format
          })
        } else if (this.pageType === 'audioAdjustTone') {
          AudioAdjustTone({
            musicTitle: this.musicTitle,
            sourcePath: this.sourcePath,
            duration: this.duration,
            resultCallBack: this.resultCallBack,
            backHandle: this.backHandle,
            format: this.format,
            sampleRate: this.sampleRate
          })
        } else {
          AudioNoiseReduction({
            musicTitle: this.musicTitle,
            sourcePath: this.sourcePath,
            duration: this.duration,
            resultCallBack: this.resultCallBack,
            backHandle: this.backHandle,
            format: this.format
          })
        }

      }.width('100%').height('100%')
    }
    .backgroundColor('#0A0D1E')
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .padding({
      top: BarVM.instance.staBarH
    })
    .onReady((context) => {
      let param = context.pathInfo.param as Record<string, string | number>
      this.pcmPath = param.path as string || ''
      this.sourcePath = param.sourcePath as string || ''
      this.channelLayout = param.channelLayout as number || 0
      this.sampleRate = param.sampleRate as number || 0
      this.duration = param.duration as number || 0
      this.musicTitle = param.title as string || ''
      this.sampleFormat = param.sampleFormat as number || 0
      this.pageType = param.pageType as string || ''
      this.format = param.format as string || ''
      this.label = param.label as string || ''
    })
    .onBackPressed(() => {
      this.backHandle()
      return true
    })
  }
}