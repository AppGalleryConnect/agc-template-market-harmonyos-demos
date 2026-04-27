export class CoverModel {
  image: Resource;
  info: string;

  constructor(image: Resource, info: string) {
    this.image = image;
    this.info = info;
  }
}
