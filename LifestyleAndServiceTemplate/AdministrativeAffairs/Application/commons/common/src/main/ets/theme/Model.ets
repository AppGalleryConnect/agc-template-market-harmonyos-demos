interface FontSizeData {
  fontSize: number;
}

interface ImageSize {
  imageSize: number;
}

export interface GlobalStyle extends FontSizeData,ImageSize {}
export type BaseStyleValue = string | number | EdgeEffect;
export type GlobalStyleObjType = Record<keyof GlobalStyle, BaseStyleValue>