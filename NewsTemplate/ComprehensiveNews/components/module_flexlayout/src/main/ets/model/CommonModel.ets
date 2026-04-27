export type JSONObject = ESObject;

export class LayoutSetting {
  type: string = ''
  style: Record<string, string | number> = {}
  showType: string = ''
  children: LayoutSetting[] = []
}

export class LayoutParams {
  nativeCardData: JSONObject
  currentIndex: number = 0
  extraInfo: Record<string, string | boolean | Record<string, string | boolean>[] | JSONObject[] | Function> = {}
  layout: LayoutSetting = new LayoutSetting()

  constructor(nativeCardData: JSONObject, currentIndex: number,
    extraInfo: Record<string, string | boolean
      | Record<string, string | boolean>[] | Function>, layout: LayoutSetting) {
    this.nativeCardData = nativeCardData
    this.currentIndex = currentIndex
    this.extraInfo = extraInfo
    this.layout = layout
  }
}