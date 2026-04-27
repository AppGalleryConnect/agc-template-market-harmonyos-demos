export interface ToolsItem {
  name: string
  id: string
  unSelected:ResourceStr
  selected:ResourceStr
}

export const canvasToolsList: ToolsItem[] = [
  {
    name: '画笔',
    id: 'pen',
    selected:$r('app.media.paintbrush_active'),
    unSelected:$r('app.media.paintbrush')
  },
  {
    name: '橡皮',
    id: 'rubbers',
    selected:$r('app.media.rubbers_active'),
    unSelected:$r('app.media.rubbers')
  },
  {
    name: '图形',
    id: 'pattern',
    selected:$r('app.media.shape_active'),
    unSelected:$r('app.media.shape')
  }
]

export interface ButtonType {
  img: Resource
  txt: string
}

export const CANVAS_COLOR: string[] = [
  '#FFFFFF',
  '#ff8f9499',
  '#778898',
  '#FFAAD4',
  '#FF3599',
  '#BF0060',
  '#DBB5FE',
  '#CA8EFF',
  '#911AFF',
  '#CECFFF',
  '#6A6AFE',
  '#2928FF',
  '#ffa5eca0',
  '#ff82ef7f',
  '#ff1f9416',
  '#ffe29090',
  '#ffec4141',
  '#ffee1111',
  '#ff9ef3f0',
  '#ff46efea',
  '#ff09efe8',
  '#fff3e3a8',
  '#fff1d050',
  '#fff5c40f',
]

export const PEN_COLOR: string[] = [
  '#F44236',
  '#E91E63',
  '#FF2C93',
  '#9C28B1',
  '#673BB7',
  '#3F51B5',
  '#2196F3',
  '#03A9F5',
  '#00BCD5',
  '#009788',
  '#4CB050',
  '#8BC24A',
  '#CDDC39',
  '#FFEB3C',
  '#FEC107',
  '#FF9700',
  '#795547',
  '#607D8B',
  '#9E9E9E',
  '#000000',
  '#FEE9F0',
  '#F7BCD0',
  '#F48FB1',
  '#F16997',
]
