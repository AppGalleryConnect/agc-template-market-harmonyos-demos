export interface IRegion {
  code: string,
  name: string,
  children?: IRegion[]
}