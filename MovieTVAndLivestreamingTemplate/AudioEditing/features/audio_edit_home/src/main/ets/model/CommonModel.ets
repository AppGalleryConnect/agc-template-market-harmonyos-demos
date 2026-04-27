import { RouterMap } from 'common';
import { SelectPageBuilder } from '../view/SelectPage';
import { AudioFormatConversionPageBuilder } from '../view/AudioFormatConversionPage'
import { AudioExtractionHomeBuilder } from '../view/AudioExtractionHomePage'
import { VipCenterPageBuilder } from 'person'

const selectPageBuilder: WrappedBuilder<[Object]> = wrapBuilder(SelectPageBuilder);
const audioFormatConversionPageBuilder: WrappedBuilder<[Object]> = wrapBuilder(AudioFormatConversionPageBuilder);
const audioExtractionPageBuilder: WrappedBuilder<[Object]> = wrapBuilder(AudioExtractionHomeBuilder);
const vipCenterPageBuilder: WrappedBuilder<[Object]> = wrapBuilder(VipCenterPageBuilder);


export interface MoreSkillModel {
  title: string,
  src: ResourceStr,
  vipIcon?: ResourceStr | string,
  builder: WrappedBuilder<[Object]>,
  pageName: string,
  param?:Record<string, string>
}

export const moreSkillData: MoreSkillModel[] = [
  {
    title: '音频调速',
    src: $r('app.media.icon_tiaosu'),
    builder: selectPageBuilder,
    pageName: RouterMap.SELECT_PAGE,
    param:{'pageType':'audioAdjustSpeed', 'headTitle': '选择音频'} as Record<string, string>
  },
  {
    title: '降噪处理',
    src: $r('app.media.icon_jiangzao'),
    builder: selectPageBuilder,
    pageName: RouterMap.SELECT_PAGE,
    param:{'pageType':'audioNoiseReduction', 'headTitle': '选择音频'} as Record<string, string>

  },
  {
    title: '音频提取',
    src: $r('app.media.icon_tiqu'),
    vipIcon: $r('app.media.icon_vip_mini'),
    builder: audioExtractionPageBuilder,
    pageName: RouterMap.AUDIO_EXTRACTION_PAGE
  },
  {
    title: '格式转换',
    src: $r('app.media.icon_zhuanhuan'),
    builder: audioFormatConversionPageBuilder,
    pageName: RouterMap.SELECT_PAGE,
    param:{'pageType':'audioConversion', 'headTitle': '选择音频'} as Record<string, string>
  },
  {
    title: 'VIP权限',
    src: $r('app.media.icon_vip'),
    builder: vipCenterPageBuilder,
    pageName: RouterMap.VIP_CENTER_PAGE
  }
]
