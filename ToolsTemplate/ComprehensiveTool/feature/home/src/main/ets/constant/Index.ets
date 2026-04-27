/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ToolTypeModule } from '../model/Index';
import { Category, ToolType } from './Enum';

export const TOOL_TYPE_MODULES: ToolTypeModule[] = [
  {
    id: ToolType.ALL,
    category: Category.ALL,
    title: '全部',
    icon: $r('app.media.almanac'),
    url: '',
  },
  {
    id: ToolType.ALMANAC,
    category: Category.LIFE,
    title: '黄历',
    icon: $r('app.media.almanac'),
    url: 'AlmanacView',
  },
  {
    id: ToolType.CALCULATOR,
    title: '计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.calculator'),
    url: 'HomePage',
  },
  {
    id: ToolType.DATE_CALCULATOR,
    title: '日期计算',
    category: Category.CALCULATE,
    icon: $r('app.media.date'),
    url: 'DateCalculatorPage',
  },
  {
    id: ToolType.EXCHANGE_RATE,
    title: '汇率计算',
    category: Category.CALCULATE,
    icon: $r('app.media.exchange'),
    url: 'ExchangeRateCalculatorPage',
  },
  {
    id: ToolType.CALORIES,
    title: '热量计算',
    category: Category.LIFE,
    icon: $r('app.media.calories'),
    url: 'CaloriesPage',
  },
  {
    id: ToolType.PERSONAL_INCOME_TAX_CALCULATOR,
    title: '个税计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.income'),
    url: 'IncomePage',
  },
  {
    id: ToolType.REMOTE_CONTROLLER,
    title: '万能空调遥控器',
    category: Category.LIFE,
    icon: $r('app.media.remote'),
    url: 'RemotePage',
  },
  {
    id: ToolType.MORTGAGE_CALCULATOR,
    title: '房贷计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.mortgage'),
    url: 'MortgageCalculationHome',
  },
  {
    id: ToolType.PERSONAL_NOTES,
    title: '隐私笔记',
    category: Category.LIFE,
    icon: $r('app.media.privacy_notes'),
    url: 'PersonalNotesPage',
  },
  {
    id: ToolType.PICTURE_WATERMARK,
    title: '图片水印',
    category: Category.LIFE,
    icon: $r('app.media.watermark'),
    url: 'WaterMarksShow',
  },

  {
    id: ToolType.DECOMPRESSION_TOOL,
    title: '敲木鱼',
    category: Category.LIFE,
    icon: $r('app.media.muyu'),
    url: 'DecompressionToolPage',
  },
  {
    id: ToolType.SCIENCE_CALCULATOR,
    title: '科学计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.calculator'),
    url: 'ScienceCalcHomePage',
  },
  {
    id: ToolType.MONEY_TRACK,
    title: '记账',
    category: Category.LIFE,
    icon: $r('app.media.money_track'),
    url: 'MoneyTrackPage',
  },
  {
    id: ToolType.CALENDAR_EVENT,
    title: '日程提醒',
    category: Category.LIFE,
    icon: $r('app.media.agenda'),
    url: 'CalendarEvent',
  },
  {
    id: ToolType.MOBILE_NFC,
    title: '手机NFC',
    category: Category.LIFE,
    icon: $r('app.media.nfc'),
    url: 'NfcHome',
  },
  {
    id: ToolType.SIMPLE_RECORDER,
    title: '录音专家',
    category: Category.LIFE,
    icon: $r('app.media.recorder'),
    url: 'RecorderHomePage',
  },
  {
    id: ToolType.COMPASS,
    title: '罗盘',
    category: Category.LIFE,
    icon: $r('app.media.compass'),
    url: 'CompassPage',
  },
  {
    id: ToolType.BMI_CALCULATOR,
    title: 'BMI计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.bmi'),
    url: 'BmiHome',
  },
  {
    id: ToolType.DIARY,
    title: '日记',
    category: Category.LIFE,
    icon: $r('app.media.diary'),
    url: 'DiaryPage',
  },
  {
    id: ToolType.NETWORK_SPEED,
    title: '网速测量',
    category: Category.CALCULATE,
    icon: $r('app.media.network_speed'),
    url: 'InternetSpeed',
  },
  {
    id: ToolType.PHOTO_EDITING,
    title: '修图神器',
    category: Category.LIFE,
    icon: $r('app.media.photo_editing'),
    url: 'PhotoEditing',
  },
  {
    id: ToolType.DRAW_BOARD,
    title: '绘画',
    category: Category.LIFE,
    icon: $r('app.media.draw_board'),
    url: 'DrawBoard',
  },
  {
    id: ToolType.ZIP_TOOL,
    title: '解压缩工具',
    category: Category.CALCULATE,
    icon: $r('app.media.zip'),
    url: 'ZipPage',
  },
  {
    id: ToolType.GUITAR_TUNING,
    title: '吉他调音器',
    category: Category.LIFE,
    icon: $r('app.media.guitar_icon'),
    url: 'TuningPage',
  },
  {
    id: ToolType.VIDEO_CLIP,
    title: '视频剪辑',
    category: Category.LIFE,
    icon: $r('app.media.video_clip'),
    url: 'VideoManage',
  },
  {
    id: ToolType.CLONE,
    title: '克隆',
    category: Category.CALCULATE,
    icon: $r('app.media.clone'),
    url: 'ClonePage',
  },
  {
    id: ToolType.HANDHELD_BULLET,
    title: '手持弹幕',
    category: Category.LIFE,
    icon: $r('app.media.bullet'),
    url: 'BulletPage',
  },
  {
    id: ToolType.IMAGE_RECOGNITION,
    title: '图文识别',
    category: Category.LIFE,
    icon: $r('app.media.recognition'),
    url: 'RecognitionHomePage',
  },
  {
    id: ToolType.FINANCIAL_CALCULATOR,
    title: '理财计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.financial'),
    url: 'FinancialPage',
  },
  {
    id: ToolType.PENSION_CALCULATOR,
    title: '养老金计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.pension'),
    url: 'PensionPage',
  },
  {
    id: ToolType.KINSHIP_CALCULATOR,
    title: '亲属称呼计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.kenship'),
    url: 'KinshipPage',
  },
  {
    id: ToolType.RETIREMENT_AGE_CALCULATOR,
    title: '退休年龄计算器',
    category: Category.CALCULATE,
    icon: $r('app.media.retirement'),
    url: 'RetirementAgePage',
  },
  {
    id: ToolType.CREDENTIALS_PHOTO,
    title: '证件照',
    category: Category.LIFE,
    icon: $r('app.media.credentials'),
    url: 'CredentialsPage',
  },
  {
    id: ToolType.AR_MEASURE,
    title: 'AR测量',
    category: Category.LIFE,
    icon: $r('app.media.ar_measure'),
    url: 'ARMeasure',
  },
  {
    id: ToolType.TRANSLATOR,
    title: '翻译',
    category: Category.CALCULATE,
    icon: $r('app.media.translator'),
    url: 'TranslatorPage',
  },
  {
    id: ToolType.CAST_TOOL,
    title: '投屏',
    category: Category.LIFE,
    icon: $r('app.media.cast'),
    url: 'CastPage',
  },
];
