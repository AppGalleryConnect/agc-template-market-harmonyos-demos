export interface BookInfo {
  id: string
  name: string
  coverUrl?: PixelMap | ResourceStr | DrawableDescriptor
  rate: string
  description: string
  author: string
  localPath: string,
  epubUrl: string,
  category?: string,
  isFree?: boolean,
  count?: string
  popular?: string
}