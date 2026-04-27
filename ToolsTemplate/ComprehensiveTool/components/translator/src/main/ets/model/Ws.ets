export type KinshipDictionary = Record<string, string>;

export interface IResult {
  encoding: string,
  compress: string,
  format: string
}

export interface IatParams {
  domain: string,
  language: string,
  accent: string,
  result: IResult
}

export interface IHeader {
  status: number,
  app_id: string
}

export interface IParameter {
  iat: IatParams
}

export interface IAudio {
  audio: string
  sample_rate: number
  encoding: string
}

export interface IPayload {
  audio: IAudio
}

export interface WebAudio {
  header: IHeader
  parameter: IParameter
  payload: IPayload
}

export interface IResponseHeader {
  message: string,
  code: number,
  sid: string,
  status: number,
}

export interface IResponseResult {
  compress: string,
  encoding: string,
  format: string,
  seq: number,
  status: number,
  text: string
}

export interface IResponsePayload {
  result: IResponseResult
}

export interface IResponse {
  header: IResponseHeader,
  payload: IResponsePayload
}

export interface IResponseWsCw {
  ng: number,
  ph: string,
  sc: number,
  w: string,
  wb: number,
  wc: number,
  we: number,
  wp: string,
  lg?: string,
}

export interface IResponseWs {
  bg: number,
  cw: IResponseWsCw[],
}

export interface IResponseText {
  sn: number,
  ls: boolean,
  bg: number,
  ed: number,
  pgs: string,
  rst: string,
  rg: number[],
  ws: IResponseWs[],
}