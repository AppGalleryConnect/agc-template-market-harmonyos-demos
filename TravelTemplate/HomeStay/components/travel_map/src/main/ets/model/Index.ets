export interface TravelMapOptions {
  location: Location,
  icon: ResourceStr,
  titleOptions: TitleOptions,
  cameraSpeed: number,
  zoom: number,
  height: number | string,
  pointClickCallBack: ()=> void
}

export interface Location {
  latitude: number,
  longitude: number,
}

export interface TitleOptions {
  name: string,
  strokeColor: number
}