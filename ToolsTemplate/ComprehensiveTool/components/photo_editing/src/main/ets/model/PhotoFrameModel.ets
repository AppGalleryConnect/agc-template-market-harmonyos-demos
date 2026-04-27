export class PhotoFrameModel {
  image?: Resource
  background?: Resource
  isVip?: boolean

  constructor( background: Resource, image: Resource, isVip:boolean = false) {
    this.image = image
    this.background = background
    this.isVip = isVip
  }
}