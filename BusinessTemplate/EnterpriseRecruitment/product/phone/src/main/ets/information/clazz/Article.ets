/**
 * 咨询和业余生活的信息
 */
export class Article {
  constructor(id: string, title: Resource, content: Resource, photo: Resource) {
    this.id = id;
    this.title = title;
    this.content = content;
    this.photo = photo;
  }

  id: string;
  title: Resource;
  content: Resource;
  photo: Resource;
}