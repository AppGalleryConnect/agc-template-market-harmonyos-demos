let pathStack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
};

export const getInstance = (): NavPathStack => {
  return pathStack;
};

export enum RouterMap {
  //  首页
  HOME = 'RecorderHomePage',
  //  列表页
  LIST = 'ListPage',
  //  语音转文字
  CONVERT = 'ConvertPage',
  //  格式转换
  FORMAT = 'FormatPage',
  //  音频编辑页
  OPERATION = 'OperationPage',
  //  录音
  RECORD = 'RecordPage',
  //  录音文件管理
  AUDIO_MANAGE = 'AudioManagePage'
}