import { Sex } from '../common/Constant';


export interface RelationShip {
  text: string,
  target: string,
  sex: Sex,
  reverse: boolean
  mode: string,
  optimal: boolean
}

export interface Selector {
  from: string,
  to: string,
  sex: Sex,
}

export interface MateMap {
  'w': string[]
  'h': string[]
}