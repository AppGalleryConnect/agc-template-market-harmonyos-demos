import { GlobalStyle, GlobalStyleObjType } from './Model';

export function getDefaultBaseStyle(): GlobalStyleObjType {
  const data: GlobalStyle = {
    fontSize:16,
    imageSize:16,
  }
  return data;
}

/**
 * AppStorage命名空间
 */
export const COMMON_NAMESPACE = 'COMMON_STYLE'

/**
 * 设置全局样式
 * @param styleData
 */
export function setCommonBaseStyle(styleData?: Partial<GlobalStyle>) {
  const newStyleData = getDefaultBaseStyle();
  if (typeof styleData === 'object' && styleData !== null) {
    Object.keys(styleData).forEach(item => {
      if (newStyleData[item]) {
        newStyleData[item] = (styleData as GlobalStyleObjType)[item] ?? newStyleData[item]
      }
    })
  }
  AppStorage.setOrCreate(COMMON_NAMESPACE, newStyleData)
}