let pathStack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
};

export const getInstance = (): NavPathStack => {
  return pathStack;
};

export enum RouterMap {
  //  首页
  HOME = 'RecognitionHomePage',
  //  文本结果页
  TEXT_RESULT = 'TextResultPage',
  //  pdf结果页
  PDF_RESULT = 'PdfResultPage',
  //   文档扫描
  DOC_SCAN = 'DocScanPage',
  //   卡证识别
  CARD_RECOGNITION = 'CardRecognitionPage',
  //  相机页
  CAMERA  = 'CameraPage'
}